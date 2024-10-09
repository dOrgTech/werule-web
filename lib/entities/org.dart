
import 'human.dart';
import 'proposal.dart';
import 'token.dart';
import 'dart:math';
class Org {
  Org({ required this.name, required this.token, this.description});

  DateTime? creationDate;
  List<User>? members;
  Token token;
  List<Proposal>? proposals;
  String name;
  String? description;
  Map<Token,double>? treasury;
  String? address;
  int holders=1; 
}