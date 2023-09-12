import 'dart:math';

class Project{
  String? name;
  DateTime? creationDate;
  DateTime? expiresAt;
  String? description;
  String? client;
  String ?arbiter;
  String? terms;
  String? requirements;
  int? amountInEscrow;
  String? status;

  // Constructor with logic
  Project({this.name, this.description,this.client, this.arbiter, this.requirements, this.status, this.terms}){
    int random = Random().nextInt(331) + 90;
    amountInEscrow = random * 100;
    creationDate=DateTime.now();
    expiresAt=creationDate!.add(Duration(days: 30));
  }

  



}