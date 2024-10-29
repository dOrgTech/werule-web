import 'dart:typed_data';

import 'package:Homebase/screens/creator.dart';
import 'package:Homebase/screens/members.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../entities/human.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../main.dart';
import '../utils/reusable.dart';
import '../widgets/dboxes.dart';
import '../widgets/membersList.dart';
import '../widgets/proposalCard.dart';
import '../widgets/voteConcentration.dart';

Color listTitleColor=const Color.fromARGB(255, 211, 211, 211);
class Account extends StatefulWidget {
  Account({super.key, this.member, required this.org});
  int status=0;
  List<Widget>proposals=[];
  Member? member;
  Org org;
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
      
        ProposalCard p1= ProposalCard(org:orgs[0],proposal:Proposal(type: "New Project", name: "Engagement with another DAO", org:orgs[0]));
        p1.type="votedOn";
        ProposalCard p2=  ProposalCard(org:orgs[0],proposal:Proposal(type: "Transfer", name: "Title of the proposal (nax. 80 characters)", org: orgs[0]));
        p2.type="votedOn";
        p2.option=1;
        widget.proposals.addAll([p1,p2]);
        
    return 
    Human().address == null?
    notSignedin():
    !widget.org.memberAddresses.contains(Human().address!.toLowerCase())?
    notAMember():
    accountWide(context); }


Widget notSignedin(){
  return const SizedBox(height: 20,
  child: Center(child:Text("You are not signed in.", style: TextStyle(fontSize: 20, color:Colors.grey)))
  );
}

Widget notAMember(){
  return const SizedBox(height: 20,
  child: Center(child:Text("You are not a member.", style: TextStyle(fontSize: 20, color:Colors.grey)))
  );
}

 Widget accountWide(context){
    widget.member=widget.org.members.firstWhere((element) => element.address.toLowerCase()==Human().address!.toLowerCase());
        
    return ListView(
      children: [
      const  SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 29),
                SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Spacer(),
                   Padding(
                     padding: const EdgeInsets.only(left:35.0),
                     child: FutureBuilder<Uint8List>(
                          future: generateAvatarAsync(hashString(Human().address!)),  // Make your generateAvatar function return Future<Uint8List>
                          builder: (context, snapshot) {
                            // Future.delayed(Duration(milliseconds: 500));
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                    color: Theme.of(context).canvasColor,
                                ),
                                width: 50.0,
                                height:50.0,
                              );
                            } else if (snapshot.hasData) {
                              return Container(width: 50,height: 50,  
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0)
                                ),
                              child: Image.memory(snapshot.data!));
                            } else {
                              return Container(
                                width: 50.0,
                                height: 50.0,
                                color: Theme.of(context).canvasColor,  // Error color
                              );
                            }
                          },
                        ),
                   ),
                        const SizedBox(width: 10),
                        Text(Human().address!, style: const TextStyle(fontSize: 16),),
                        const Spacer(),
                        
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
                                const Text("Voting Weight" , style: TextStyle(
                                  fontSize: 16,
                                  ),),
                                const SizedBox(height: 10,),
                                 Text(widget.member!.votingWeight.toString(), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                              ],
                            ),
                            const Spacer(),
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Personal Balance" , style: TextStyle(fontSize: 16 ),),
                                const SizedBox(height: 10,),
                                Text(widget.member!.personalBalance.toString(), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                              ],
                            ),
                            const Spacer(),
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Proposals Created" , style: TextStyle(fontSize: 16 ),),
                                const SizedBox(height: 10,),
                                 Text(widget.member!.proposalsCreated.length.toString(), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                            ],
                          ),
                            const Spacer(),
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Votes Cast" , style: TextStyle(fontSize: 16 ),),
                                const SizedBox(height: 10,),
                                 Text(widget.member!.proposalsCreated.length.toString(), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
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
                  const SizedBox(height: 9),
                  const Text("You can either delegate your vote or accept delegations, but not both at the same time."),
                    ],
                  ),
                ),
                  const SizedBox(height: 9),
                  const Divider(),
                
                const SizedBox(height: 35),
           
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
                       const Text("Activity history", style: TextStyle(fontSize: 20),),
                         Container(
                      padding: const EdgeInsets.only(right: 50),
                      height: 40,
                      child: ToggleSwitch(
                initialLabelIndex: widget.status,
                totalSwitches: 2,
                minWidth: 186,
                borderWidth: 1.5,
                activeFgColor: Theme.of(context).indicatorColor,
                inactiveFgColor: const Color.fromARGB(255, 189, 189, 189),
                activeBgColor: [const Color.fromARGB(255, 77, 77, 77)],
                inactiveBgColor: Theme.of(context).cardColor,
                borderColor: [Theme.of(context).cardColor],
                labels: ['VOTING RECORD','PROPOSALS CREATED'],
                customTextStyles: [const TextStyle( fontSize: 14)],
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
                const SizedBox(height: 9),
                const Divider(),
                const SizedBox(height: 30),
                Container(
      child:  Padding(
        padding: const EdgeInsets.symmetric(horizontal:1.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:15.0),
                child: Container(
                  padding: const EdgeInsets.only(left:15  ),
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
        const SizedBox(height: 140),
      ],
    );

  }

}

