import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../entities/proposal.dart';
import '../main.dart';
import '../widgets/dboxes.dart';
import '../widgets/membersList.dart';
import '../widgets/proposalCard.dart';
Color listTitleColor=Color.fromARGB(255, 211, 211, 211);
class Account extends StatefulWidget {
  Account({super.key});
  int status=0;
  List<Widget>proposals=[];
  
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
        ProposalCard p1= ProposalCard(org:orgs[0],proposal:new Proposal(type: "New Project", name: "Engagement with another DAO", org:orgs[0]));
        p1.type="votedOn";
        ProposalCard p2=  ProposalCard(org:orgs[0],proposal:new Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)", org: orgs[0]));
        p2.type="votedOn";
        p2.option=1;
        widget.proposals.addAll([p1,p2]);
        
    return ListView(
      children: [
      const  SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 29),
                SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Padding(
                     padding: const EdgeInsets.only(left:35.0),
                     child: SizedBox(height: 36,
                       child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(add1, )),
                     ),
                   ),
                        SizedBox(width: 10),
                        Text("tz1UVpbXS6pAtwPSQdQjPyPoGmVkCsNwn1K5", style: TextStyle(fontSize: 16),),
                        Spacer(),
                        
                  ],
                )
              ),
             const SizedBox(height:10),
              Padding(
                padding: const EdgeInsets.only(left:40,right:40,top:25,bottom:25),
                child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Voting Weight" , style: TextStyle(
                                  fontSize: 16,
                                  ),),
                                const SizedBox(height: 10,),
                                const Text("320000", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                              ],
                            ),
                            Spacer(),
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Personal Balance" , style: TextStyle(fontSize: 16 ),),
                                const SizedBox(height: 10,),
                                const Text("0", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                              ],
                            ),
                            Spacer(),
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Proposals Created" , style: TextStyle(fontSize: 16 ),),
                                const SizedBox(height: 10,),
                                const Text("5", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                            ],
                          ),
                            Spacer(),
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Votes Cast" , style: TextStyle(fontSize: 16 ),),
                                const SizedBox(height: 10,),
                                const Text("35", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                            ],
                          ),
                          const SizedBox(width: 20)
                        ],
                      ),
                  ),
              ],
            ),
          ),
        ),
       const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(38.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text("Delegation settings", style: TextStyle(fontSize: 20),),
                  SizedBox(height: 9),
                  const Text("You can either delegate your vote or accept delegations, but not both at the same time."),
                    ],
                  ),
                ),
                  SizedBox(height: 9),
                  Divider(),
                
                SizedBox(height: 35),
           
                DelegationBoxes()
              ],
            ),
          ),
        ),
          const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(38.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text("Activity history", style: TextStyle(fontSize: 20),),
                         Container(
                      padding: EdgeInsets.only(right: 50),
                      height: 40,
                      child: ToggleSwitch(
                initialLabelIndex: widget.status,
                totalSwitches: 2,
                minWidth: 186,
                borderWidth: 1.5,
                activeFgColor: Theme.of(context).indicatorColor,
                inactiveFgColor: Color.fromARGB(255, 189, 189, 189),
                activeBgColor: [Color.fromARGB(255, 77, 77, 77)],
                inactiveBgColor: Theme.of(context).cardColor,
                borderColor: [Theme.of(context).cardColor],
                labels: ['VOTING RECORD','PROPOSALS CREATED'],
                customTextStyles: [TextStyle( fontSize: 14)],
                onToggle: (index) {
                  print('switched to: $index');
            setState(() {
              widget.status=index!;
            });
              },
            ) 
            ),
                     ],
                   ),
                  
                    ],
                  ),
                ),
                SizedBox(height: 9),
                Divider(),
                SizedBox(height: 30),
                Container(
      child:  Padding(
        padding: const EdgeInsets.symmetric(horizontal:1.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:15.0),
                child: Container(
                  padding: EdgeInsets.only(left:15  ),
                  width: 90,
                  child: Text("ID #", style: TextStyle(color:listTitleColor),)),
              ),
              Expanded(
                child: Container(
                  width:230, child: Padding(
                    padding: const EdgeInsets.only(left:48.0),
                    child: Text("Title", style: TextStyle(color:listTitleColor),),
                  )),
              ),
              Container(
                width: 180,
                child: Center(child: Text("Voted    ", style: TextStyle(color:listTitleColor),))),
              SizedBox(width:150,child: Center(child: Text("Posted", style: TextStyle(color:listTitleColor),))),
              SizedBox(width: 150, child: Center(child: Text("Type ", style: TextStyle(color:listTitleColor),))),
              SizedBox(width:100, child: Center(child: Text("Status ", style: TextStyle(color:listTitleColor),))),
            ],
          ),
      ),
    ), 
       ...widget.proposals
              ],
            ),
          ),
        ),
        SizedBox(height: 140),
      ],
    );
  }
}

