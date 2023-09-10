



import 'dart:math';

class Project{
  String? type;
  String? name;
  String? description;
  String? client;
  String ?arbiter;
  String? link;
  int? amountInEscrow;
  String? status;

  // Constructor with logic
  Project({this.name, this.description,this.client, this.arbiter, this.link, this.status}){
    int random = Random().nextInt(331) + 90;
    amountInEscrow = random * 100;
    if(type==null)
    {type="set";}
  }

  



}