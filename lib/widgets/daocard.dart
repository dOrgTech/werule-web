import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../screens/dao.dart';

import '../entities/org.dart';

class DAOCard extends StatelessWidget {
  DAOCard({super.key, required this.org});
  Org org;
  @override
  Widget build(BuildContext context) {
    
    return Card(
      child: TextButton(
        onPressed: () {
       Navigator.push(
  context,
  MaterialPageRoute(builder: (context) =>DAO(InitialTabIndex: 0, org:org))
  ) ;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical:14.0),
          child: SizedBox(
            width: 350,
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
                          child: Text(org.govToken!.symbol, style: TextStyle(
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
                        Text(org.holders.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      
                        Text("Voting\nAddresses" , textAlign: TextAlign.center, style: TextStyle( fontWeight: FontWeight.w100, fontSize: 13 ) ,),
                      ],
                    ),
                ),
                  SizedBox(width: 20),
                   Padding(
                     padding: const EdgeInsets.only(top:8.0),
                     child: Column(
                       children: [
                        
                            Text(org.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                           
                     Padding(
                      padding: const EdgeInsets.only(top:18.0, left: 12),
                      child: SizedBox(
                        width: 240,
                        child: Center(child: Text(org.description!))),
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