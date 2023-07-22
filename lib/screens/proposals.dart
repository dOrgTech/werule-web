

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:homebase/utils/theme.dart';
import 'package:homebase/widgets/proposalCard.dart';

class Proposals extends StatefulWidget {
  const Proposals({super.key});

  @override
  State<Proposals> createState() => _ProposalsState();
}

class _ProposalsState extends State<Proposals> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 50),
                  width: 500,
                  child: TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(width: 0.1),
                          ),
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search by Title or Author',
                        // other properties
                      ),
                      // other properties
                    ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 50),
                  height: 40,
                  child: ElevatedButton(
                    child: Text("Create Proposal",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).indicatorColor)),
                    onPressed: (){}, ),
                ),
              ],
            )
          ),
          SizedBox(height: 40),
          Container(
      child:  Padding(
        padding: const EdgeInsets.symmetric(horizontal:8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:15.0),
                child: Container(
                  padding: EdgeInsets.only(left:15  ),
                  width: 90,
                  child: Text("ID #")),
              ),
              Expanded(
                child: Container(
                  width:230, child: Padding(
                    padding: const EdgeInsets.only(left:48.0),
                    child: Text("Title"),
                  )),
              ),
              Container(
                
                width: 230,
                child: Center(child: Text("Author"))),
              SizedBox(width:150,child: Center(child: Text("Posted"))),
              SizedBox(width: 150, child: Center(child: Text("Type "))),
              SizedBox(width:100, child: Center(child: Text("Status "))),
            ],
          ),
      ),
    ),
        
        ProposalCard(),
        ProposalCard()
        ],
      ),
    );
  }
}