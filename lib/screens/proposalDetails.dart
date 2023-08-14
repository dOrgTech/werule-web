import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../widgets/menu.dart';

class ProposalDetails extends StatefulWidget {
  const ProposalDetails({super.key});

  @override
  State<ProposalDetails> createState() => _ProposalDetailsState();
}

class _ProposalDetailsState extends State<ProposalDetails> {
  @override
  Widget build(BuildContext context) {
    return  Container(
          alignment: Alignment.topCenter,
          child: ListView( // Start of ListView
            shrinkWrap: true, // Set this property to true
            children: [
              Column( // Start of Column
                crossAxisAlignment: CrossAxisAlignment.center, // Set this property to center the items horizontally
                mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its children's size vertically
                children: [
                   const SizedBox(height: 20,),
          Container(
            height: 240,
             color:Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                        SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Engagement with another DAO", 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                          
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                             side: BorderSide(width: 0.2, color: Theme.of(context).hintColor),
                            ),
                            onPressed: (){}, child: const Text("Drop Proposal", style: TextStyle(fontSize: 12))),
                        )
                      ],
                    ),
                       Opacity(
                        opacity: 0.7,
                         child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15.0)),
                            color: Colors.teal,
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal:18.0),
                            child: Text("ACTIVE"),
                          )
                         ),
                       ), 
                          const SizedBox(width: 129),
                       Container(
                      constraints: const BoxConstraints(
                        maxWidth: 450,
                      ),
                      padding: const EdgeInsets.all(18.0),
                      child: const Text(
                        "This is the description of the Project. Doesn't need to be super long cause we also link the Terms (on the right) and that should contain all the details needed for executing the task and making a judgement on the state of the project.",
                        
                        textAlign: TextAlign.center,
                        ),
                    ),
                  ],
                ),
             
                Padding(
                  padding: const EdgeInsets.only(top:35.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    
                    children: [
                      
                      SizedBox(
                        height: 40,
                         child: Center(
                           child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Posted By: "),
                                  Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5", style: TextStyle(fontSize: 11),),
                                  const SizedBox(width: 2,),
                                  TextButton(
                                    onPressed: (){},
                                    child: const Icon(Icons.copy)),
                                ],
                              ),
                         ),
                       ),
                      SizedBox(
                        height: 40,
                         child: Center(
                           child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Client Address: "),
                                  Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5", style: TextStyle(fontSize: 11),),
                                  const SizedBox(width: 2,),
                                  TextButton(
                                    onPressed: (){},
                                    child: const Icon(Icons.copy)),
                                ],
                              ),
                         ),
                       ),
                        SizedBox(
                        height: 40,
                         child: Center(
                           child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Arbiter Address: "),
                                  Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5", style: TextStyle(fontSize: 11),),
                                  const SizedBox(width: 2,),
                                  TextButton(
                                    onPressed: (){},
                                    child: const Icon(Icons.copy)),
                                ],
                              ),
                         ),
                       ),
                       SizedBox(
                        height: 40,
                         child: Center(
                           child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Terms of Engagement: "),
                                  Text("https://ipfs/QmNrgEMcUygbKzZe...", style: TextStyle(fontSize: 11),),
                                  const SizedBox(width: 2,),
                                  TextButton(
                                    onPressed: (){},
                                    child: const Icon(Icons.copy)),
                                ],
                              ),
                         ),
                       ),
                   
                  ],),
                )
              ],
            ),
          ),
          SizedBox(height: 20),
           Row(
            children: [
              
                Container(
                  height: 280,
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                    ),
                    child:Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(19.0),
                            child: Padding(
                              padding: EdgeInsets.only(left:28.0),
                              child: Text("Current Cycle: 5411", style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),),
                            ),
                          ),
                          const SizedBox(height: 15,),
                          Padding(
                            padding: const EdgeInsets.only(left:38.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.donut_large_rounded, size: 50,),
                                const SizedBox(width: 10,),
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text("Creating Proposals" , style: TextStyle(
                                    color: Theme.of(context).indicatorColor,
                                    fontSize: 16, fontWeight: FontWeight.normal),),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24,),
                          Padding(
                            padding: const EdgeInsets.only(left:38.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.hourglass_bottom, size: 50,),
                              Column(
                                  children: [
                                    Text("Time left in cycle" , style: TextStyle(
                                      color: Theme.of(context).indicatorColor,
                                      fontSize: 17, fontWeight: FontWeight.normal),),
                                    const SizedBox(height: 10,),
                                    const Padding(
                                      padding: EdgeInsets.only(left:28.0),
                                      child: Text("0d 12h 24m (2979 blocks)" , style: TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.normal),),
                                    ),
                                    
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                 Container(
                  height: 280,
                    constraints: const BoxConstraints(
                      maxWidth: 680,
                    ),
                    child:Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top:19,left:28.0),
                              child: Text("CRRDAO Locked", style: TextStyle(fontSize: 17, 
                              color: Theme.of(context).indicatorColor,
                              fontWeight: FontWeight.normal),),
                            ),
                          
                          const SizedBox(height: 15,),
                        const  Padding(
                            padding: const EdgeInsets.only(left:28.0),
                            child: Text("10513.46218086", style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),),
                          ),
                          const SizedBox(height: 21,),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal:28.0),
                            child: Opacity(
                              opacity: 0.1,
                              child: Divider(
                                thickness: 6,
                                height: 18,)),
                          ),
                          const SizedBox(height: 37,),
                        Padding(
                          padding: const EdgeInsets.only(left:38.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Voting Addresses" , style: TextStyle(color: Theme.of(context).indicatorColor ),),
                                  const SizedBox(height: 10,),
                                  const Text("32", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                                ],
                              ),
                              const SizedBox(width: 70,),
                                Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Active Proposals" , style: TextStyle(color: Theme.of(context).indicatorColor ),),
                                  const SizedBox(height: 10,),
                                  const Text("0", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                                ],
                              )
                            ],
                          ),
                        )
                        ],
                      ),
                    ),
                  ),
                ),
               
            ],
           )              
                  
                  ])
                      
              ]));
  }
}