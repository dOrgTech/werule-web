import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../utils/functions.dart';
import 'package:intl/intl.dart';
import '../entities/human.dart';
import 'membersList.dart';

class UserCard extends StatelessWidget {
   UserCard({super.key, required this.human});
  Human human;

  @override
  Widget build(BuildContext context) {
    return 
      Card(
        child: Row(
           children: <Widget>[
              Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child:  Padding(
                  padding: const EdgeInsets.only(top:8.0,left:25,bottom:8),
                  child: Row(
                    children: [
                      // FutureBuilder<Uint8List>(
                      //         future: generateAvatarAsync(hashString(human.address!)),  // Make your generateAvatar function return Future<Uint8List>
                      //         builder: (context, snapshot) {
                      //           if (snapshot.connectionState == ConnectionState.waiting) {
                      //             return Container(
                      //               width: 40.0,
                      //               height: 40.0,
                      //               color: Colors.grey,
                      //             );
                      //           } else if (snapshot.hasData) {
                      //             print("generating");
                      //             return Image.memory(snapshot.data!);
                      //           } else {
                      //             return Container(
                      //               width: 40.0,
                      //               height: 40.0,
                      //               color: Colors.red,  // Error color
                      //             );
                      //           }
                      //         },
                      //       ),
                      const SizedBox(width: 10),
                      Text(
                        shortenString(human.address!),
                        style:const TextStyle(fontSize: 13)),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 120),
              Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: Center(child: Text(human.balances!.length.toString()))
                ),  
               const SizedBox(width: 110),
                Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text(
               "Replace this"
                  // DateFormat('MMM d, yyyy').format(human.lastActive!)
                  ))),
            
            ],
        )
      )
    
    
    ;
  }
}