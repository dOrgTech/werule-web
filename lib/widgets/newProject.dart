

import 'dart:isolate';
import 'dart:html' as html;
import 'package:beamer/beamer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/project.dart';



const String escape = '\uE00C';


class Dobli extends StatelessWidget {
  const Dobli({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 400,width:500, child:Text("NEW PROPOSAL"));
  }
}

class NewProject extends StatefulWidget {
bool loading=false;
bool done=false;
bool error=false;
Project project=Project();

// ignore: use_key_in_widget_constructors
NewProject() ;

  @override
  _NewProjectState createState() => _NewProjectState();
}
int pmttoken=0;
class _NewProjectState extends State<NewProject> {
  
  @override
  Widget build(BuildContext context) {
    DateTime.now().add(Duration(days:1825 ));
    List<DropdownMenuItem<int>> paymentTokens=[];
    return
    Container(
          padding: EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).highlightColor,
              width: 0.3,
            ),
          ),
          // width: MediaQuery.of(context).size.width*0.7,
          height: MediaQuery.of(context).size.height*0.86,
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UploadPic(),
                      const SizedBox(width: 30,),
                      Column(
                        children: [
                            const SizedBox(height: 10,),
                            agentName(),
                            agentDescription(),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8,),
              
                const SizedBox(height: 60,),
               SizedBox(
                  width:430,
                  child: TextField(
                    onChanged: (value) {
                      widget.project.client=value;
                    },
                    maxLength: 42,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Client Address",
                      ),),
                ),
                 // ignore: prefer_const_constructors
                 SizedBox(
                  width:430,
                  // ignore: prefer_const_constructors
                  child: TextField(
                    
                    maxLength: 42,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      labelText: "Arbiter Address",
                      ),),
                ),
                SizedBox(
                  width:430,
                  child: TextField(
                    onChanged: (value) {
                      widget.project.link=value;
                    },
                    style: const TextStyle(fontSize: 13),
                    decoration:  InputDecoration(
                      labelText: "Offchain resource",
                      hintText: 'Link to additional details.'),),
                ),
               const SizedBox(height: 77,),
                SizedBox(
                  height: 40,
                  width: 170,
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all<Color>(Theme.of(context).indicatorColor),
                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).indicatorColor),
                      elevation: MaterialStateProperty.all(1.0),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                      ),
                    ),
                    onPressed: ()async{

                      // setState(() {widget.loading=true;});
                      // String projectAddress=await createClientProject(
                      //   widget.project,
                      //   this,
                       
                      //   );
                      //   receivePort.listen((message) {
                      //   projectAddress=message;
                      // //  });               
                      Navigator.of(context).pop();
                    },
                     child: const Center(
                    child: Text("CREATE PROJECT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:Colors.black),),
                  )),
                )
                ],
              ),
          ))
    );

  }

  bool pressedName = false;
  bool pressedDesc = false;

  UploadPic(){return SizedBox(
    width: 150,height: 150,
    child: Placeholder());}
  createClientProject(project,state){print("create project");}
  Widget agentName() {
    var whatis =  SizedBox(
          width:400,
          height: 50,
          child: TextField(
              maxLength: 30,
              style: const TextStyle(fontSize: 21),
              decoration: const InputDecoration(hintText: 'Set project name'),
              onChanged: (value) => widget.project.name = value,
            ),
        );
    return SizedBox(
      width: 460,
      height: 50,
      child: widget.project.name == null ||widget.project.name == "N/A"
          ? whatis
          : Text(
              widget.project.name!,
              style: const TextStyle(fontSize: 21),
            ),
    );
  }
  Widget agentDescription() {
    var whatis = TextField(
            maxLength: 200,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'A few words about the project',
            ),
            onChanged: (value) {
              widget.project.description = value;
            },
          );
    return Container(
      width: 470,
      height: 90,
      margin: const EdgeInsets.only(top: 26),
      child: widget.project.description == null||widget.project.description == "N/A"
          ? whatis
          : Text(
              widget.project.description!,
              style: const TextStyle(fontSize: 17),
            ),
    );
  }
}