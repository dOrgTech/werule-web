import 'package:flutter/material.dart';
import '../widgets/executeLambda.dart';
import '../widgets/newProject.dart';


var proposalTypes={
  "Offchain Poll":"Create in inconsequential poll for your community",
  "Transfer Assets": "from the DAO Treasury to another account",
  "Edit Registry": "Change an entry or add a new one",
  "Add Lambda":"Write custom Michelson code for your DAO",
  "Remove Lambda": "Delete an existing functionality",
  "Execute Lambda":"Call any of the custom or standard functions",
  "DAO Configuration": "Change the proposal fee and/or the returned amount",
  "Change Guardian": "Set a priviledge address that can drop spam proposals",
  "Change DAO Delegate":"for the main consensus layer on Tezos.",
  "New Project (arbitrated)":"Create a new engagement with escrow and dispute resolution.",
  "Fund Project":"Send funds to a Homebase Project",
};
var state;
var newProposalWidgets={
  "New Project (arbitrated)": NewProject(),
  "Offchain Poll":NotImplemented(),
  "Transfer Assets": NotImplemented(),
  "Edit Registry": NotImplemented(),
  "Add Lambda":NotImplemented(),
  "Remove Lambda": NotImplemented(),
  "Execute Lambda":ExecuteLambda(),
  "DAO Configuration": NotImplemented(),
  "Change Guardian": NotImplemented(),
  "Change DAO Delegate":NotImplemented(),
  //  "Fund Project": FundProject(org:daos![0]),
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


class Proposal{
  String hash="";
  String? type;
  String? name="Title of the proposal (max 80 characters)";
  String? description;
  String? author;
  String? callData;
  DateTime? createdAt;
  String? status;
  int turnoutPercent=0;
  String inFavor="0";
  String against="0";
  int votesFor=0;
  int votesAgainst=0;
  String? externalResource;
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
