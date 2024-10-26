
// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../widgets/transfer.dart';
import 'human.dart';
import 'proposal.dart';
import 'token.dart';
import 'contractFunctions.dart';
import '../screens/creator.dart';
class Org {
  var pollsCollection;
  var votesCollection;
  Org
  ({required this.name,
    this.govToken,
    this.description,
    this.govTokenAddress
    });
  DateTime? creationDate;
  List<Member> members=[];
  Token? govToken;
  String? symbol;
  int? decimals;
  String? totalSupply;
  bool nonTransferrable=false;
  String? govTokenAddress;
  String? treasuryAddress;
  List<Proposal> proposals=[];
  List<String>? proposalIDs=[];
  late String name;
  String? description;
  Map<String, String> treasuryMap={};
  Map<Token,String> treasury={};
  String? address;
  int holders=1;
  int quorum=0;
  int supermajority=0;
  int votingDelay=0;
  int votingDuration=0;
  String nativeBalance="0";
  int executionAvailability=0;

 populateTreasury() async{
  treasury={};
  Token tokenXTZ=Token(
    name:"Tezos",
    symbol:"XTZ",
    decimals:18);
  nativeBalance=await getNativeBalance(address!);
  tokenXTZ.address="native";
  treasury.addAll({tokenXTZ:nativeBalance});
  treasuryMap.forEach((address, value) {
    Token? matchingToken = tokens.cast<Token?>().firstWhere(
      (token) => token?.address == address,
      orElse: () => null,
    );
    if (matchingToken != null) {
      treasury[matchingToken] = value;
    }
  });
}

  getMembers()async{
    print("getting members");
     var membersCollection = daosCollection.doc(address).collection("members");
     var membersSnapshot =await  membersCollection.get();
     for(var doc in membersSnapshot.docs){
      print("adding one member");
      Member m=Member(address: doc.data()['address']);
      print("after creating the member");
      m.personalBalance=doc.data()['personalBalance'];
      
      m.votingWeight=doc.data()['votingWeight'];
      List<String> proposalsCreatedHashes=List<String>.from(doc.data()['proposalsCreated'] ?? []);
      List<String> proposalsVotedHashes=List<String>.from(doc.data()['proposalsVoted'] ?? []);
      m.proposalsCreated=proposals.where((proposal) => proposalsCreatedHashes.contains(proposal.hash)).toList();
      m.proposalsVoted=proposals.where((proposal) => proposalsVotedHashes.contains(proposal.hash)).toList();
      m.lastSeen=  doc.data()['lastSeen'] != null
    ? (doc.data()['lastSeen'] as Timestamp).toDate()
    : null;
      // m.delegate=doc.data()['delegate'];
      members.add(m);
     }
     
  }


  getProposals()async{
    print("getting proposals");
    await populateTreasury();
    pollsCollection=FirebaseFirestore
      .instance.collection("daos${Human().chain.name}")
      .doc(address).collection("proposals");
    var proposalsSnapshot= await pollsCollection.get();
    for (var doc in proposalsSnapshot.docs){
      Proposal p =Proposal(
        org: this,
        type: doc.data()['type'],
        name:doc.data()['title']
        ) ;
      p.against=doc.data()['against'];
      p.inFavor=doc.data()['inFavor'];
      p.callData=doc.data()['calldata'];
      p.createdAt=(doc.data()['createdAt'] as Timestamp).toDate();
      p.turnoutPercent=doc.data()['turnoutPercent'];
      p.author=doc.data()['author'];
      p.votesFor=doc.data()['votesFor'];
      p.votesAgainst=doc.data()['votesAgainst'];
      p.externalResource=doc.data()['externalResource'];
      p.description=doc.data()['description'];
      proposals.add(p);
      proposalIDs!.add(doc.id);
      var statusHistoryMap = doc['statusHistory'] as Map<String, dynamic>;
      p.statusHistory = statusHistoryMap.map((key, value) {
        return MapEntry(key, (value as Timestamp).toDate());
      });
      p.getStatus();
      p.transactions=(doc.data()['transactions'] as List<dynamic>).map((tx) {
        return Txaction(
          recipient: tx['recipient'],
          value: tx['value'],
          callData: tx['callData'],
        )..hash = tx['hash'];
      }).toList();
      
  }
      print("before getting member");
      await getMembers();
  }
   toJson(){
    return {
      'name':name,
      'creationDate':creationDate,
      'description':description,
      'token':govTokenAddress,
      'treasuryAddress':treasuryAddress,
      'address':address,
      'holders':holders,
      'symbol':symbol,
      'decimals':decimals,
      'proposals':proposalIDs,
      'treasury':treasury,
      'votingDelay':votingDelay,
      'totalSupply':totalSupply,
      'votingDuration':votingDuration,
      'executionAvailability':executionAvailability,
      'quorum':quorum,
      'nonTransferrable':nonTransferrable,
      'supermajority':supermajority
    };
  }
}






