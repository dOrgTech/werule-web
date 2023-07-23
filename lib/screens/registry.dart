import 'package:flutter/material.dart';



class Registry extends StatefulWidget {
  const Registry({super.key});

  @override
  State<Registry> createState() => _RegistryState();
}

class _RegistryState extends State<Registry> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        SizedBox(
          height: 120,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
             Container(
                  padding: EdgeInsets.only(left: 50),
                  width: 500,
                  child: TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(width: 0.1),
                          ),
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search by Key',
                        // other properties
                      ),
                      // other properties
                    ),
                ),
             const Spacer(),
               Container(
                      padding: EdgeInsets.only(right: 50),
                      height: 40,
                      child: ElevatedButton(
                        child: Text("Add/Edit Item",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black87),
                        ),
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).indicatorColor)),
                        onPressed: (){},),
                    ),
            ],
          )
        ),
      ],
    );
  }
}