import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:homebase/widgets/membersList.dart';
import 'dart:math';
import '../entities/org.dart';

class Home extends StatefulWidget {
  Home({super.key, required this.org});
  Org org;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(
     
      
      child:ListView(
        children: [
          const SizedBox(height: 20,),
          Container(
            height: 180,
             color:Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Padding(
                          padding: EdgeInsets.all(18.0),
                          child: Text(widget.org.name, 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                          
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                             side: BorderSide(width: 0.2, color: Theme.of(context).hintColor),
                            ),
                            onPressed: (){}, child: const Text("View Config", style: TextStyle(fontSize: 12))),
                        )
                      ],
                    ),
                     SizedBox(
                      height: 40,
                       child: Center(
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Contract Address: "),
                                Text(widget.org.address!, style: TextStyle(fontSize: 11),),
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
                                Text("Governance Token Address: "),
                                Text(widget.org.token.address, style: TextStyle(fontSize: 11),),
                                const SizedBox(width: 2,),
                                TextButton(
                                  onPressed: (){},
                                  child: const Icon(Icons.copy)),
                              ],
                            ),
                       ),
                     ),
                    
                  ],
                ),
                Container(
                      constraints: const BoxConstraints(
                        maxWidth: 450,
                      ),
                      padding: const EdgeInsets.all(11.0),
                      child: Text(
                          widget.org.description!
                        ,
                        
                        textAlign: TextAlign.center,
                        ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 20,),
            Wrap(
              spacing: 20,
              runSpacing: 20,
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
                          Padding(
                            padding: const EdgeInsets.only(top:19,left:28.0),
                            child: Text(widget.org.token.symbol+ " Locked", style: TextStyle(fontSize: 17, 
                            color: Theme.of(context).indicatorColor,
                            fontWeight: FontWeight.normal),),
                            ),
                          
                          const SizedBox(height: 15,),
                        Padding(
                              padding: const EdgeInsets.only(left:28.0),
                              child: Text(
                                '${(300 + Random().nextDouble() * (300000 - 300)).toStringAsFixed(4)}',
                                style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
                              ),
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
                                  Text(widget.org.holders.toString(), style: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),),
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
               
              ]),
              const SizedBox(height: 44),
       
         
       
        ],
        
      )
    );
  }
}