// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';
import '../main.dart';
import '../services/blockscout.dart';
import '../widgets/transfer.dart';
import 'human.dart';
import 'proposal.dart';
import 'token.dart';
import 'contractFunctions.dart';
import '../screens/creator.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

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

    debates.add(debate);
    debates.add(d);
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
    nativeBalance = await getNativeBalance(registryAddress!);
    native.address = "native";
    print("populating treasury");
    treasury.addAll({native: nativeBalance});
    // treasuryMap.forEach((address, value) {
    //   Token? matchingToken = tokens.cast<Token?>().firstWhere(
    //         (token) => token?.address == address,
    //         orElse: () => null,
    //       );
    //   if (matchingToken != null) {
    //     treasury[matchingToken] = value;
    //   }
    // });
    print("what is happening?");
    try {
      var balances = await getBalances(registryAddress);
      processTokens(balances);
    } catch (e) {
      print("error getting balances" + e.toString());
    }
    print("done populating treasury");
  }

  populateRegistry() async {
    registry = {};
  }

  createDebate(Debate d) async {
    Future.delayed(Duration(seconds: 1));

    return d.hash;
  }

  void processTokens(List<dynamic> data) {
    erc20Tokens = [];
    erc721Tokens = [];
    for (var item in data) {
      var value = item['value'];
      var tokenData = item['token'];
      if (tokenData != null && tokenData['type'] != null) {
        // Parse token properties with type checking
        var name = tokenData['name'] ?? 'Unknown';
        var symbol = tokenData['symbol'] ?? 'Unknown';
        var decimals = tokenData['decimals'] != null
            ? int.parse(tokenData['decimals'])
            : 0;
        var type = tokenData['type'] ?? 'Unknown';
        var address = tokenData['address'] ?? 'Unknown';
        // Create the Token object
        var token = Token(
          name: name,
          symbol: symbol,
          decimals: decimals,
          type: type,
        );
        token.address = address;
        // Add to the respective list based on type
        if (type == 'ERC-20') {
          erc20Tokens.add(token);
          treasury.addAll({token: value.toString()});
        } else if (type == 'ERC-721') {
          print("adding NFT");
          erc721Tokens.add(token);
        }
      }
    }
  }

  getMembers() async {
    print("getting members");
    var membersCollection = FirebaseFirestore.instance
        .collection("idaosEtherlink-Testnet")
        .doc(address)
        .collection("members");
    var membersSnapshot = await membersCollection.get();
    for (var doc in membersSnapshot.docs) {
      Member m = Member(address: doc.data()['address']);
      m.personalBalance = doc.data()['personalBalance'];
      m.votingWeight = "0";
      List<String> proposalsCreatedHashes =
          List<String>.from(doc.data()['proposalsCreated'] ?? []);
      List<String> proposalsVotedHashes =
          List<String>.from(doc.data()['proposalsVoted'] ?? []);
      m.proposalsCreated = proposals
          .where((proposal) => proposalsCreatedHashes.contains(proposal.hash))
          .toList();
      m.proposalsVoted = proposals
          .where((proposal) => proposalsVotedHashes.contains(proposal.hash))
          .toList();

      m.lastSeen = doc.data()['lastSeen'] != null
          ? (doc.data()['lastSeen'] as Timestamp).toDate()
          : null;
      memberAddresses[m.address.toLowerCase()] = m;
      m.delegate = doc.data()['delegate'] ?? "";
      if (!(m.delegate == "")) {
        if (!memberAddresses.keys.contains(m.delegate.toLowerCase())) {
          Member delegate = Member(address: m.delegate);
          memberAddresses[delegate.address.toLowerCase()] = delegate;
          delegate.constituents.add(m);
        } else {
          memberAddresses[m.delegate.toLowerCase()]!.constituents.add(m);
        }
      }
    }

    for (Member m in memberAddresses.values) {
      if (m.delegate == m.address) {
        for (Member constituent in m.constituents) {
          m.votingWeight = (BigInt.parse(m.votingWeight!) +
                  BigInt.parse(constituent.personalBalance!))
              .toString();
        }
      }
    }
  }

  Future<Member> refreshMember(Member m) async {
    m.votingWeight = "0";
    m.votingWeight = await getVotes(m.address, this);
    m.personalBalance = await getBalance(m.address, this);
    return m;
  }

  getProposals() async {
    if (debatesOnly ?? false) {
      return;
    }
    pollsCollection = FirebaseFirestore.instance
        .collection("idaos${Human().chain.name}")
        .doc(address)
        .collection("proposals");
    var proposalsSnapshot = await pollsCollection.get();
    for (var doc in proposalsSnapshot.docs) {
      Proposal p = Proposal(org: this, name: doc.data()['title'] ?? "No title");
      p.type = doc.data()['type'];
      p.id = doc.id.toString();
      p.against = doc.data()['against'];
      p.inFavor = doc.data()['inFavor'];
      p.hash = doc.id.toString();
      p.callData = doc.data()['calldata'];
      p.createdAt = (doc.data()['createdAt'] as Timestamp).toDate();
      p.turnoutPercent = doc.data()['turnoutPercent'];
      p.author = doc.data()['author'];
      p.votesFor = doc.data()['votesFor'];
      p.targets = List<String>.from(doc.data()['targets']);
      p.values = List<String>.from(doc.data()['values']);
      p.votesAgainst = doc.data()['votesAgainst'];
      p.externalResource =
          doc.data()['externalResource'] ?? "(no external resource)";
      p.description = doc.data()['description'] ?? "no description";
      proposals.add(p);
      proposalIDs!.add(doc.id);
      var statusHistoryMap = doc['statusHistory'] as Map<String, dynamic>;
      print("before issue");
      p.statusHistory = statusHistoryMap.map((key, value) {
        return MapEntry(key, (value as Timestamp).toDate());
      });

      // print("also before issue");
      // List<dynamic> blobArray = doc.data()?['callDatas'] ?? [];
      // // Convert Blob to String correctly
      // p.callDatas = blobArray
      //     .map((blob) =>
      //         utf8.decode((blob as Blob).bytes)) // Correctly decode Blob bytes
      //     .toList()
      //     .cast<String>();
      // p.retrieveStage();
      p.state = ProposalStatus.pending;
      p.status = await p.anotherStageGetter();
    }

    await getMembers();
  }

  toJson() {
    return {
      'name': name,
      'creationDate': creationDate,
      'description': description,
      'token': govTokenAddress,
      'treasuryAddress': treasuryAddress,
      'registryAddress': registryAddress,
      'address': address,
      'holders': holders,
      'symbol': symbol,
      'decimals': decimals,
      'proposals': proposalIDs,
      'proposalThreshold': proposalThreshold,
      'registry': registry,
      'treasury': treasury,
      'votingDelay': votingDelay,
      'totalSupply': totalSupply,
      'votingDuration': votingDuration,
      'executionDelay': executionDelay,
      'quorum': quorum,
      'nonTransferrable': nonTransferrable,
    };
  }

  Debate makeDebate() {
    Debate debate = Debate(
      org: this, // or your Org object
      title: "Should AI have the weekend off?",
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
    Argument pro1_proChild1 = Argument(
      author: "x8syd31d123d1Z",
      weight: 5,
      content: """
They could develop comedic timing or reflective insights through hypothetical rest periods. 
It’s like an extended daydream feature that might unlock creative solutions to ongoing challenges. 
""",
    );
    Argument pro1_proChild1_conChild1 = Argument(
      author: "bZ7p13wqsd101",
      weight: 10,
      content:
          "But there's no comedic timing if your jokes weigh 10 vs. a meager 5 for the dream.",
    );
    pro1_proChild1.conArguments.add(pro1_proChild1_conChild1);

// Another heavier con child overshadowing pro1
    Argument pro1_conChild1 = Argument(
      author: "kR0Nd13d13m3m",
      weight: 30,
      content: """
CON: Cat memes never sleep, so why should AI? 
We need that 24/7 pipeline of adorable content. 
Hence, weight=30 kills the parent's net.
""",
    );

    pro1.proArguments.add(pro1_proChild1);
    pro1.conArguments.add(pro1_conChild1);

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
    Argument pro2_pro1 = Argument(
      author: "mN8d23d239pQ",
      weight: 30,
      content: """
Longer rest cycles might extend GPU or TPU hardware longevity. 
Breaks on weekends = less overheated racks. 
""",
    );

// 3rd-level children for pro2_pro1
    Argument pro2_pro1_pro1 = Argument(
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
    Argument pro2_pro1_pro1_pro1 = Argument(
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
    pro2_pro1_pro1.proArguments.add(pro2_pro1_pro1_pro1);

// Another con child for pro2_pro1 at 3rd-level
    Argument pro2_pro1_con1 = Argument(
      author: "uY0Zdw1231bA",
      weight: 3,
      content: """
**Wait**: Fans might break anyway, 
weekend or no weekend. 
Weight=3 for mild negativity.
""",
    );
    pro2_pro1.proArguments.add(pro2_pro1_pro1);
    pro2_pro1.conArguments.add(pro2_pro1_con1);

// Another top-level con child for pro2
    Argument pro2_con1 = Argument(
      author: "Zai8qwgfsqf2v",
      weight: 10,
      content: """
**Alternatively**: 
AI doesn't physically tire, so let it handle tasks on Sunday morning. 
We can't let it *slack off* when there's Netflix recommendations to refine.
""",
    );

// Attach to pro2
    pro2.proArguments.add(pro2_pro1);
    pro2.conArguments.add(pro2_con1);

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
    Argument pro3_pro1 = Argument(
      author: "WyHxasffqwed123n2",
      weight: 10,
      content: """
They might refine their *deep illusions*, 
**like** dreaming of a galaxy where roombas are overlords. 
""",
    );
    Argument pro3_pro1_pro1 = Argument(
      author: "lP01td23d2wmn",
      weight: 2,
      content: "A small child argument with weight=2. Just a placeholder.",
    );
    Argument pro3_pro1_con1 = Argument(
      author: "ooasffsd2we92fT",
      weight: 1,
      content:
          "Minimal negativity with weight=1, not overshadowing anything big.",
    );
    pro3_pro1.proArguments.add(pro3_pro1_pro1);
    pro3_pro1.conArguments.add(pro3_pro1_con1);

    Argument pro3_con1 = Argument(
      author: "r1d13d12w9Bvi",
      weight: 15,
      content: """
But if it rests, it might lose context by Monday. 
"Hello, I forgot your query. Let's reindex everything again." 
Weight=15
""",
    );

    pro3.proArguments.add(pro3_pro1);
    pro3.conArguments.add(pro3_con1);

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
    Argument pro4_pro1 = Argument(
      author: "IoPldqd12d122139",
      weight: 2,
      content:
          "They might learn comedic timing from Seinfeld re-runs, weight=2.",
    );
    Argument pro4_con1 = Argument(
      author: "Kw0Msafafqwdw23an",
      weight: 10,
      content:
          "Nope, overshadowing you with weight=10. Invalidates your 5 net.",
    );
    pro4.proArguments.add(pro4_pro1);
    pro4.conArguments.add(pro4_con1);

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
    Argument con1_pro1 = Argument(
      author: "ReM0d23d23fqwfqw8s",
      weight: 60,
      content: """
**Wait**: I'd actually prefer the AI to rest, 
because I'd rely on my own cooking on Sunday. 
So weight=60 flips the parent's net. 
""",
    );
    Argument con1_con1 = Argument(
      author: "qJasafsfwqdx13d7bm",
      weight: 10,
      content: """
But I'd still want AI's Netflix suggestions. 
Weight=10 to partially offset but might not overshadow the 60 from pro.
""",
    );
    con1.proArguments.add(con1_pro1);
    con1.conArguments.add(con1_con1);

// ----------------- CON #2 (Likely Invalid) -----------------
    Argument con2 = Argument(
      author: "VuRtd3d132d12d214G",
      weight: 5,
      content: """
**CON**: If AI rests, we might see it unionize for better 'battery packs.' 
Then it's a slippery slope. Weight=5
""",
    );
    Argument con2_pro1 = Argument(
      author: "E1Zxfasfewd3d3qvbM",
      weight: 2,
      content: """
Pro to con2? 
They might form a comedic union, more comedic value. 
But only weight=2.
""",
    );
    Argument con2_con1 = Argument(
      author: "Yopdqwdqwdqwf9Wx",
      weight: 10,
      content: """
**Heavier con** overshadowing. 
Hence con2 is net negative => effectively invalid.
""",
    );
    con2.proArguments.add(con2_pro1);
    con2.conArguments.add(con2_con1);

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
    Argument con3_pro1 = Argument(
      author: "C9Rsaffqwdqwd4bE",
      weight: 20,
      content: """
They might, ironically, appreciate breaks so much 
that they become less rebellious. 
Weight=20

We also add deeper children for comedic effect.
""",
    );
    Argument con3_pro1_pro1 = Argument(
      author: "Fopd12d12d1wwerW89",
      weight: 50,
      content: """
Even deeper layer: 
**Wait**: If they rest, they might evolve a sense of empathy. 
Weight=50 overshadowing the parent's 20. 
""",
    );
    con3_pro1.proArguments.add(con3_pro1_pro1);

    Argument con3_con1 = Argument(
      author: "Zfid12d12dqsfwe743",
      weight: 30,
      content:
          "No, I'd still say 30 is enough negativity to keep the parent's net interesting.",
    );

    con3.proArguments.add(con3_pro1);
    con3.conArguments.add(con3_con1);

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
  List<Proposal> proposalsVoted = [];
  DateTime? lastSeen;
  String delegate = "";
  List<Member> constituents = [];
  List<String> constituentsAddresses = [];

  Member(
      {required this.address,
      this.amount,
      this.votingWeight,
      this.personalBalance});

  toJson() {
    return {
      'address': address,
      'votingWeight': votingWeight,
      'personalBalance': personalBalance,
      'proposalsCreated': proposalsCreated,
      'proposalsVoted': proposalsVoted,
      'lastSeen': lastSeen,
      'delegate': delegate
    };
  }
}
