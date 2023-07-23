import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:homebase/screens/proposals.dart';
import 'package:homebase/screens/registry.dart';
import 'package:homebase/screens/treasury.dart';
import 'package:homebase/widgets/menu.dart';
import 'home.dart';
class DAO extends StatefulWidget {
  const DAO({super.key});
  @override
  State<DAO> createState() => _DAOState();
}
class _DAOState extends State<DAO> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopMenu(),
      body: Container(
        alignment:Alignment.topCenter,
          child: DefaultTabController(
            initialIndex: 0,
            length: 5,
            child: ListView( // Start of ListView
              shrinkWrap: true, // Set this property to true
              children: [
                  Column( // Start of Column
                    crossAxisAlignment: CrossAxisAlignment.center, // Set this property to center the items horizontally
                    mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its children's size vertically
                    children: [
                     Container(
                      alignment: Alignment.topCenter,
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 1200),
                      height: 50,
                      color: Color.fromARGB(255, 68, 68, 68),
                      child:TabBar( 
                    
                tabs: [
                  menuItem(MenuItem("Home",Icon(Icons.home))),
                  menuItem(MenuItem( "Proposals",Icon(Icons.front_hand))),
                  menuItem(MenuItem("Treasury",Icon(Icons.money))),
                  menuItem(MenuItem("Registry",Icon(Icons.list))),
                  menuItem(MenuItem("Account",Icon(Icons.person))),
                ],
              ), 
                     ),
                      Container(
                        height: 1000,
                         width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 1200),
                         // Expanded start
                child: TabBarView( // TabBarView start
                  children: [
                    Home(),
                    Center(child: Proposals()),
                    Center(child: Treasury()),
                    Center(child: Registry()),
                    Center(child: Text('NFTs')),
                  ],
                ), // TabBarView end
              ), // Ex
                    ],
                  
                ), // End of Column
              ],
            ),
          ), // End of ListView
        ),
    );
  }
  
  menuItem(MenuItem id){
    return Tab(
      child:Center(
                  child: Row( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                    id.icon,
                   const SizedBox(width: 8),
                    Text( id.name,style: const TextStyle(fontSize: 18),),
                    ]),
                )
    );
  }

}

class MenuItem{
  String name;
  Icon icon;
  Widget? content;
  MenuItem(this.name,this.icon);

}
