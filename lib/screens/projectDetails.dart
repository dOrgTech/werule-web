import 'package:flutter/material.dart';
import 'package:flutter_circle_chart/flutter_circle_chart.dart';
import 'package:homebase/screens/proposalDetails.dart';
import 'package:homebase/widgets/arbitrate.dart';
import 'package:homebase/widgets/dispute.dart';
import 'package:homebase/widgets/projectCard.dart';
import 'package:homebase/widgets/release.dart';
import 'package:homebase/widgets/sendfunds.dart';
import 'package:homebase/widgets/setParty.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../entities/project.dart';
import '../main.dart';
import '../widgets/menu.dart';
import '../widgets/withdraw.dart';


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
    functionItem("Send Funds to Project", "Anyone",SendFunds()),
    functionItem("Set other party", "Author", SetParty()),
    functionItem("Withdraw/Reinburse", "Author", Withdraw()),
  ];
  List<Widget> ongoingProjectFunctions=[
    functionItem("Send Funds to Project", "Anyone", SendFunds()),
    functionItem("Dispute Project", "Parties", Dispute()),
    functionItem("Release funds to contractor", "Author", Release()),
  ];
  List<Widget> disputedProjectFunctions=[
    // functionItem("Award all funds to Contractor", "Arbiter", Arbitrate(project:widget.project)),
    // functionItem("Reinburse all Project backers", "Arbiter", Arbitrate(project:widget.project)),
    functionItem("Arbitrate", "Arbiter", Arbitrate(project:widget.project)),
  ];
  List<Widget> closedProjectFunctions=[
    functionItem("Withdraw/Reinburse", "Anyone", Withdraw()),
  ];
  
  List<Widget> pendingProjectFunctions=[
    functionItem("Withdraw/Reinburse", "Author", Withdraw()),
    functionItem("Sign Contract", "Contractor", Withdraw()),
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
                     padding: const EdgeInsets.all(8.0),
                     child: Text(widget.project!.name!.toString(), 
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
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
                       SizedBox(height: 35,
                       width: 500,
                         child: Center(
                           child: Row(
                         mainAxisAlignment:   widget.project.status=="Dispute"?
                               MainAxisAlignment.spaceBetween:
                               MainAxisAlignment.end, 
                              children: [
                                Text("Created: ${DateFormat.yMMMd().format(widget.project.creationDate!)}    ",style: const TextStyle(fontSize: 13),),
                                widget.project.status=="Dispute"? Text("Expires: ${DateFormat.yMMMd().format(widget.project.expiresAt!)}",style: const TextStyle(fontSize: 13)):const Text(""),
                                StatusBox(project: widget.project)
                              ],
                            ),
                         ),
                       ),
                         SizedBox(
                      height: 35,
                       child: Center(
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Contract Address: "),
                                Text(orgs[0].address!, style: TextStyle(fontSize: 11),),
                                const SizedBox(width: 2,),
                                TextButton(
                                  onPressed: (){
                                     copied(context, "whatever");
                                  
                                  },
                                  child: const Icon(Icons.copy)),
                              ],
                            ),
                       ),
                     ),
                    SizedBox(
                      height: 35,
                       child: Center(
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Author Address: "),
                                const Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5", style: TextStyle(fontSize: 11),),
                                const SizedBox(width: 2,),
                                TextButton(
                                  onPressed: (){
                                     copied(context, "whatever");
                                  
                                  },
                                  child: const Icon(Icons.copy)),
                              ],
                            ),
                       ),
                     ),
                widget.project.status=="Ongoing" || widget.project.status=="Dispute" || widget.project.status=="Closed"  || widget.project.status=="Pending" 
                     ?
                    SizedBox(
                      height: 35,
                       child: Center(
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Other Party Address: "),
                                const Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5", style: TextStyle(fontSize: 11),),
                                const SizedBox(width: 2,),
                                TextButton(
                                  onPressed: (){
                                    copied(context, "whatever");
                                  },
                                  child: const Icon(Icons.copy)),
                              ],
                            ),
                       ),
                     ):const SizedBox(),
                      widget.project.status=="Ongoing" || widget.project.status=="Dispute" || widget.project.status=="Closed"  || widget.project.status=="Pending" 
                     ?
                      SizedBox(
                      height: 35,
                       child: Center(
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Arbiter Address: "),
                                const Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5", style: TextStyle(fontSize: 11),),
                                const SizedBox(width: 2,),
                                TextButton(
                                  onPressed: (){
                                    copied(context, "whatever");
                                  },
                                  child: const Icon(Icons.copy)),
                              ],
                            ),
                       ),
                     ):const SizedBox(),
                     SizedBox(
                      height: 35,
                       child: Center(
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                widget.project.status=="Ongoing" || widget.project.status=="Dispute" || widget.project.status=="Closed"  || widget.project.status=="Pending" 
                                        ?   
                                  "Terms of Engagement: ":"Requirements: "),
                                const Text("https://ipfs/QmNrgEMcUygbKzZe...", style: TextStyle(fontSize: 11),),
                                const SizedBox(width: 2,),
                                TextButton(
                                  onPressed: (){
                                    copied(context, "whatever");
                                  },
                                  child: const Icon(Icons.copy)),
                              ],
                          ),
                       ),
                     ),
                ],)
                ],
                ),
              ),
              const SizedBox(height: 20),
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
                               child: Text(widget.project.amountInEscrow!.toString()+".000000 USDT", style: const TextStyle(fontSize: 25, fontWeight: FontWeight.normal),),
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
                    const SizedBox(height: 40),
                   ],
                 ),
                ),
               ),
               const SizedBox(height: 40),
             const Text("Implementation:"),
               const SizedBox(height: 10),
               Container(
                alignment: Alignment.topCenter,
                constraints: const BoxConstraints(maxWidth: 1200),
               padding: const EdgeInsets.all(11),
               decoration: const BoxDecoration(color: Color(0xff121416)),child:Align(
              alignment: Alignment.topLeft,
              child: Transform(
              transform: scaleXYZTransform(scaleX: 1.3, scaleY: 1.3),
              child: Image.network("https://i.ibb.co/fDJhKkt/image.png"))))
              ]),
            ],
          )));
  }


  copied(context,text){
        ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      // The content of the SnackBar.
                                      content: Center(
                                          child: Text(
                                        'Address copied',
                                        style: TextStyle(fontSize: 15),
                                      )),
                                      // The duration of the SnackBar.
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
  }



  Widget functionItem(String title, String access, target )
          {
            return InkWell(
              onTap: () {
                showDialog(context: context, builder: (context)=>AlertDialog(
                  content: target,
                )
                );
              },
              child: Container(
                    width: 410, height:146,
                    decoration: BoxDecoration(
                      color: const Color(0x31000000),
                      border: Border.all(width: 1, color:  const Color(0x2111111))
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        SizedBox(
                          width: 360,
                          child: Center(
                            child: Text(title,
                            style: const TextStyle(fontSize: 20), 
                            textAlign: TextAlign.center,
                              ),
                          )
                        ),                   
                        const SizedBox(height: 30),
                          Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Can be called by: ",style: 
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


