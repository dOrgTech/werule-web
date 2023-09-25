import 'package:flutter/material.dart';

import '../entities/org.dart';
import '../entities/token.dart';
import '../main.dart';


class FundProject extends StatefulWidget {
   FundProject({super.key, required this.org});
  Org org;
  @override
  State<FundProject> createState() => _FundProjectState();
}
  String? selectedToken;  String? selectedAddress;String amount = "";
class _FundProjectState extends State<FundProject> {
  @override
  Widget build(BuildContext context) {
       List<String> paymentTokens = [];
         for (Token t in tokens) {
      paymentTokens.add(t.symbol + " (" + t.name + ")");
    }
    return Container(
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
          
            SizedBox(width: 380,
            child:TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Project Contract Address',
              ),
            ),
            
            ),

                  Row(
                    children: [
                      DropdownButton<String>(
                          hint: Text("Select accepted token "),
                          value: selectedToken,
                          items: paymentTokens.asMap().entries.map((entry) {
                            int idx = entry.key;
                            String value = entry.value;

                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: idx == 0
                                      ? Theme.of(context).indicatorColor
                                      : Colors.white, // First item will be green
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedToken = newValue;
                             
                              amount = "";
                              selectedAddress = tokens
                                  .firstWhere((token) =>
                                      token.symbol + " (" + token.name + ")" ==
                                      newValue)
                                  .address;
                            });
                          },
                        ),
                        SizedBox(width: 20,),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Amount',
                            ),
                            onChanged: (value) {
                              setState(() {
                                amount = value;
                              });
                            },
                          ),
                        ),
                       
                    ],
                  ),
                   SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: SizedBox(
                height: 40,
                width: 130,
                child: TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).indicatorColor),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).indicatorColor),
                      elevation: MaterialStateProperty.all(1.0),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Center(
                      child: Text(
                        "SUBMIT",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    )),
              ),
            ),
            ],
          ),
        );
  }
}