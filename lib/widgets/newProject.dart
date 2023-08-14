

import 'dart:isolate';
import 'dart:html' as html;
import 'package:beamer/beamer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/project.dart';



const String escape = '\uE00C';

class NewProject extends StatefulWidget {
bool loading=false;
bool done=false;
bool error=false;
Project project=Project();

State state;
// ignore: use_key_in_widget_constructors
NewProject({required this.state}) ;

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
    widget.loading&&!widget.done && !widget.error?
   Center(child: Column(
     mainAxisAlignment: MainAxisAlignment.center,
     crossAxisAlignment: CrossAxisAlignment.center,
      children:  [
        Text("Creating proposal for new client project...", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        const SizedBox(height: 80),
        SizedBox(
          height: 100,width: 100,
          child: CircularProgressIndicator(),),
      ],
    ),):
    !widget.loading && !widget.done && !widget.error?
     Consumer(
      builder: (context, watch,child) {
        // final om=watch(human);
        // final stati=watch(stats);
        // print("lungimea la chestii ${stati.paymentTokens.keys.length}");
        // for (int i = 0; i < stati.paymentTokens.entries.length; i++) {
        //   print("facem si desfacem ${stati.paymentTokens.keys.elementAt(i)}" );
        //   String token=stati.paymentTokens.keys.elementAt(i).symbol;
        //   paymentTokens.add(DropdownMenuItem(child: Text(token),value:i));
        // }
        paymentTokens.add(const DropdownMenuItem(child: const Text("USDC"),value:0));
        paymentTokens.add(const DropdownMenuItem(child: Text("MATIC"),value:1));
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
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
                      UploadPic(widget.project),
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
                Container(
                  width:270,
                  height:50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.1,
                    ),
                    color: const Color.fromARGB(31, 95, 95, 95),
                  ),
                  child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Payment Token ",style: TextStyle(fontSize: 16),),
                            const SizedBox(width: 10),
                              DropdownButton(
                            value: pmttoken,
                            onChanged: (value) {
                              int numar=value as int;
                              setState(() {pmttoken=numar;});
                                },
                            items:paymentTokens)
                        ]),
                ),
                const SizedBox(height: 20,),
               SizedBox(
                  width:380,
                  child: TextField(
                    onChanged: (value) {
                      widget.project.client=value;
                    },
                    maxLength: 42,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Client Address",
                      hintText: 'Client Address'),),
                ),
                 // ignore: prefer_const_constructors
                 SizedBox(
                  width:380,
                  // ignore: prefer_const_constructors
                  child: TextField(
                    controller:TextEditingController()..text =
                     '0x85F407ad0d51900d0F9A0a0dcBc13d7Ab15315C4',
                    readOnly:true,
                    maxLength: 42,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      labelText: "Arbiter Address",
                      hintText: 'Arbiter Address'),),
                ),
                SizedBox(
                  width:380,
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
                      overlayColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 134, 0, 0)),
                      backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 85, 31, 31)),
                      elevation: MaterialStateProperty.all(1.0),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                      ),
                    ),
                    onPressed: ()async{
                      setState(() {widget.loading=true;});
                      String projectAddress=await createClientProject(
                        widget.project,
                        this,
                       
                        );
                      //   receivePort.listen((message) {
                      //   projectAddress=message;
                      //  });               
                       print("asivenit "+projectAddress);
                    },
                     child: const Center(
                    child: Text("CREATE PROJECT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(221, 255, 255, 255)),),
                  )),
                )
                ],
              ),
            ),
          ),
        );
      }
    ):
    !widget.error?
    Center(child: 
      SizedBox(
        height:300,width: 300,
        child:Column(children: [
          Text("Project created successfully!",style: TextStyle(fontSize: 18),),
          // const SizedBox(height: 20,),
          // ElevatedButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("Yeeey!",style: TextStyle(fontSize: 20),)),
        ],)
      )
    )
    :
    Center(child: 
      SizedBox(
        height:300,width: 300,
        child:Column(children: [
          Text("Transaction reverted.",style: TextStyle(fontSize: 18),),
          const SizedBox(height: 20,),
          ElevatedButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("Ok",style: TextStyle(fontSize: 20),)),
        ],)
      )
    );

  }

  bool pressedName = false;
  bool pressedDesc = false;

  UploadPic(Project project){print("upload pic");}
  createClientProject(project,state){print("create project");}
  Widget agentName() {
    var whatis = !pressedName
        ? SizedBox(
            width: 400,
            height: 50,
            child: TextButton(
              onPressed: () => setState(() => pressedName = true),
              child: Row(
                children: const [
                  Icon(Icons.edit),SizedBox(width: 5,),
                  Text('Set name', style: TextStyle(fontSize: 21))
                ],
              ),
            ),
          )
        : SizedBox(
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
    var whatis = !pressedDesc
        ? SizedBox(
            width: 470,
            height: 90,
            child: TextButton(
              onPressed: () => setState(() => pressedDesc = true),
              child: Row(
                children: const [
                  Icon(Icons.edit),SizedBox(width: 5,),
                  Text(
                    'Set description',
                  )
                ],
              ),
            ),
          )
        : TextField(
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