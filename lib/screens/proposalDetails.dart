import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_circle_chart/flutter_circle_chart.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'dart:math';
import 'dart:math' as math;
import '../widgets/menu.dart';
import 'dao.dart';

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
          child: Column( // Start of Column
            crossAxisAlignment: CrossAxisAlignment.center, // Set this property to center the items horizontally
            mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its chilWSdren's size vertically
            children: [
              SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Text("< Back to all proposals"))),
  //              Align(
                
  //               alignment: Alignment.topLeft,
  //               child: TextButton(onPressed: (){
  //                   Navigator.push(
  // context,
  // MaterialPageRoute(builder: (context) =>DAO(InitialTabIndex: 1))
  // ) ;
  //               }, child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Icon(Icons.arrow_back, color: Theme.of(context).indicatorColor,),
  //                   Text("All proposals", style: TextStyle(color:Theme.of(context).indicatorColor,),),
  //                 ],
  //               ))),
               const SizedBox(height: 10,),
          Container(
            height: 240,
             color:Theme.of(context).cardColor,
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  const SizedBox(height: 4),
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
                      child: ElevatedButton(
                        style: TextButton.styleFrom(
                         side: BorderSide(width: 0.2, color: Theme.of(context).hintColor),
                        ),
                        onPressed: (){}, child: const Text("Drop Proposal", style: TextStyle(fontSize: 12))),
                    )
                  ],
                ),
                   Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(color:Colors.black12,
                    border: Border.all(width: 0.5, color:Colors.white12)
                    ),
                     child: Row(
                       children: [
                        SizedBox(width: 10),
                       const  Text("New Project proposal"),
                       const SizedBox(width: 20),
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
                              child: Text("ACTIVE", style: TextStyle(color:Colors.black),),
                            )
                           ),
                         ),
                        SizedBox(width: 10),
                       ],
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
                crossAxisAlignment: CrossAxisAlignment.end,
                
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
                      const SizedBox(height: 24,),
                      Padding(
                        padding: const EdgeInsets.only(left:48.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.hourglass_bottom, size: 50,),
                          Column(
                              children: [
                                Text("Time left to vote" , style: TextStyle(
                                  color: Theme.of(context).indicatorColor,
                                  fontSize: 17, fontWeight: FontWeight.normal),),
                                const SizedBox(height: 10,),
                                const Padding(
                                  padding: EdgeInsets.only(left:28.0),
                                  child: Text("0d 11h 19m (2137 blocks)" , style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.normal),),
                                ),
                                
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 70),
                      Padding(
                        padding: const EdgeInsets.only(left:48.0),
                        child: SizedBox(
                          width: 360,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            ElevatedButton(
                              style: const ButtonStyle(
                                elevation:MaterialStatePropertyAll(0.0),
                                backgroundColor: MaterialStatePropertyAll(Colors.teal)),
                              onPressed: (){}, child: const SizedBox(width:120, height:40,child: Center(child: Text("Support")))),
                           Spacer(),
                            ElevatedButton(onPressed: (){}, 
                             style: const ButtonStyle(
                                elevation:MaterialStatePropertyAll(0.0),
                                backgroundColor: MaterialStatePropertyAll(Colors.redAccent)),
                            
                            child: const SizedBox(width:120, height:40,child: Center(child: Text("Oppose"))))
                          ],),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
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
                          child: Row(
                            children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: Text("12 Votes", style: TextStyle(fontSize: 17, 
                                  color: Theme.of(context).indicatorColor,
                                  fontWeight: FontWeight.normal),),
                                ),
                              const SizedBox(width: 32),
                              ElevatedButton(onPressed: (){}, child: Text("View"))
                            ],
                          ),
                        ),
                      const SizedBox(height: 25,),
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal:8.0),
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                           children: const [

                            SizedBox(width: 34),
                            Icon(Icons.circle,color: Colors.teal),
                            SizedBox(width: 10),
                              SizedBox(
                                    child:Text("Support",
                                    style: TextStyle(fontWeight: FontWeight.bold),)),
                                 SizedBox(width: 13),
                                Text("14305000 (49.41%)"),
                                Spacer(),
                                Icon(Icons.circle, color: Colors.redAccent,),
                                SizedBox(width: 10),
                              SizedBox(
                                    child:Text("Oppose",
                                    style: TextStyle(fontWeight: FontWeight.bold),)),
                                 SizedBox(width: 13),
                                Text("14781100 (51.59%)"),
                                 SizedBox(width: 73)
                           ],
                         ),
                       ),
                   const SizedBox(height: 13),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal:28.0),
                     child: SizedBox(height: 10,width: double.infinity,
                     child:SfSparkWinLossChart(
                       firstPointColor: Colors.teal,
                       lastPointColor: Colors.redAccent,
                       data: const [43.0,13.0],
                     )
                    ),
                   ),
                 SizedBox(height: 13),
                Padding(
                  padding: const EdgeInsets.only(left:18.0),
                  child: CircleChart(
                    chartRadius: 40,
                    borderRadius: Radius.circular(4),
                    chartCircleBackgroundStrokeWidth: 9,
                    chartStrokeWidth: 1,
                    padding: EdgeInsets.all(9),
                    duration: Duration(seconds: 1),
                    backgroundColor: Theme.of(context).cardColor,
                    chartType: CircleChartType.values[1],
                    items: List.generate(
                      1,
                      (index) => CircleChartItemData(
                        color: Theme.of(context).indicatorColor,
                        value: 100.00,
                        name: 'Quorum threshold achieved',
                        description:
                            '',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
            ),
           ) ]),
           SizedBox(height: 60),
           Align(
            alignment: Alignment.topLeft,
            
              child: Padding(
                padding: const EdgeInsets.only(left:18.0),
                child: Text("Implementation:"),
              )),
           SizedBox(height: 12),
           Container(
             height:352,
           width: double.infinity,
           padding: EdgeInsets.all(11),
           decoration: BoxDecoration(color: Color(0xff121416)),child:Align(
          alignment: Alignment.topLeft,
          child: Transform(
  transform: scaleXYZTransform(scaleX: 1.3, scaleY: 1.3),
  child: Image.network("https://i.ibb.co/fDJhKkt/image.png"))))
          ]));
  }
}

Color randomColor() {
  var g = math.Random.secure().nextInt(255);
  var b = math.Random.secure().nextInt(255);
  var r = math.Random.secure().nextInt(255);
  return Color.fromARGB(255, r, g, b);
}


Matrix4 scaleXYZTransform({
  double scaleX = 1.00,
  double scaleY = 1.00,
  double scaleZ = 1.00,
}) {
  return Matrix4.diagonal3Values(scaleX, scaleY, scaleZ);
}