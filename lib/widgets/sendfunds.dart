

import 'dart:isolate';
import 'dart:html' as html;
import 'package:beamer/beamer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homebase/entities/token.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';  // Import this for TextInputFormatter

import '../entities/project.dart';
const String escape = '\uE00C';

class SendFunds extends StatefulWidget {
bool loading=false;
bool done=false;
bool error=false;
Project project=Project();

// ignore: use_key_in_widget_constructors
SendFunds() ;

  @override
  SendFundsState createState() => SendFundsState();
}
int pmttoken=0;
class SendFundsState extends State<SendFunds> {
  String? selectedToken;
  String? selectedAddress;
  TextEditingController amountController = TextEditingController();
  String amount="";
  @override
  Widget build(BuildContext context) {
    
    List<String> paymentTokens=[];
    for (Token t in widget.project.acceptedTokens!){
      paymentTokens.add(t.symbol +" ("+t.name+")");}
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
          const  Text("Fund Project",
            textAlign: TextAlign.center,
             style: TextStyle(fontSize: 19), 
              ),
           Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color:Colors.black38,
            ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String> (
                   hint: Text("Select accepted token "),
                   value:selectedToken,
                   items: paymentTokens.asMap().entries.map((entry) {
  int idx = entry.key;
  String value = entry.value;

  return DropdownMenuItem<String>(
    value: value,
    child: Text(
      value,
      style: TextStyle(
        color: idx == 0 ? Theme.of(context).indicatorColor: Colors.white, // First item will be green
          ),
        ),
      );
    }).toList(),
             onChanged: (String? newValue) {
              setState(() {
                selectedToken = newValue;
                amountController.text = "";
                amount="";
                  selectedAddress = widget.project.acceptedTokens!.firstWhere(
                        (token) => token.symbol + " (" + token.name + ")" == newValue
                      ).address;
                  });
                      },
                    ),
                 const SizedBox(height: 33),
                   if (selectedToken != null && paymentTokens.indexOf(selectedToken!) != 0)
      SizedBox(
        width: 400,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$selectedAddress", style: TextStyle(fontSize: 14),),
            const SizedBox(width: 14,),
            TextButton(onPressed: (){
              ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    // The content of the SnackBar.
    content: Center(child: Text('Address copied',style: TextStyle(fontSize: 15),)),
    // The duration of the SnackBar.
    duration: Duration(seconds: 2),
    // The action to perform when the user taps on the SnackBar.
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        // Some code to execute.
      },
    ),
  ),
);
              
              
            }, child: const Icon(Icons.copy))
          ],
        ),
      ),
                  
                ],                
              )
           ),
          //  const SizedBox(height: 90),
           if (selectedToken != null) // Only display if a token is selected
      SizedBox(
        width: 200,
        child: TextField(
          controller: amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
  ],
          onChanged: (value) {
            amount=value;
          },
          decoration: InputDecoration(
            labelText: 'Enter amount',
          ),
        ),
      ),

            Padding(
              padding: const EdgeInsets.only(top:58),
              child: SizedBox(
                height: 40,
                width: 130,
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(Theme.of(context).indicatorColor),
                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).indicatorColor),
                    elevation: MaterialStateProperty.all(1.0),
                    shape: MaterialStateProperty.all(
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