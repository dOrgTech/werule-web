import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';


final List<String> items = ['Transfer', 
   'Change Config','Change Guardian','Change Delegate', "Engagement with another DAO" ];

  // The current selected value of the dropdown
String? selectedValue = 'Transfer';

Widget getComponent(context){
  Map<String,Widget> components={
  "Transfer":transfer(context),
  "Engagement with another DAO":engagement(context)
};
return components[selectedValue] as Widget;
}



class ExecuteLambda extends StatefulWidget {
  ExecuteLambda({super.key});

  @override
  State<ExecuteLambda> createState() => _ExecuteLambdaState();
}

class _ExecuteLambdaState extends State<ExecuteLambda> {
  
  @override
  Widget build(BuildContext context) {
    
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 60),
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
                      Text("Pick an available function:"),
                      SizedBox(width: 20),
                      DropdownButton<String>(
                        hint:Text('Select a value'),
                        enableFeedback: true,
                          value: selectedValue,
                          focusColor: Colors.transparent,
                          items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
                          }).toList(),
                          onChanged: (String? newValue) {
              setState(() {
                selectedValue = newValue;
              });
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 8,),
              
                getComponent(context)
                ],
              ),
          ))
          
        
      
    );
  }
}


Widget engagement(context){
    return Container(
      child: Column(
        children: [
          SizedBox(height: 90),
        SizedBox(
          width: 360,
          child: const  Text("This will create a proposal to the project into arbitration.",
           style: TextStyle(fontSize: 19), 
            ),
        ),
          SizedBox(height: 90),
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
                    onPressed: (){
                      Navigator.of(context).pop();
                      
                    },
                    
                     child: const Center(
                    child: Text("SUBMIT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:Colors.black),),
                  )),
                )
        ]
      )
      );
  }


Widget transfer(context){
    return Container(
      child: Column(
        children: [
               const SizedBox(height: 60,),
               SizedBox(
                  width:430,
                  child: TextField(
                    onChanged: (value) {
                     
                    },
                    maxLength: 42,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Recipient Address",
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
                      labelText: "Amount",
                      ),),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width:430,
                  height: 40,
                  child: TextButton(
                    style: ButtonStyle(
                      elevation: MaterialStatePropertyAll(0.1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 20),
                      Text("Add recipient"),
                    ],
                  ), onPressed: (){},)
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
                    onPressed: null,
                    
                     child: const Center(
                    child: Text("SUBMIT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:Colors.black),),
                  )),
                )
 
        ],
      ),
    );
  }
