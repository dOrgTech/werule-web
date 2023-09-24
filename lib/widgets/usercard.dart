import 'package:flutter/material.dart';
import 'package:homebase/utils/functions.dart';
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
                      Image.network(add1),
                      const SizedBox(width: 10),
                      Text(
                        shortenString(human.address!)
                        , style:const TextStyle(fontSize: 13),),
                      const SizedBox(width: 30),
                     
                    ],
                  ),
                ),
              ),
              SizedBox(width: 120),
              Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: Center(child: Text(human.balances!.length.toString()))
                ),  
               const SizedBox(width: 110),
                Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: Center(child: Text(
                  DateFormat('MMM d, yyyy').format(human.lastActive!)
                  ))),
            
            ],
        )
      )
    
    
    ;
  }
}