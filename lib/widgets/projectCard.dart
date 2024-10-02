import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../screens/projectDetails.dart';
import '../widgets/menu.dart';
import 'package:intl/intl.dart';

import '../entities/project.dart';
import '../screens/dao.dart';

class ProjectCard extends StatelessWidget {
  ProjectCard({super.key, this.project});
  Project? project;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: TextButton(
        onPressed: () {
       Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>ProjectDetails(project: project!))
    );
        },
        child: SizedBox(
          width: 490,
          height: 260,
          child: Column(
            children: [
             const SizedBox(height: 8),
           Container(
            padding: EdgeInsets.only(top:4,bottom: 4,left:14,right: 14),
           decoration: BoxDecoration(
           color: Colors.grey.withOpacity(0.2),
          border: Border.all(width: 0.6,color: Colors.black12)
           ),
           child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Created: ${DateFormat.yMMMd().format(project!.creationDate!)}",style: const TextStyle(fontSize: 13),),
                    Text(project!.status=="Dispute"?"Expires: ${DateFormat.yMMMd().format(project!.expiresAt!)}":"",style: TextStyle(fontSize: 13)),
                ],
              ),
              ),
              SizedBox(height: 23),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left:8.0, top:10),
                    child: Column(
                        children: [
                          StatusBox(project: project!),
                            SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(color:Theme.of(context).canvasColor,
                                  border: Border.all(width: 0.5, color: Colors.white24)                      
                                ),
                            child: Column(
                              children: [
                                // Text("Holding" , textAlign: TextAlign.center, style: TextStyle( fontWeight: FontWeight.w100, fontSize: 14 ) ,),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                          Text(
                      project!.name!.length<29?project!.name!:
                      project!.name!.substring(0,28)+".."
                            , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),   
                       Padding(
                        padding: const EdgeInsets.only(top:18.0, left: 12),
                        child: SizedBox(
                          width: 290,
                          child: Text(project!.description!)),
                                       ),
                         ],
                       ),
                     ),
                ],
              ),
              Spacer(),
              Padding(padding: EdgeInsets.only(bottom: 13),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Author: "),
                  Text("Cotoflender ", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text("(tz1QEBc....d14hyu)"),
                ],
              )
              ),
              
               
        

            ],
          ),

        ),
      ),
    );
  }

}


class StatusBox extends StatelessWidget {
   StatusBox({required this.project, super.key});
  Project project;
  @override
  Widget build(BuildContext context) {
      
    return
    project.status =="Ongoing"?
                Container(
                      width: 90,
                      height: 20,
                      decoration: BoxDecoration(
                        color:Color.fromARGB(255, 80, 109, 96),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text(project!.status! , 
                      style: 
                     
                      TextStyle(color: Color.fromARGB(255, 185, 253, 206), fontWeight: FontWeight.bold, fontSize: 12)
                      ))) 
              :
    project.status =="Dispute"?

              Container(
                      width: 90,
                      height: 20,
                      decoration: BoxDecoration(
                        color:Color.fromARGB(255, 109, 80, 80),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text(project!.status! , 
                      style:
                  
                      TextStyle(color: Color.fromARGB(255, 253, 185, 185), fontWeight: FontWeight.bold, fontSize: 12))))
                :
                project.status =="Open"?
                    Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38,width: 0.01),
                      borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color:Colors.white70,
                        blurRadius: 1.0,
                        spreadRadius: 0.12,
                        offset: Offset(0.1, 0.3),
                      ),
                    ],
                    ),
                    width: 90,
                    height: 19,
                    child:Center(child: Text(
                      project.status.toString(),style: TextStyle(color: Color.fromARGB(255, 8, 29, 9)),
                    ),)
                  ):
                   project.status =="Pending"?
                    Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromARGB(96, 202, 202, 202),width: 0.01),
                      borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color:Colors.white70,
                        blurRadius: 1.0,
                        spreadRadius: 0.12,
                        offset: Offset(0.1, 0.3),
                      ),
                    ],
                    ),
                    width: 90,
                    height: 19,
                    child:Center(child: Text(
                      project.status.toString(),style: TextStyle(color: Color.fromARGB(255, 75, 75, 75)),
                    ),)
                  ):
                      Container(
                    decoration: BoxDecoration(
                      border: Border.all(color:  Colors.black38,width: 0.01),
                      borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color:Color.fromARGB(234, 104, 104, 104),
                        blurRadius: 1.0,
                        spreadRadius: 0.12,
                        offset: Offset(0.1, 0.3),
                      ),
                    ],
                    ),
                    width: 90,
                    height: 19,
                    child:Center(child: Text(
                      project.status.toString(),style: TextStyle(color: Colors.black),
                    ),)
                  )                  
                        ;                  
       }
}