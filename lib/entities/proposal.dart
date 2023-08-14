






import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:homebase/widgets/newProject.dart';

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
  "New Project (arbitrated)":"Create a new engagement with escrow and dispute resolution."
};
var state;
var newProposalWidgets={
  "New Project (arbitrated)": NewProject(),
  "Offchain Poll":NotImplemented(),
  "Transfer Assets": NotImplemented(),
  "Edit Registry": NotImplemented(),
  "Add Lambda":NotImplemented(),
  "Remove Lambda": NotImplemented(),
  "Execute Lambda":NotImplemented(),
  "DAO Configuration": NotImplemented(),
  "Change Guardian": NotImplemented(),
  "Change DAO Delegate":NotImplemented(),
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
  String? type;
  String? typeDescription;
  String? name="Title of the proposal (max 80 characters)";
  String? description;
  String? author;
  String? code;
  String? params;
  DateTime? postedTime;
  Duration? votingDuration;
  List? votes; 

  Proposal({required this.type, this.name});
  

  


}