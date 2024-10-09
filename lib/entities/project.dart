import 'dart:math';

import '../entities/token.dart';

class Project{
  String? name;
  DateTime? creationDate;
  DateTime? expiresAt;
  String? description;
  String? client;
  String ?arbiter;
  String? terms;
  String? requirements;
  double? amountInEscrow;
  String? status;
  List<Token>? acceptedTokens;

  // Constructor with logic
  Project({this.name, this.description,this.client, this.arbiter, this.requirements, this.status, this.terms}){
    int random = Random().nextInt(331) + 90;
    amountInEscrow = random * 100;
    creationDate=DateTime.now();
    expiresAt=creationDate!.add(Duration(days: 30));
    acceptedTokens=[

    
    ];
  }

}



