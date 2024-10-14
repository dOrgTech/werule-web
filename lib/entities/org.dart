
import 'human.dart';
import 'proposal.dart';
import 'token.dart';
import 'dart:math';
class Org {
  Org({ required this.name, this.govToken, this.description, this.govTokenAddress});
  DateTime? creationDate;
  List<User>? members;
  Token? govToken;
  String? govTokenAddress;
  List<Proposal>? proposals;
  List<String>? proposalIDs;
  late String name;
  String? description;
  Map<Token,double>? treasury;
  String? address;
  int holders=1; 

  fromJson(Map<String, dynamic> json) {
    name = json['name'];
    govTokenAddress = json['token'];
    description = json['description'];
    address = json['address'];
    creationDate = DateTime.fromMillisecondsSinceEpoch(json['creationDate']);
    // members = json['members'].map<User>((member) => User.fromJson(member)).toList();
  }

   toJson(){
    return {
      'name':name,
      'created':creationDate,
      'description':description,
      'token':govTokenAddress,
      'address':address,
      'holders':holders,
      'proposals':proposalIDs,
      'treasury':treasury
    };
  }
}



