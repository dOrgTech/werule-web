
import 'human.dart';
import 'proposal.dart';
import 'token.dart';

class Org{
  List<Human>? members;
  List<Proposal>? proposals;
  String? name;
  String? description;
  Map<Token,double>? treasury;
  String? address;
}