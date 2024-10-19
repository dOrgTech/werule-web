import 'package:Homebase/entities/token.dart';
import 'package:flutter/material.dart';
import '../widgets/executeLambda.dart';
import '../widgets/newProject.dart';
import '../widgets/transfer.dart';
import 'org.dart';


var proposalTypes={
  "Offchain Poll":"Create in inconsequential poll for your community",
  "Transfer Assets": "from the DAO Treasury to another account",
  "Edit Registry": "Change an entry or add a new one",
  "Contract Interaction":"Call any function on any contract",
  "DAO Configuration": "Change the proposal fee and/or the returned amount",

};
var state;
var newProposalWidgets={
"New Project (arbitrated)": (Org org) => NewProject(org: org),
  "Offchain Poll": (Org org) => NotImplemented(),
  "Transfer Assets": (Org org) => TransferWidget(org: org),
  "Edit Registry": (Org org) => NotImplemented(),
  "Add Lambda": (Org org) => NotImplemented(),
  "Remove Lambda": (Org org) => NotImplemented(),
  "Contract Interaction": (Org org) => ExecuteLambda(org: org),
  "DAO Configuration": (Org org) => NotImplemented(),
  "Change Guardian": (Org org) => NotImplemented(),
  "Change DAO Delegate": (Org org) => NotImplemented(),
  // You can add more widgets as needed
};

class NotImplemented extends StatelessWidget {
  const NotImplemented({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 300,height: 240,
    child:Center(child: Text("NOT IMPLEMENTED"),)
    
    );
  }
}

class Txaction{
  Txaction({
    required this.sender,
    required this.recipient,
    required this.value,
    required this.callData
  });

  String? hash;
  String? sender;
  String? recipient;
  String value="0";
  String callData="0x";
}

class Proposal{
  int? id;
  String hash="";
  String? type;
  String? name="Title of the proposal (max 80 characters)";
  String? description;
  String? author;
  double value=0;
  String? callData;
  DateTime? createdAt;
  String? status;
  int turnoutPercent=0;
  String inFavor="0";
  String against="0";
  int votesFor=0;
  int votesAgainst=0;
  String? externalResource;
  List<Txaction> transactions=[];
  List<Vote> votes=[];
  Proposal({required this.type, this.name});

  toJson(){
    return {
      'hash':hash,
      'type':type,
      'name':name,
      'description':description,
      'author':author,
      'calldata':callData,
      'createdAt':createdAt,
      'status':status,
      'turnoutPercent':turnoutPercent,
      'inFavor':inFavor,
      'against':against,
      'votesFor':votesFor,
      'votesAgainst':votesAgainst,
      'externalResource':externalResource
    };
  }
}


class Vote{
  String? voter;
  String? proposalID;
  int option;
  String votingPower;
  DateTime? castAt;
  Vote({
    required this.votingPower,
    required this.voter, required this.proposalID, required this.option});
  
  toJson(){
      return {
        'votingPower':votingPower,
        'castAt':castAt,
        'voter':voter,
        'proposalID':proposalID,
        'option':option
      };
    }
  }

  class Member{
    Member({required this.address, required this.votingPower});
    String address;
    String votingPower;
    DateTime? lastActive;
    int proposalsCreated=0;
    int votesCast=0;
    String personalVotingPower="0";

    toJson(){
      return {
        'address':address,
        'votingPower':votingPower,
        'lastActive':lastActive,
        'proposalsCreated':proposalsCreated,
        'votesCast':votesCast,
        'personalVotingPower':personalVotingPower};
    }
  }
