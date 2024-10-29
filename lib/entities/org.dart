
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
  
  Map<String, Member> memberAddresses={};
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
    Member m=Member(address: doc.data()['address']);
    m.personalBalance=doc.data()['personalBalance'];
    m.votingWeight="0";
    List<String> proposalsCreatedHashes=List<String>.from(doc.data()['proposalsCreated'] ?? []);
    List<String> proposalsVotedHashes=List<String>.from(doc.data()['proposalsVoted'] ?? []);
    m.proposalsCreated=proposals.where((proposal) => proposalsCreatedHashes.contains(proposal.hash)).toList();
    m.proposalsVoted=proposals.where((proposal) => proposalsVotedHashes.contains(proposal.hash)).toList();
    m.lastSeen = doc.data()['lastSeen'] != null
  ? (doc.data()['lastSeen'] as Timestamp).toDate()
  : null;
    memberAddresses[m.address.toLowerCase()]=m;
    m.delegate=doc.data()['delegate']??"";
    if (!(m.delegate=="")){
      if(!memberAddresses.keys.contains(m.delegate.toLowerCase())){
          Member delegate=Member(address: m.delegate);
          memberAddresses[delegate.address.toLowerCase()]=delegate;
          delegate.constituents.add(m);
      }else{
          memberAddresses[m.delegate.toLowerCase()]!.constituents.add(m);
        }
    }
    
    }
    
    for (Member m in memberAddresses.values){
       if (m.delegate==m.address){
          for (Member constituent in m.constituents){
            m.votingWeight = (BigInt.parse(m.votingWeight!)
            +
            BigInt.parse(constituent.personalBalance!)).toString();
        }
      }
    }
}


Member refreshMember(Member m){
  m.constituents.add(m);
  m.votingWeight="0";
   if (m.delegate==m.address){
          for (Member constituent in m.constituents){
            m.votingWeight = (BigInt.parse(m.votingWeight!)
            +
            BigInt.parse(constituent.personalBalance!)).toString();
        }
      }
  print("returning voting power "+m.votingWeight.toString());
  return m;
}


  getProposals()async{
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


class Member {
  String address;
  int? amount;
  String? votingWeight="0";
  String? personalBalance;
  List<Proposal> proposalsCreated = [];
  List<Proposal> proposalsVoted = [];
  DateTime? lastSeen;
  String delegate="";
  List<Member> constituents=[];

  Member({
    required this.address, this.amount,
  this.votingWeight, this.personalBalance});

  toJson(){
    return {
      'address':address,
      'votingWeight':votingWeight,
      'personalBalance':personalBalance,
      'proposalsCreated':proposalsCreated,
      'proposalsVoted':proposalsVoted,
      'lastSeen':lastSeen,
      'delegate':delegate
    };
  }

}






