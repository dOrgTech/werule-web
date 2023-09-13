import 'package:flutter/material.dart';
import 'package:flutter_circle_chart/flutter_circle_chart.dart';
import 'package:homebase/screens/proposalDetails.dart';
import 'package:homebase/widgets/projectCard.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../entities/project.dart';
import '../widgets/menu.dart';


class ProjectDetails extends StatefulWidget {
  ProjectDetails({super.key, required this.project});
  Project project;
  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  @override
  Widget build(BuildContext context) {

 List<Widget> openProjectFunctions=[
    functionItem("Send Funds to Project", "Anyone", "sendFunds"),
    functionItem("Set other party", "Author", "setParty"),
    functionItem("Withdraw/Reinburse", "Author", "withdraw"),
  ];
  List<Widget> ongoingProjectFunctions=[
    functionItem("Send Funds to Project", "Anyone", "sendFunds"),
    functionItem("Dispute Project", "Parties", "dispute"),
    functionItem("Release funds to contractor", "Author", "re;ease"),
  ];
  List<Widget> disputedProjectFunctions=[
    functionItem("Award all funds to Contractor", "Arbiter", "awardContractor"),
    functionItem("Reinburse all Project backers", "Arbiter", "award"),
    functionItem("Split funds between Parties", "Arbiter", "sendFunds"),
  ];
  List<Widget> closedProjectFunctions=[
    functionItem("Withdraw/Reinburse", "Anyone", "withdraw"),
  ];
  
  List<Widget> pendingProjectFunctions=[
    functionItem("Withdraw/Reinburse", "Author", "withdraw"),
    functionItem("Sign Contract", "Contractor", "withdraw"),
  ];
  


return  
Scaffold(
appBar: const TopMenu(),
body:Container(
          alignment: Alignment.topCenter,
          child: ListView(
            shrinkWrap: true, // Set this property to true
            children: [
              Column( // Start of Column
                crossAxisAlignment: CrossAxisAlignment.center, // Set this property to center the items horizontally
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its children's size vertically
                children: [
                  
              Container(
                 constraints: const BoxConstraints(maxWidth: 1200),
                height: 240,
                 color:Theme.of(context).cardColor,
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  // SizedBox(height: 40),
                    Padding(
                     padding: EdgeInsets.all(8.0),
                     child: Text(widget.project!.name!.toString(), 
                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                        ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                       SizedBox(height: 40,
                       width: 500,
                         child: Center(
                           child: Row(
                         mainAxisAlignment:   widget.project.status=="Dispute"?
                               MainAxisAlignment.spaceBetween:
                               MainAxisAlignment.end, 
                              children: [
                                Text("Created: ${DateFormat.yMMMd().format(widget.project.creationDate!)}    ",style: const TextStyle(fontSize: 13),),
                                widget.project.status=="Dispute"? Text("Expires: ${DateFormat.yMMMd().format(widget.project.expiresAt!)}",style: TextStyle(fontSize: 13)):Text(""),
                                StatusBox(project: widget.project)
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
                                Text("Author Address: "),
                                Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5", style: TextStyle(fontSize: 11),),
                                const SizedBox(width: 2,),
                                TextButton(
                                  onPressed: (){},
                                  child: const Icon(Icons.copy)),
                              ],
                            ),
                       ),
                     ),
                widget.project.status=="Ongoing" || widget.project.status=="Dispute" || widget.project.status=="Closed"  || widget.project.status=="Pending" 
                     ?
                    SizedBox(
                      height: 40,
                       child: Center(
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Other Party Address: "),
                                Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5", style: TextStyle(fontSize: 11),),
                                const SizedBox(width: 2,),
                                TextButton(
                                  onPressed: (){},
                                  child: const Icon(Icons.copy)),
                              ],
                            ),
                       ),
                     ):SizedBox(),
                      widget.project.status=="Ongoing" || widget.project.status=="Dispute" || widget.project.status=="Closed"  || widget.project.status=="Pending" 
                     ?
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
                     ):SizedBox(),
                     SizedBox(
                      height: 40,
                       child: Center(
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                widget.project.status=="Ongoing" || widget.project.status=="Dispute" || widget.project.status=="Closed"  || widget.project.status=="Pending" 
                     ?   
                                  "Terms of Engagement: ":"Requirements: "),
                                Text("https://ipfs/QmNrgEMcUygbKzZe...", style: TextStyle(fontSize: 11),),
                                const SizedBox(width: 2,),
                                TextButton(
                                  onPressed: (){},
                                  child: const Icon(Icons.copy)),
                              ],
                          ),
                       ),
                     ),
                ],)
                ],
                ),
              ),
              SizedBox(height: 20),
               Container(
                 alignment: Alignment.topCenter,
               width: double.infinity,
                 constraints: const BoxConstraints(
                   maxWidth: 1200,
                 ),
                 child:Card(
                   
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     Container(
                         width: 1200,
                         padding: const EdgeInsets.all(18.0),
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                           children: [
                             Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Padding(
                                 padding: const EdgeInsets.only(left:28.0),
                                 child: Text(
                                  widget.project.status=="Pending"||widget.project.status=="Pending"?
                                  "Funds in Contract":"Funds in Escrow", style: TextStyle(fontSize: 17, 
                                 color: Theme.of(context).indicatorColor,
                                 fontWeight: FontWeight.normal),),
                               ),
                             const SizedBox(height: 8,),
                               Padding( 
                               padding: const EdgeInsets.only(left:28.0),
                               child: Text(widget.project.amountInEscrow!.toString()+".000000 USDT", style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),),
                             ),
                               ],
                             ),
                             
                           Padding(
                             padding: const EdgeInsets.only(left:18.0),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                               children: [
                                 TextButton(
                                   onPressed: (){},
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     children: [
                                       const Text("32", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                                       const SizedBox(width: 10,),
                                       Text("Backers" , style: TextStyle(color: Theme.of(context).indicatorColor ),),
                                     ],
                                   ),
                                 ),
                                 const SizedBox(width: 70,),
                                   TextButton(
                                   onPressed: (){}, child:Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     children: [
                                       const Text("4", style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
                                       const SizedBox(width: 10,),
                                       Text("Asset Types" , style: TextStyle(color: Theme.of(context).indicatorColor ),),
                                     ],
                                                                 ),
                                   )
                               ],
                             ),
                           )
                           ],
                         ),
                       ),
                       
                         const Padding(
                           padding: EdgeInsets.symmetric(horizontal:28.0),
                           child: Opacity(
                             opacity: 0.1,
                             child: Divider(
                               thickness: 6,
                               height: 18,)),
                         ),
                         const SizedBox(height: 37,),
                          Wrap(
                           runAlignment: WrapAlignment.center,
                           spacing: 40,
                           runSpacing: 40,
                           children:
                           widget.project!.status=="Ongoing"?
                           ongoingProjectFunctions:
                           widget.project!.status=="Open"?
                           openProjectFunctions:
                           widget.project!.status=="Closed"?
                           closedProjectFunctions:
                           widget.project!.status=="Pending"?
                           pendingProjectFunctions:
                           disputedProjectFunctions  
                         ),
                    SizedBox(height: 40),
                   ],
                 ),
                ),
               ),
               SizedBox(height: 40),
             Text("Implementation:"),
               SizedBox(height: 10),
               Container(
                alignment: Alignment.topCenter,
                constraints: const BoxConstraints(maxWidth: 1200),
               padding: EdgeInsets.all(11),
               decoration: BoxDecoration(color: Color(0xff121416)),child:Align(
              alignment: Alignment.topLeft,
              child: Transform(
              transform: scaleXYZTransform(scaleX: 1.3, scaleY: 1.3),
              child: Image.network("https://i.ibb.co/fDJhKkt/image.png"))))
              ]),
            ],
          )));
  }

  Widget functionItem(String title, String access, target )
          {
            return InkWell(
              onTap: () {
                print("TAP on card "+target!.toString());
              },
              child: Container(
                    width: 410, height:146,
                    decoration: BoxDecoration(
                      color: Color(0x31000000),
                      border: Border.all(width: 1, color:  Color(0x2111111))
                    ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        SizedBox(
                          width: 360,
                          child: Center(
                            child: Text(title,
                            style: TextStyle(fontSize: 20), 
                            textAlign: TextAlign.center,
                              ),
                          )
                        ),                   
                        SizedBox(height: 30),
                          Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Can be called by: ",style: 
                              TextStyle(
                                fontSize: 13,)),
                              Text(access, style: 
                              TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).indicatorColor)
                              ,),
                            ],
                          )
                      ],
                    ),
                  ),
    );
    
  }

 

}


