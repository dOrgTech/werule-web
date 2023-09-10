import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:homebase/screens/projectDetails.dart';

import '../entities/project.dart';
import '../screens/dao.dart';

class ProjectCard extends StatelessWidget {
  ProjectCard({super.key, this.project});
  Project? project;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextButton(
        onPressed: () {
       Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>ProjectDetails(project: project!))
    );
        },
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SizedBox(
            width: 490,
            height: 240,
            child: Column(
              children: [
                Row(children: [
                 
                ],),
                SizedBox(height: 9),
                Padding(padding: EdgeInsets.only(left:22),
                child:Row(
                  children: [
                    Text("Author: "),
                    Text("Cotoflender ", style: TextStyle(fontWeight: FontWeight.bold),),
                    Text("(tz1QEBc....d14hyu)"),
                     Spacer(),
                  Container(
                    decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color:Colors.white54,
                        blurRadius: 2.0,
                        spreadRadius: 0.12,
                        offset: Offset(0.1, 0.3),
                      ),
                    ],
                    ),
                    width: 90,
                    height: 29,
                  )

                  ],
                )
                ),
                SizedBox(height: 23),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:8.0, top:10),
                      child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 20,
                              decoration: BoxDecoration(
                                color:project!.status =="Ongoing"?Color.fromARGB(255, 80, 109, 96):Color.fromARGB(255, 109, 80, 80),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: Text(project!.status! , 
                              style: 
                              project!.status =="Ongoing"?
                              TextStyle(color: Color.fromARGB(255, 185, 253, 206), fontWeight: FontWeight.bold, fontSize: 12)
                              :
                              TextStyle(color: Color.fromARGB(255, 253, 185, 185), fontWeight: FontWeight.bold, fontSize: 12))),
                              
                            ),
                              SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(color:Theme.of(context).canvasColor,
                                        border: Border.all(width: 0.5, color: Colors.white24)                      
                                      ),
                              child: Column(
                                children: [
                                  Text("In escrow" , textAlign: TextAlign.center, style: TextStyle( fontWeight: FontWeight.w100, fontSize: 14 ) ,),
                                  Text(project!.amountInEscrow!.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                                  Text("USDT" , textAlign: TextAlign.center, style: TextStyle( fontWeight: FontWeight.w100, fontSize: 16 ) ,),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ),
                      SizedBox(width: 20),
                       Padding(
                         padding: const EdgeInsets.only(top:8.0),
                         child: Column(
                           children: [
                            Text(project!.name!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),   
                         Padding(
                          padding: const EdgeInsets.only(top:18.0, left: 12),
                          child: SizedBox(
                            width: 290,
                            child: Center(child: Text(project!.description!))),
                                         ),
                           ],
                         ),
                       ),
                     
                    
                  ],
                ),
              ],
            ),

          ),
        ),
      ),
    );
  }
}