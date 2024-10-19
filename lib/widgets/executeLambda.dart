import 'package:Homebase/entities/org.dart';
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
  "Engagement with another DAO":engagement(context,"dao"),
  'Change Config':notImpl()
  ,'Change Guardian':notImpl()
  ,'Change Delegate':notImpl()
};
return components[selectedValue] as Widget;
}



class ExecuteLambda extends StatefulWidget {
  ExecuteLambda({super.key, required Org org});

  @override
  State<ExecuteLambda> createState() => _ExecuteLambdaState();
}

class _ExecuteLambdaState extends State<ExecuteLambda> {
  
  @override
  Widget build(BuildContext context) {
    
    return Container(
          constraints: const BoxConstraints(maxWidth: 900),
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


Widget engagement(context, which){
    return Engagement(which: "dao");
  }

  

Widget notImpl(){
  return Placeholder();
}


Widget transfer(context) {
  String selectedAsset = 'XTZ';
  double availableXTZ = 4500;
  double availableUSDC = 4000;

  return Container(
    child: Column(
      children: [
        const SizedBox(height: 60),
        SizedBox(
          width: 430,
          child: DropdownButtonFormField<String>(
            value: selectedAsset,
            onChanged: (value) {
              selectedAsset = value!;
            },
            items: ['XTZ', 'USDC'].map((String asset) {
              return DropdownMenuItem<String>(
                value: asset,
                child: Text(asset),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: "Asset Type",
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 430,
          child: Text(
            selectedAsset == 'XTZ'
                ? 'Available: $availableXTZ XTZ'
                : 'Available: $availableUSDC USDC',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 430,
          child: TextField(
            onChanged: (value) {},
            maxLength: 42,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              labelText: "Recipient Address",
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 430,
          child: TextField(
            maxLength: 42,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              labelText: "Amount",
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 430,
          height: 40,
          child: TextButton(
            style: ButtonStyle(
              elevation: const MaterialStatePropertyAll(0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add),
                SizedBox(width: 20),
                Text("Add recipient"),
              ],
            ),
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 77),
        SizedBox(
          height: 40,
          width: 170,
          child: TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).indicatorColor),
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).indicatorColor),
              elevation: MaterialStateProperty.all(1.0),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
              ),
            ),
            onPressed: null,
            child: const Center(
              child: Text(
                "SUBMIT",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
        )
      ],
    ),
  );
}




class Engagement extends StatelessWidget {
  Engagement({super.key, required this.which});
  String which;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: SizedBox(
                      height: 40,
                       child: Center(
                         child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Funds in escrow: ",style: TextStyle(fontSize: 18)),
                                Text("28400.00", style: TextStyle(fontSize: 18,color: Theme.of(context).indicatorColor),),
                                const SizedBox(width: 8),
                                Text("USDT", style: TextStyle(fontSize: 18,color: Theme.of(context).indicatorColor),),
                                const SizedBox(width: 20),
                                Text("from ", style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Text("9 senders", style: TextStyle(fontSize: 18, color: Theme.of(context).indicatorColor),),
                                const SizedBox(width: 30),
                                ElevatedButton(onPressed: (){}, child: Text("View"))
                                
                              ],
                            ),
                       ),
                     ),
        ),
         SizedBox(
                    height: 40,
                     child: Center(
                       child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Arbiter Address: "),
                              Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5", style: TextStyle(fontSize: 11),),
                              const SizedBox(width: 2,),
                              TextButton(
                                onPressed: (){},
                                child: const Icon(Icons.copy)),
                            ],
                          ),
                     ),
                   ),
                   SizedBox(
                    height: 40,
                     child: Center(
                       child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Terms of Engagement: "),
                              Text("https://ipfs/QmNrgEMcUygbKzZe...", style: TextStyle(fontSize: 11),),
                              const SizedBox(width: 2,),
                              TextButton(
                                onPressed: (){},
                                child: const Icon(Icons.copy)),
                            ],
                          ),
                     ),
                   ),



        Container(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              
            SizedBox(width: 50,height: 4,),
            Container(
              decoration: BoxDecoration(
                color: Color(0x31000000),
                border: Border.all(width: 1, color:  Color(0x2111111))
              ),
              padding: EdgeInsets.all(50),
              child: Column(
                children: [
                  SizedBox(
                    width: 360,
                    child: const  Text("Throw the project into arbitration",
                    textAlign: TextAlign.center,
                     style: TextStyle(fontSize: 19), 
                      ),
                  ),
                  SizedBox(height: 30),
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
                    ),
                ],
              ),
            ),
            SizedBox(width: 50,height: 40,),
              
          Container(
              decoration: BoxDecoration(
                color: Color(0x31000000),
                border: Border.all(width: 1, color:  Color(0x2111111))
              ),
              padding: EdgeInsets.only(top:50,bottom:50,left:40,right:40),
              child: Column(
                children: [
                  SizedBox(
                    width: 380,
                    child: const  Text("Return all funds to the sender(s)",
                     style: TextStyle(fontSize: 19), 
                      ),
                  ),
                  SizedBox(height: 30),
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
                    ),
                ],
              ),
            ),
   
        
          
            ]
          )
          ),
      ],
    );
  }
}