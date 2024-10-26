import 'package:flutter/material.dart';

import '../widgets/dboxes.dart';
import '../widgets/membersList.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Column(
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
                  const Text("Delegation Settings", style: TextStyle(fontSize: 20),),
                  SizedBox(height: 9),
                  const Text("These settings affect your participation in both on-chain and off-chain proposals."),
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
        )
      ],
    );
  }
}


// class DelegationBoxes extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildContainer(
//             context,
//             icon: Icons.handshake,
//             title: "DELEGATE\nYOUR VOTE",
//             description:
//                 "If you cannot or don't want to take part in the governance process, your voting privilege may be forwarded to another member of your choosing, provided that they are accepting delegations. You can't delegate your vote and be accepting delegations at the same time.",
//             label: "Label 1",
//           ),
//           SizedBox(width: 40),
//           _buildContainer(
//             context,
//             icon: Icons.how_to_vote,
//             title: "VOTE\nDIRECTLY",
//             description:
//                 "This also allows other members to delegate their vote to you, so that you may participate in the governance process on their behalf. Your vote must not be delegated.",
//             label: "Label 2",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContainer(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String description,
//     required String label,
//   }) {
//     return Container(
//       width: 400,
//       height: 340,
//       decoration: BoxDecoration(
//         color: Color.fromARGB(38, 0, 0, 0),
//         border: Border.all(
//           width: 0.3,
//           color: Color.fromARGB(255, 105, 105, 105))),
//       padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      
//       child: Column(
//         children: [
//           SizedBox(height: 20),
//           // Title row with icon
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 60),
//               SizedBox(width: 4),
//               SizedBox(width: 8),
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           // Fixed space between title and description
//           Spacer(),
//           // Description text
//           Padding(
//             padding: const EdgeInsets.all(19.0),
//             child: Expanded(
//               child: Text(
//                 description,
//                 textAlign: TextAlign.justify,
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//           // Fixed space between description and label
//           Spacer(),
//           // Label at the bottom
//           Text(
//             label,
//             style: TextStyle(fontSize: 16, color: Colors.blueAccent),
//           ),
//           SizedBox(height: 5),
//         ],
//       ),
//     );
//   }
// }
