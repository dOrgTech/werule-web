import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class DAOCard extends StatelessWidget {
  const DAOCard({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Card(
      child: TextButton(
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical:14.0),
          child: SizedBox(
            width: 367,
            height: 145,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:8.0, top:10),
                  child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom:16.0),
                          child: Text("SYM", style: TextStyle(
                            color:Theme.of(context).indicatorColor,
                            fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        Container(
                          width: 40,
                          height: 20,
                          decoration: BoxDecoration(
                            color:Color.fromARGB(255, 80, 109, 96),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text("V.3" , style: TextStyle(color: Color.fromARGB(255, 185, 253, 206), fontWeight: FontWeight.bold, fontSize: 15))),
                        ),
  SizedBox(height: 16),
                        Text("24", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      
                        Text("Voting\nAddresses" , textAlign: TextAlign.center, style: TextStyle( fontWeight: FontWeight.w100, fontSize: 13 ) ,),
                      ],
                    ),
                ),
                  SizedBox(width: 20),
                   Padding(
                     padding: const EdgeInsets.only(top:8.0),
                     child: Column(
                       children: [
                        
                            Text('DAO NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                           
                     Padding(
                      padding: const EdgeInsets.only(top:18.0, left: 12),
                      child: SizedBox(
                        width: 240,
                        child: Center(child: Text('The DAO was an organization that used smart contracts to automate governance and investment decisions.'))),
                                     ),
                       ],
                     ),
                   ),
                 
                
              ],
            ),

          ),
        ),
      ),
    );
  }
}