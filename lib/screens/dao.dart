import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:homebase/screens/account.dart';
import 'package:homebase/screens/proposals.dart';
import 'package:homebase/screens/registry.dart';
import 'package:homebase/screens/treasury.dart';
import 'package:homebase/widgets/membersList.dart';
import 'package:homebase/widgets/menu.dart';
import 'home.dart';
import 'members.dart';
class DAO extends StatefulWidget {
  DAO({super.key, this.InitialTabIndex=0});
  int InitialTabIndex;
  @override
  State<DAO> createState() => _DAOState();
}
class _DAOState extends State<DAO> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopMenu(),
      body: Container(
        alignment:Alignment.topCenter,
          child: DefaultTabController(
            initialIndex: widget.InitialTabIndex,
            length: 6,
            child: ListView( // Start of ListView
              shrinkWrap: true, // Set this property to true
              children: [
                  Column( // Start of Column
                    crossAxisAlignment: CrossAxisAlignment.center, // Set this property to center the items horizontally
                    mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its children's size vertically
                    children: [
                      // LinearProgressIndicator(
                      //   color: Theme.of(context).indicatorColor.withOpacity(0.3),
                      //   minHeight: 7,
                      // ),
                     Container(
                      alignment: Alignment.topCenter,
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 1200),
                      height: 50,
                      color:Theme.of(context).cardColor,
                      child:TabBar( 
                    
                tabs: [
                  menuItem(MenuItem("Home",const Icon(Icons.home))),
                  menuItem(MenuItem( "Proposals",const Icon(Icons.front_hand))),
                  menuItem(MenuItem("Treasury",const Icon(Icons.money))),
                  menuItem(MenuItem("Registry",const Icon(Icons.list))),
                  menuItem(MenuItem("Members",const Icon(Icons.people))),
                  menuItem(MenuItem("Account",const Icon(Icons.person))),
                ],
              ), 
              
                     ),
                     
                      Container(
                        height: 1000,
                         width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 1200),
                         // Expanded start
                child: TabBarView( // TabBarView start
                  children: [
                    Home(),
                    Center(child: Proposals(which: "all",)),
                    Center(child: Treasury()),
                    Center(child: Registry()),
                    Center(child: Members()),
                    Center(child: Account()),
                  ],
                ), // TabBarView end
              ), 
              
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
