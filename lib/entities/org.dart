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
    Debate d = Debate(
        org: this,
        title: "Should AI have the weekend off?",
        rootArgument: Argument(
            content: "Maybve bnut oaij doqij w content",
            author: "0x83198dw712987d9821739812dws",
            weight: 100));

    debates.add(d);
  }
  DateTime? creationDate;
  Map<String, Member> memberAddresses = {};
  Token? govToken;
  String? symbol;
  int? decimals;
  bool debatesOnly = false;
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
    nativeBalance = await getNativeBalance(registryAddress!);
    native.address = "native";
    print("populating treasury");
    treasury = {};
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
        .collection("idaos${Human().chain.name}")
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
