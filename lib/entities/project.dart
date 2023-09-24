import 'dart:math';

import 'package:homebase/entities/token.dart';

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

      Token(address: "---", name: "Native", symbol: "XTZ", decimals: 5),
      Token(address: "KT1MzN5jLkbbq9P6WEFmTffUrYtK8niZavzH", name: "Bug Hunt Thursday", symbol: "BGT", decimals: 5),
      Token(address: "KT1Dmemf2YRbA5vEejvaGWa6ghYn9fH7EKu4", name: "Very Tasty Jelly", symbol: "VTJ", decimals: 6),
      Token(address: "KT1E7jkyAWhCoMbPZbVUJMo7xAfKcqYyCG6Z", name: "FLToken", symbol: "FLT", decimals: 2)
    ];
  }

}



