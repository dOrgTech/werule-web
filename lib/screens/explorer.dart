import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:homebase/widgets/menu.dart';

import '../widgets/daocard.dart';
class Explorer extends StatefulWidget {
  const Explorer({super.key});

  @override
  State<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {
  @override
  Widget build(BuildContext context) {
       List<Widget> daos=[];
    for (var i = 0; i < 41; i++) {
      daos.add(DAOCard());
    }
    return Scaffold(
      appBar: const TopMenu(),
      body: Container(
          alignment: Alignment.topCenter,
          child: ListView( // Start of ListView
            shrinkWrap: true, // Set this property to true
            children: [
              Column( // Start of Column
                crossAxisAlignment: CrossAxisAlignment.center, // Set this property to center the items horizontally
                mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its children's size vertically
                children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                       height: 80, 
                       width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 1200),
                       child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Padding(
                          padding: const EdgeInsets.only(left:5.0),
                          child: SizedBox(
                            width: 
                            MediaQuery.of(context).size.width>1200?
                            550:
                            MediaQuery.of(context).size.width * 0.5,
                            child: TextField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                     borderSide: BorderSide(width: 0.1),
                                  
                                  ),
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Search by DAO Name or Token Symbol',
                                // other properties
                              ),
                              // other properties
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right:8.0),
                          child: Row(
                            children: [
                              Text("21 DAOs"),
                              SizedBox(width: 30,),
                              SizedBox(
                                height: 40,
                                child: ElevatedButton(onPressed: (){}, 
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).indicatorColor),
                                child: Text("Create DAO", 
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'CascadiaCode', fontSize: 18, fontWeight: FontWeight.w100),)),
                              )
                            ],
                          ),
                        )
                        ],
                       ),
                      ),
                    SizedBox(height: 10,),
                   Container(
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 1200),
                     child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: daos as List<Widget>,
                     ),
                   )
                ],
              ), // End of Column
            ],
          ), // End of ListView
        ),
    );
  }
}