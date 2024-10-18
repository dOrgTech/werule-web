
// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

import 'human.dart';
import 'proposal.dart';
import 'token.dart';

class Org {
  var pollsCollection;
  var votesCollection;
  Org
  ({ required this.name,
    this.govToken,
    this.description,
    this.govTokenAddress
    });
  DateTime? creationDate;
  List<User>? members;
  Token? govToken;
  String? symbol;
  int? decimals;
  String? govTokenAddress;
  String? treasuryAddress;
  List<Proposal> proposals=[];
  List<String>? proposalIDs=[];
  late String name;
  String? description;
  Map<Token,double> treasury={};
  String? address;
  int holders=1;
  int quorum=0;
  int supermajority=0;
  int votingDuration=0;
  int votingDelay=0;
  int executionAvailability=0;

  getProposals()async{
    pollsCollection=FirebaseFirestore
      .instance.collection("daos${Human().chain.name}")
      .doc(address).collection("proposals");
    var proposalsSnapshot= await pollsCollection.get();
    for (var doc in proposalsSnapshot.docs){
      Proposal p =Proposal(
        type: doc.data()['type'],
        name:doc.data()['title']
        ) ;
      p.against=doc.data()['against'];
      p.inFavor=doc.data()['inFavor'];
      p.callData=doc.data()['calldata'];
      p.createdAt=(doc.data()['createdAt'] as Timestamp).toDate();
      p.status=doc.data()['status'];
      p.turnoutPercent=doc.data()['turnoutPercent'];
      p.author=doc.data()['author'];
      p.votesFor=doc.data()['votesFor'];
      p.votesAgainst=doc.data()['votesAgainst'];
      p.externalResource=doc.data()['externalResource'];
      p.description=doc.data()['description'];
      proposals.add(p);
      proposalIDs!.add(doc.id);
    }

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
      'votingDuration':votingDuration,
      'executionAvailability':executionAvailability,
      'quorum':quorum,
      'supermajority':supermajority
    };
  }
}






