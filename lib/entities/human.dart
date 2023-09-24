import 'package:homebase/entities/token.dart';

class Human{

  Human({this.address, this.balances, this.lastActive, this.icon});

  String? address;
  Map<Token,double>? balances;
  DateTime? lastActive;
  String? icon;
}