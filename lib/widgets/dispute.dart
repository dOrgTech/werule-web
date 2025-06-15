


import '../entities/token.dart';
import 'package:flutter/material.dart';
// Import this for TextInputFormatter

import '../entities/project.dart';
const String escape = '\uE00C';

class Dispute extends StatefulWidget {
bool loading=false;
bool done=false;
bool error=false;
Project project=Project();

// ignore: use_key_in_widget_constructors
Dispute() ;
  @override
  DisputeState createState() => DisputeState();
}
int pmttoken=0;
class DisputeState extends State<Dispute> {
  String? selectedToken;
  String? selectedAddress;
  TextEditingController amountController = TextEditingController();
  String amount="";
  @override
  Widget build(BuildContext context) {
    List<String> paymentTokens=[];
    for (Token t in widget.project.acceptedTokens!){
      paymentTokens.add("${t.symbol} (${t.name})");}
    return
    Container(
      width: 650,
          padding: const EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).highlightColor,
              width: 0.3,
            ),
          ),
          // width: MediaQuery.of(context).size.width*0.7,
          height:650,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
          const  Text("Initiate dispute",
            textAlign: TextAlign.center,
             style: TextStyle(fontSize: 19), 
              ),
            SizedBox(width: 380,
            child:Text("This action will enable the Arbiter to distribute the funds in escrow to one or both parties at their discretion. If the Arbiter does not rule within 60 days, the funds will be accessible to the backers through the withdraw/reinburse function."
            ,style: TextStyle(color: Theme.of(context).indicatorColor),
            )
            ),
            Padding(
              padding: const EdgeInsets.only(top:58),
              child: SizedBox(
                height: 40,
                width: 130,
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all<Color>(Theme.of(context).indicatorColor),
                    backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).indicatorColor),
                    elevation: WidgetStateProperty.all(1.0),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                    ),
                  ),
                  onPressed: ()async{
                    Navigator.of(context).pop();
                  },
                   child: const Center(
                  child: Text("SUBMIT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:Colors.black),),
                )),
              ),
            ),
            ],
          )
    );

  }

 
}