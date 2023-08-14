






var proposalTypes={
  "Offchain Poll":"Create in inconsequential poll for your community",
  "Transfer Assets": "from the DAO Treasury to another account",
  "Edit Registry": "Change an entry or add a new one",
  "Add Lambda":"Write custom Michelson code for your DAO",
  "Remove Lambda": "Delete an existing functionality",
  "Execute Lambda":"Call any of the custom or standard functions",
  "DAO Configuration": "Change the proposal fee and/or the returned amount",
  "Change Guardian": "Set a priviledge address that can drop spam proposals",
  "Change DAO Delegate":"for the main consensus layer on Tezos."
};





class Proposal{
  String? type;
  String? typeDescription;
  String? name;
  String? description;
  String? author;
  String? code;
  String? params;
  DateTime? postedTime;
  Duration? votingDuration;
  List? votes; 

  Proposal({required this.type});


}