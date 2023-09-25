
import 'human.dart';
import 'proposal.dart';
import 'token.dart';
import 'dart:math';
class Org {
  Org({required this.address, required this.name, required this.token, this.description}) {
    final random = Random();
    holders = random.nextInt(4) + random.nextInt(4) + 1;
  }


  List<Human>? members;
  Token token;
  List<Proposal>? proposals;
  String name;
  String? description;
  Map<Token,double>? treasury;
  String? address;
  int holders=1; 
}