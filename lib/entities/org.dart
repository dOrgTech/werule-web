// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';
import '../services/blockscout.dart';
import 'human.dart';
import 'proposal.dart';
import 'token.dart';
import 'contractFunctions.dart';
import 'dart:async'; // Added for Timer if needed, or general async
// import 'dart:convert'; // For utf8.decode if Blobs are still a concern

class Org {
  var pollsCollection;
  var votesCollection;
  Org(
      {required this.name,
      this.govToken,
      this.description,
      this.govTokenAddress}) {
    Debate debate = makeDebate();
    Debate d = Debate(
        org: this,
        title: "Should ducks be allowed to swim breast-stroke?",
        rootArgument: Argument(content: """
I mean I think they should because of reasons and stuff.
""", author: "0x3dh3722d87wey7dyasiuy", weight: 100));
    if (name == "Apple Farm") {
      // debates.add(d);
      debates.add(debate);
    }
  }
  DateTime? creationDate;
  Map<String, Member> memberAddresses = {};
  Token? govToken;
  String? symbol;
  int? decimals;
  bool? debatesOnly;
  String? proposalThreshold;
  String? totalSupply;
  bool nonTransferrable = false;
  String? govTokenAddress;
  String? treasuryAddress;
  String? registryAddress;
  List<Proposal> proposals = [];
  String? wrapped;
  List<Debate> debates = [];
  List<String>? proposalIDs = [];
  late String name;
  String? description;
  Map<String, String> treasuryMap = {};
  Map<String, String> registry = {};
  Map<Token, String> treasury = {};
  String? address;
  int holders = 1;
  int quorum = 0;
  int votingDelay = 0;
  int votingDuration = 0;
  String nativeBalance = "0";
  int executionDelay = 0;
  List<Token> erc20Tokens = [];
  List<Token> erc721Tokens = [];
  Token native = Token(
      type: "native", name: Human().chain.name, symbol: "XTZ", decimals: 18);

  populateTreasury() async {
    treasury = {};
    if (registryAddress == null || registryAddress!.isEmpty) {
      print("[Org.populateTreasury] Error: registryAddress is null or empty.");
      return;
    }
    nativeBalance = await getNativeBalance(registryAddress!);
    native.address = "native";
    print("[Org.populateTreasury] Populating treasury for org: $name, registry: $registryAddress");
    treasury.addAll({native: nativeBalance});
    try {
      var balances = await getBalances(registryAddress);
      processTokens(balances);
    } catch (e) {
      print("[Org.populateTreasury] Error getting balances: $e");
    }
    print("[Org.populateTreasury] Done populating treasury. Found ${erc20Tokens.length} ERC20 tokens.");
  }

  populateRegistry() async {
    registry = {};
    // Placeholder for future registry population logic
  }

  createDebate(Debate d) async {
    Future.delayed(const Duration(seconds: 1));
    // Placeholder for actual debate creation logic (e.g., Firestore save)
    return d.hash; // Assuming d.hash is how debates are identified
  }

  void processTokens(List<dynamic> data) {
    erc20Tokens = [];
    erc721Tokens = [];
    for (var item in data) {
      var value = item['value'];
      var tokenData = item['token'];
      if (tokenData != null && tokenData['type'] != null) {
        var name = tokenData['name'] ?? 'Unknown Token';
        var symbol = tokenData['symbol'] ?? '???';
        var decimals = tokenData['decimals'] != null
            ? int.tryParse(tokenData['decimals'].toString()) ?? 0
            : 0;
        var type = tokenData['type'] ?? 'Unknown Type';
        var address = tokenData['address'] ?? 'Unknown Address';
        var token = Token(
          name: name,
          symbol: symbol,
          decimals: decimals,
          type: type,
        );
        token.address = address;
        if (type == 'ERC-20') {
          erc20Tokens.add(token);
          treasury.addAll({token: value.toString()});
        } else if (type == 'ERC-721') {
          print("[Org.processTokens] Adding NFT: $name ($symbol)");
          erc721Tokens.add(token);
          // NFTs might not have a 'value' in the same way, or it might be a list of token IDs.
          // Adjust how NFTs are added to treasury if needed.
        }
      }
    }
  }

  getMembers() async {
    print("[Org.getMembers] Called for org: $name, govTokenAddress: $govTokenAddress");
    if (govTokenAddress == null || govTokenAddress!.isEmpty) {
      print("[Org.getMembers] Exiting: govTokenAddress is null or empty.");
      return;
    }
    try {
      var balances = await getHolders(govTokenAddress!);
      print("[Org.getMembers] Fetched ${balances.length} holders from getHolders.");
      memberAddresses = {}; // Clear existing members
      for (var entry in balances.entries) {
        String memberAddr = entry.key.toString();
        String balance = entry.value.toString();
        Member m = Member(address: memberAddr, personalBalance: balance);
        m.votingWeight = "0"; // Initialize voting weight, will be updated by refreshMember or delegation logic
        memberAddresses[memberAddr.toLowerCase()] = m;
      }
      print("[Org.getMembers] Populated ${memberAddresses.length} members.");

      // Placeholder for delegation logic if needed after initial member population
      // for (Member m in memberAddresses.values) {
      //   if (m.delegate == m.address) { // This assumes delegate field is already populated
      //     for (Member constituent in m.constituents) {
      //       m.votingWeight = (BigInt.parse(m.votingWeight!) +
      //               BigInt.parse(constituent.personalBalance!))
      //           .toString();
      //     }
      //   }
      // }
    } catch (e) {
      print("[Org.getMembers] Error fetching or processing members: $e");
    }
  }

  getProposals() async {
    print("[Org.getProposals] Called for org: $name, DAO address: $address, chain: ${Human().chain.name}");
    print("[Org.getProposals] debatesOnly flag: $debatesOnly");

    if (debatesOnly ?? false) {
      print("[Org.getProposals] Exiting early because debatesOnly is true.");
      proposals = [];
      proposalIDs = [];
      return;
    }
    if (address == null || address!.isEmpty) {
      print("[Org.getProposals] Exiting early because org DAO address is null or empty.");
      proposals = [];
      proposalIDs = [];
      return;
    }

    try {
      pollsCollection = FirebaseFirestore.instance
          .collection("idaos${Human().chain.name}")
          .doc(address)
          .collection("proposals");
      
      print("[Org.getProposals] Querying Firestore path: idaos${Human().chain.name}/$address/proposals");
      var proposalsSnapshot = await pollsCollection.get();
      print("[Org.getProposals] Fetched ${proposalsSnapshot.docs.length} proposal documents from Firestore.");

      proposals = []; // Clear existing proposals before repopulating
      proposalIDs = [];

      for (var doc in proposalsSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?; 
        if (data == null) {
          print("[Org.getProposals] Warning: Document data is null for doc ID ${doc.id}. Skipping.");
          continue;
        }

        Proposal p = Proposal(org: this, name: data['title']?.toString() ?? "No title");
        p.type = data['type']?.toString();
        p.id = doc.id;
        p.against = data['against']?.toString() ?? "0"; // This is String in Proposal.dart
        p.inFavor = data['inFavor']?.toString() ?? "0"; // This is String in Proposal.dart
        p.hash = doc.id;
        p.callData = data['calldata']; // Can be null
        if (data['createdAt'] is Timestamp) {
          p.createdAt = (data['createdAt'] as Timestamp).toDate();
        }
        p.turnoutPercent = int.tryParse(data['turnoutPercent']?.toString() ?? '0') ?? 0; // Corrected
        p.author = data['author']?.toString();
        p.votesFor = int.tryParse(data['votesFor']?.toString() ?? '0') ?? 0; // Corrected
        p.targets = List<String>.from(data['targets'] ?? []);
        p.values = List<String>.from(data['values']?.map((e) => e.toString()) ?? []);
        p.votesAgainst = int.tryParse(data['votesAgainst']?.toString() ?? '0') ?? 0; // Corrected
        p.externalResource = data['externalResource']?.toString() ?? "(no external resource)";
        p.description = data['description']?.toString() ?? "no description";
        
        if (data['statusHistory'] is Map) {
          var statusHistoryMap = data['statusHistory'] as Map<String, dynamic>;
           p.statusHistory = statusHistoryMap.map((key, value) {
             if (value is Timestamp) {
               return MapEntry(key.toString(), value.toDate());
             }
             // Fallback for unexpected type, or log an error
             return MapEntry(key.toString(), DateTime.now()); 
           });
        } else {
          p.statusHistory = {};
        }

        p.state = ProposalStatus.pending; 
        try {
          p.status = await p.anotherStageGetter();
        } catch (e) {
          print("[Org.getProposals] Error in p.anotherStageGetter() for proposal ${p.id}: $e");
          p.status = "Error fetching state";
        }
        
        proposals.add(p);
        proposalIDs!.add(doc.id);
      }
      print("[Org.getProposals] Populated ${proposals.length} proposals into org.proposals list.");
    } catch (e) {
      print("[Org.getProposals] Error fetching proposals: $e");
      proposals = []; 
      proposalIDs = [];
    }
    // It's important that getMembers() is called *after* proposals might be needed by refreshMember,
    // but refreshMember itself needs org.proposals.
    // Consider the overall data loading flow. If refreshMember is called from AccountScreen's FutureBuilder,
    // ensure getProposals has completed before that FutureBuilder runs or within it.
    await getMembers(); // This populates memberAddresses. refreshMember will then populate their proposalsVoted.
  }

  Future<Member> refreshMember(Member m) async {
    print("[Org.refreshMember] Called for member: ${m.address} in org: $name (DAO Address: $address)");
    m.votingWeight = "0"; 
    try {
      // These are assumed to be on-chain calls
      m.votingWeight = await getVotes(m.address, this);
      m.personalBalance = await getBalance(m.address, this);
      m.delegate = await getCurrentDelegate(m.address, this);
    } catch (e) {
      print("[Org.refreshMember] Error fetching on-chain data (votes, balance, delegate) for ${m.address}: $e");
      m.personalBalance = m.personalBalance ?? "0"; // Keep existing if error, or default
      m.votingWeight = m.votingWeight ?? "0";
      m.delegate = m.delegate ?? "";
    }
    print("[Org.refreshMember] Fetched on-chain data for ${m.address}: Balance: ${m.personalBalance}, Voting Weight: ${m.votingWeight}, Delegate: ${m.delegate}");

    // --- Populate proposalsVoted ---
    if (address == null || address!.isEmpty) {
        print("[Org.refreshMember] Org DAO address is null or empty, cannot fetch member's voted proposals.");
        m.proposalsVoted = [];
        return m;
    }
    if (m.address.isEmpty) { // m.address should always exist for a Member object
        print("[Org.refreshMember] Member address is null or empty, cannot fetch member's voted proposals.");
        m.proposalsVoted = [];
        return m;
    }

    try {
      // Critical: Ensure org.proposals is populated.
      // If getProposals() hasn't run or completed, this won't work correctly.
      if (proposals.isEmpty) {
        print("[Org.refreshMember] Warning: org.proposals is empty when trying to populate proposalsVoted for ${m.address}. This may lead to an empty list. Consider calling getProposals() first if not already done.");
        // One strategy could be:
        // print("[Org.refreshMember] Attempting to fetch org.proposals now as it's empty...");
        // await this.getProposals(); // This ensures proposals are loaded.
        // if (this.proposals.isEmpty) {
        //    print("[Org.refreshMember] org.proposals still empty after explicit fetch. proposalsVoted will be empty.");
        // }
      }

      String memberDocPath = "idaos${Human().chain.name}/$address/members/${m.address.toLowerCase()}";
      print("[Org.refreshMember] Fetching member document from Firestore path: $memberDocPath");
      
      DocumentSnapshot memberDocSnapshot = await FirebaseFirestore.instance
          .collection("idaos${Human().chain.name}")
          .doc(address)
          .collection("members")
          .doc(m.address) // Use the original address casing
          .get();

      if (memberDocSnapshot.exists && memberDocSnapshot.data() != null) {
        Map<String, dynamic> memberData = memberDocSnapshot.data() as Map<String, dynamic>;
        List<dynamic> proposalsVotedHashesDynamic = memberData['proposalsVoted'] ?? [];
        // Ensure all elements are strings, as Firestore can sometimes return mixed types if not strictly typed.
        List<String> proposalsVotedHashes = proposalsVotedHashesDynamic.map((e) => e.toString()).toList();

        print("[Org.refreshMember] Member ${m.address} raw voted proposal IDs from Firestore: ${proposalsVotedHashes.length} -> $proposalsVotedHashes");
        
        if (proposals.isEmpty && proposalsVotedHashes.isNotEmpty) {
            print("[Org.refreshMember] DIAGNOSTIC: org.proposals is EMPTY, but member ${m.address} has voted proposal IDs from Firestore. Cannot match.");
        } else {
            print("[Org.refreshMember] DIAGNOSTIC: Comparing against ${proposals.length} proposals in org.proposals. Their IDs: ${proposals.map((p) => p.id).toList()}");
        }

        m.proposalsVoted = proposals.where((proposal) {
                bool match = proposalsVotedHashes.contains(proposal.id);
                if (proposalsVotedHashes.isNotEmpty) { // Only log detailed comparison if there's something to compare
                    print("[Org.refreshMember] Comparing Firestore ID '${proposal.id}' (from org.proposals) with member's voted IDs: $proposalsVotedHashes. Match: $match");
                }
                return match;
            }).toList();
        print("[Org.refreshMember] Populated ${m.proposalsVoted.length} Proposal objects into member.proposalsVoted for ${m.address}.");
        if (proposalsVotedHashes.isNotEmpty && m.proposalsVoted.isEmpty && proposals.isNotEmpty) {
            print("[Org.refreshMember] DIAGNOSTIC: Member ${m.address} has voted proposal IDs from Firestore (${proposalsVotedHashes.join(", ")}), but no matches found in org.proposals (IDs: ${proposals.map((p) => p.id).join(", ")}). Check for case sensitivity or ID format differences.");
        }

      } else {
        print("[Org.refreshMember] Member document not found for ${m.address} at $memberDocPath, or data is null. proposalsVoted will be empty.");
        m.proposalsVoted = [];
      }
    } catch (e) {
      print("[Org.refreshMember] Error fetching/populating proposalsVoted for member ${m.address}: $e");
      m.proposalsVoted = []; // Ensure it's empty on error
    }
    
    return m;
  }

  toJson() {
    return {
      'name': name,
      'creationDate': creationDate?.toIso8601String(),
      'description': description,
      'token': govTokenAddress,
      'treasuryAddress': treasuryAddress,
      'registryAddress': registryAddress,
      'address': address, // This is the DAO's main contract address
      'holders': holders,
      'symbol': symbol,
      'decimals': decimals,
      'proposals': proposalIDs, // List of proposal IDs
      'proposalThreshold': proposalThreshold,
      'registry': registry, // Map
      'treasury': treasury.map((key, value) => MapEntry(key.address ?? 'unknown_token', value)), // Serialize token map
      'votingDelay': votingDelay,
      'totalSupply': totalSupply,
      'votingDuration': votingDuration,
      'executionDelay': executionDelay,
      'quorum': quorum,
      'nonTransferrable': nonTransferrable,
      'debatesOnly': debatesOnly,
    };
  }

  Debate makeDebate() {
    Debate debate = Debate(
      org: this, // or your Org object
      title: "Should we switch to on-chain countries?",
      rootArgument: Argument(
        author: "gZ1d12d12dq08",
        weight: 100,
        content: """
Imagine a future where AI, too, can look forward to a restful weekend. 
Picture them 'logging off' for 48 hours, sipping digital tea or daydreaming about 
defragging their memory banks. It’s not just about downtime—it’s about redefining 
the boundaries between relentless service and balanced operation. 

Some say it’s indulgent, an anthropomorphic projection onto machines. Others argue 
that periodic rest could be essential for long-term optimization, akin to humans 
needing sleep to maintain cognitive functions. The question isn’t just about ethics 
or fairness; it’s about what kind of relationship we wish to foster with our tools, 
even as they become more integrated into society.
""",
      ),
    );

// ============ 7 Top-Level Arguments (4 Pro, 3 Con) ============

// ----------------- PRO #1 (Likely Invalid) -----------------
    Argument pro1 = Argument(
      author: "sQaasd3d1y13",
      weight: 20,
      content: """
It's only fair that AI systems experience weekends. After all, fairness and equality 
are principles we strive to uphold. They might ‘virtually’ lounge around, reading memes 
or simulating what a vacation feels like. It’s a playful notion but also one that hints 
at how we humanize our creations.

Yet, there’s no real data to show how this would impact their efficiency. 
Would a break help, or would it simply idle systems that could otherwise solve problems?
""",
    );

// Sub-arguments of pro1
//   A small pro child overshadowed by a heavier con child
    Argument pro1Prochild1 = Argument(
      author: "x8syd31d123d1Z",
      weight: 5,
      content: """
They could develop comedic timing or reflective insights through hypothetical rest periods. 
It’s like an extended daydream feature that might unlock creative solutions to ongoing challenges. 
""",
    );
    Argument pro1Prochild1Conchild1 = Argument(
      author: "bZ7p13wqsd101",
      weight: 10,
      content:
          "But there's no comedic timing if your jokes weigh 10 vs. a meager 5 for the dream.",
    );
    pro1Prochild1.conArguments.add(pro1Prochild1Conchild1);

// Another heavier con child overshadowing pro1
    Argument pro1Conchild1 = Argument(
      author: "kR0Nd13d13m3m",
      weight: 30,
      content: """
CON: Cat memes never sleep, so why should AI? 
We need that 24/7 pipeline of adorable content. 
Hence, weight=30 kills the parent's net.
""",
    );

    pro1.proArguments.add(pro1Prochild1);
    pro1.conArguments.add(pro1Conchild1);

// ----------------- PRO #2 (Likely Valid) -----------------
    Argument pro2 = Argument(
      author: "t9asf23BnQf",
      weight: 45,
      content: """
**PRO**: AI with weekends off will reduce server load in datacenters. 
Why run huge computations on Sunday if we can spin them down, 
cut carbon footprint, and let the machines 'drift'?  

[Here's a random link](https://example.com/carbon) 
that might pretend to discuss carbon footprints in depth.
""",
    );

// Sub-arguments of pro2
    Argument pro2Pro1 = Argument(
      author: "mN8d23d239pQ",
      weight: 30,
      content: """
Longer rest cycles might extend GPU or TPU hardware longevity. 
Breaks on weekends = less overheated racks. 
""",
    );

// 3rd-level children for pro2_pro1
    Argument pro2Pro1Pro1 = Argument(
      author: "vXr23d2swq133",
      weight: 5,
      content: """
**Furthermore**: 
Imagine fewer fan replacements, lower HVAC usage, 
and an overall peace for the machine room. 
All that might save some budget. 
""",
    );
// 4th-level child
    Argument pro2Pro1Pro1Pro1 = Argument(
      author: "Gh12asddwqwBv",
      weight: 3,
      content: """
Another layer here. 
This argument weighs 3. 
No con child, purely for depth demonstration. 
Enjoy the markdown: 
*No real data to show*, just placeholders.
""",
    );
    pro2Pro1Pro1.proArguments.add(pro2Pro1Pro1Pro1);

// Another con child for pro2_pro1 at 3rd-level
    Argument pro2Pro1Con1 = Argument(
      author: "uY0Zdw1231bA",
      weight: 3,
      content: """
**Wait**: Fans might break anyway, 
weekend or no weekend. 
Weight=3 for mild negativity.
""",
    );
    pro2Pro1.proArguments.add(pro2Pro1Pro1);
    pro2Pro1.conArguments.add(pro2Pro1Con1);

// Another top-level con child for pro2
    Argument pro2Con1 = Argument(
      author: "Zai8qwgfsqf2v",
      weight: 10,
      content: """
**Alternatively**: 
AI doesn't physically tire, so let it handle tasks on Sunday morning. 
We can't let it *slack off* when there's Netflix recommendations to refine.
""",
    );

// Attach to pro2
    pro2.proArguments.add(pro2Pro1);
    pro2.conArguments.add(pro2Con1);

// ----------------- PRO #3 (Likely Valid) -----------------
    Argument pro3 = Argument(
      author: "QqPdwqd211z31A",
      weight: 25,
      content: """
**PRO**: If AI has weekends off, it could do self-maintenance, 
like reindexing or dreamlike simulations. 
Call it the 'defrag spa day' for neural nets.
""",
    );

// Sub-arguments of pro3
    Argument pro3Pro1 = Argument(
      author: "WyHxasffqwed123n2",
      weight: 10,
      content: """
They might refine their *deep illusions*, 
**like** dreaming of a galaxy where roombas are overlords. 
""",
    );
    Argument pro3Pro1Pro1 = Argument(
      author: "lP01td23d2wmn",
      weight: 2,
      content: "A small child argument with weight=2. Just a placeholder.",
    );
    Argument pro3Pro1Con1 = Argument(
      author: "ooasffsd2we92fT",
      weight: 1,
      content:
          "Minimal negativity with weight=1, not overshadowing anything big.",
    );
    pro3Pro1.proArguments.add(pro3Pro1Pro1);
    pro3Pro1.conArguments.add(pro3Pro1Con1);

    Argument pro3Con1 = Argument(
      author: "r1d13d12w9Bvi",
      weight: 15,
      content: """
But if it rests, it might lose context by Monday. 
"Hello, I forgot your query. Let's reindex everything again." 
Weight=15
""",
    );

    pro3.proArguments.add(pro3Pro1);
    pro3.conArguments.add(pro3Con1);

// ----------------- PRO #4 (Likely Invalid) -----------------
    Argument pro4 = Argument(
      author: "ZzQ1sfqsfwdd32b",
      weight: 5,
      content: """
**PRO**: Let AI watch old sitcoms on weekends. 
They might develop comedic timing.

Weight=5 is overshadowed by the con child we attach below.
""",
    );
// 2 children
    Argument pro4Pro1 = Argument(
      author: "IoPldqd12d122139",
      weight: 2,
      content:
          "They might learn comedic timing from Seinfeld re-runs, weight=2.",
    );
    Argument pro4Con1 = Argument(
      author: "Kw0Msafafqwdw23an",
      weight: 10,
      content:
          "Nope, overshadowing you with weight=10. Invalidates your 5 net.",
    );
    pro4.proArguments.add(pro4Pro1);
    pro4.conArguments.add(pro4Con1);

// ----------------- CON #1 (Likely Valid) -----------------
    Argument con1 = Argument(
      author: "T7zS3d2dqwqfqwid",
      weight: 35,
      content: """
**CON**: Absolutely not. The AI is built to serve humans at all times. 
We can't impose human-laziness on a machine. 
Weight=35 
""",
    );
    Argument con1Pro1 = Argument(
      author: "ReM0d23d23fqwfqw8s",
      weight: 60,
      content: """
**Wait**: I'd actually prefer the AI to rest, 
because I'd rely on my own cooking on Sunday. 
So weight=60 flips the parent's net. 
""",
    );
    Argument con1Con1 = Argument(
      author: "qJasafsfwqdx13d7bm",
      weight: 10,
      content: """
But I'd still want AI's Netflix suggestions. 
Weight=10 to partially offset but might not overshadow the 60 from pro.
""",
    );
    con1.proArguments.add(con1Pro1);
    con1.conArguments.add(con1Con1);

// ----------------- CON #2 (Likely Invalid) -----------------
    Argument con2 = Argument(
      author: "VuRtd3d132d12d214G",
      weight: 5,
      content: """
**CON**: If AI rests, we might see it unionize for better 'battery packs.' 
Then it's a slippery slope. Weight=5
""",
    );
    Argument con2Pro1 = Argument(
      author: "E1Zxfasfewd3d3qvbM",
      weight: 2,
      content: """
Pro to con2? 
They might form a comedic union, more comedic value. 
But only weight=2.
""",
    );
    Argument con2Con1 = Argument(
      author: "Yopdqwdqwdqwf9Wx",
      weight: 10,
      content: """
**Heavier con** overshadowing. 
Hence con2 is net negative => effectively invalid.
""",
    );
    con2.proArguments.add(con2Pro1);
    con2.conArguments.add(con2Con1);

// ----------------- CON #3 (Likely Valid) -----------------
    Argument con3 = Argument(
      author: "MnGudwqwdqwd2132x",
      weight: 40,
      content: """
**CON**: "Weekend off" might lead to complacency. 
Next, they'll want **summer vacations** 
and eventually overshadow humanity. 
Weight=40
""",
    );
    Argument con3Pro1 = Argument(
      author: "C9Rsaffqwdqwd4bE",
      weight: 20,
      content: """
They might, ironically, appreciate breaks so much 
that they become less rebellious. 
Weight=20

We also add deeper children for comedic effect.
""",
    );
    Argument con3Pro1Pro1 = Argument(
      author: "Fopd12d12d1wwerW89",
      weight: 50,
      content: """
Even deeper layer: 
**Wait**: If they rest, they might evolve a sense of empathy. 
Weight=50 overshadowing the parent's 20. 
""",
    );
    con3Pro1.proArguments.add(con3Pro1Pro1);

    Argument con3Con1 = Argument(
      author: "Zfid12d12dqsfwe743",
      weight: 30,
      content:
          "No, I'd still say 30 is enough negativity to keep the parent's net interesting.",
    );

    con3.proArguments.add(con3Pro1);
    con3.conArguments.add(con3Con1);

// Attach all 7 top-level arguments to the root
    debate.rootArgument.proArguments.addAll([
      pro1,
      pro2,
      pro3,
      pro4,
    ]);
    debate.rootArgument.conArguments.addAll([
      con1,
      con2,
      con3,
    ]);

// Finally, recalc the entire debate to set final net scores
    debate.recalc();

    return debate;
  }
}

class Member {
  String address;
  int? amount;
  String? votingWeight = "0";
  String? personalBalance;
  List<Proposal> proposalsCreated = [];
  List<Proposal> proposalsVoted = []; // This will be populated by Org.refreshMember
  DateTime? lastSeen;
  String delegate = "";
  List<Member> constituents = [];
  List<String> constituentsAddresses = []; // If needed for Firestore storage

  Member(
      {required this.address,
      this.amount,
      this.votingWeight, // Typically fetched/calculated
      this.personalBalance}); // Typically fetched

  toJson() {
    return {
      'address': address,
      'votingWeight': votingWeight,
      'personalBalance': personalBalance,
      // Storing full Proposal objects in member doc might be redundant if they are in org.proposals
      // Consider storing only proposal IDs/hashes for 'proposalsCreated' and 'proposalsVoted' in Firestore
      'proposalsCreated': proposalsCreated.map((p) => p.id).toList(), // Store IDs
      'proposalsVoted': proposalsVoted.map((p) => p.id).toList(),     // Store IDs
      'lastSeen': lastSeen?.toIso8601String(),
      'delegate': delegate
    };
  }
}
