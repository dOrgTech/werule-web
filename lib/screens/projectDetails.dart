import 'package:flutter/material.dart';
import 'package:flutter_circle_chart/flutter_circle_chart.dart';
import 'package:homebase/screens/proposalDetails.dart';
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
                mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its children's size vertically
                children: [
                   const SizedBox(height: 20,),
              Container(
                 constraints: const BoxConstraints(maxWidth: 1200),
                height: 240,
                 color:Theme.of(context).cardColor,
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                        SizedBox(height: 40),
              
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(widget.project!.name!.toString(), 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                          
                        ),
                        const SizedBox(width: 10),
                       Opacity(
                              opacity: 0.7,
                               child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  color:Theme.of(context).indicatorColor,
                                ),
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(3),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal:2.0),
                                  child: Text("ONGOING", style: TextStyle(color:Colors.black),),
                                )
                               ),
                             ),
                      ],
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
                Padding(
                  padding: const EdgeInsets.only(top:35.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    
                    children: [
                      
                      SizedBox(
                        height: 40,
                         child: Center(
                           child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("DAO Address: "),
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
                                 child: Text("Funds in Escrow", style: TextStyle(fontSize: 17, 
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
                         widget.project!.status=="Ongoing"?   Wrap(
                           runAlignment: WrapAlignment.center,
                           spacing: 40,
                           runSpacing: 40,
                           children: [
                             TextButton(
                               onPressed: (){},
                               child: Container(
                                 width: 410,
                                 height:146,
                               decoration: BoxDecoration(
                                 color: Color(0x31000000),
                                 border: Border.all(width: 1, color:  Color(0x2111111))
                               ),
                               padding: EdgeInsets.all(50),
                               child: Column(
                                 children: [
                                   SizedBox(
                                     width: 390,
                                     child: const  Text("Release funds to DAO (client only)",
                                     style: TextStyle(fontSize: 19), 
                                       ),
                                   ),
                                  
                                
                                 ],
                               ),
                                                         ),
                             ),
                          TextButton(
                               onPressed: (){},
                             child: Container(
                               width: 410, height:146,
                               decoration: BoxDecoration(
                                 color: Color(0x31000000),
                                 border: Border.all(width: 1, color:  Color(0x2111111))
                               ),
                               padding: EdgeInsets.all(50),
                               child: Column(
                                 children: [
                                   SizedBox(
                                     width: 360,
                                     child: Center(
                                       child: const  Text("Send funds into escrow",
                                       style: TextStyle(fontSize: 19), 
                                         ),
                                     ),
                                   ),
                                  
                                  
                                 ],
                               ),
                             ),
                           ),
                              TextButton(
                               onPressed: (){},
                             child: Container(
                               width: 410, height:146,
                               decoration: BoxDecoration(
                                 color: Color(0x31000000),
                                 border: Border.all(width: 1, color:  Color(0x2111111))
                               ),
                               padding: EdgeInsets.all(50),
                               child: Column(
                                 children: [
                                   SizedBox(
                                     width: 360,
                                     child: Center(
                                       child: const  Text("Throw project into arbitration (client only)",
                                       style: TextStyle(fontSize: 19), 
                                         ),
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ),
                           
                           ],
                         ):
                          Wrap(
                           runAlignment: WrapAlignment.center,
                           spacing: 40,
                           runSpacing: 40,
                           children: [
                             TextButton(
                               onPressed: (){},
                               child: Container(
                                 width: 410,
                                 height:146,
                               decoration: BoxDecoration(
                                 color: Color(0x31000000),
                                 border: Border.all(width: 1, color:  Color(0x2111111))
                               ),
                               padding: EdgeInsets.all(50),
                               child: Column(
                                 children: [
                                   SizedBox(
                                     width: 390,
                                     child: const  Text("Release funds to DAO (arbiter only)",
                                     style: TextStyle(fontSize: 19), 
                                       ),
                                   ),
                                  
                                
                                 ],
                               ),
                                                         ),
                             ),
                          TextButton(
                               onPressed: (){},
                             child: Container(
                               width: 410, height:146,
                               decoration: BoxDecoration(
                                 color: Color(0x31000000),
                                 border: Border.all(width: 1, color:  Color(0x2111111))
                               ),
                               padding: EdgeInsets.all(50),
                               child: Column(
                                 children: [
                                   SizedBox(
                                     width: 360,
                                     child: Center(
                                       child: const  Text("Return funds to senders (arbiter only)",
                                       style: TextStyle(fontSize: 19), 
                                         ),
                                     ),
                                   ),
                                  
                                  
                                 ],
                               ),
                             ),
                           ),
                           
                           
                           ],
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
}
