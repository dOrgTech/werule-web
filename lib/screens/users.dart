import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:homebase/main.dart';
import 'package:homebase/widgets/cutie.dart';
import 'package:homebase/widgets/hovermenu.dart';
import 'package:homebase/widgets/projectCard.dart';
import '../entities/human.dart';
import '../entities/project.dart';
import '../widgets/membersList.dart';
import '../widgets/menu.dart';
import '../widgets/usercard.dart';

List<Widget> userCards=[];
var selectedStatus="";
List<String> statuses=["Recently Active","Most Memberships","Most Reputation"];
class Users extends StatefulWidget {
  const Users({super.key});
  @override
  State<Users> createState() {
    return  _UsersState();
  }
}

class _UsersState extends State<Users> {
  @override
  void initState() {
    userCards=[];
    super.initState();
     for (Human h in humans){
      userCards.add(UserCard(human:h));   
    }
  }
    int _selectedCardIndex = -1;
  @override
  Widget build(BuildContext context) {
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
            const  SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                       height: 46, 
                       width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 1200),
                       child:  MediaQuery(
                 data: MediaQuery.of(context).copyWith(textScaleFactor: 0.8),child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Padding(
                              padding: const EdgeInsets.only(left:5.0),
                              child: SizedBox(
                                width: 
                                MediaQuery.of(context).size.width>1200?
                                500:
                                MediaQuery.of(context).size.width * 0.5,
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                         borderSide: BorderSide(width: 0.1),
                                      ),
                                    prefixIcon: Icon(Icons.search),
                                    hintText: 'Search user by address or alias',
                                    // other properties
                                  ),
                                  // other properties
                                ),
                              ),
                            ),
                           
                            ],
                           ),
                      )),
                      SizedBox(height: 23),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                                child: Container(
                                 child:  Column(
                                   children: [
                                     Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text("Addressss"),
                                        Text("            Memberships"),
                                        Text("   Last Active"),
                                      ],
                                ),SizedBox(height: 10),
   ...userCards.asMap().entries.map((entry) {
                        final index = entry.key;
                        final userCard = entry.value;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCardIndex = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: _selectedCardIndex == index
                                  ? Border.all(color: Color.fromARGB(255, 156, 156, 156))
                                  : null,
                            ),
                            
                            child: userCard,
                          ),
                        );
                      }).toList(),
                                   ],
                                 ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(14),
                                  child:
                                  _selectedCardIndex==-1?
                                  selectAnItem():
                                  userDetails(humans[_selectedCardIndex])
                                ),
                              ),
                      ],
                    ),
                  )
                  
                ],
              ), // End of Column
            ],
          ), // End of ListView
        ),
    );
  }

  Widget selectAnItem(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(height: 90),
        Icon(Icons.turn_left,size: 145,color: Color.fromARGB(96, 171, 171, 171),),
        SizedBox(height: 24),
        Text("Select an item", style: TextStyle(
          color: Color.fromARGB(96, 171, 171, 171),fontSize: 41
        ),)
      ],
    );
  }

  Widget userDetails(Human human){
    return Padding(
      padding: const EdgeInsets.only(left:28,top:30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: EdgeInsets.only(top:18.0,left:45),
              child: Row(
                children: [
                  Image.network(add1),
                  SizedBox(width: 10),
                  Text(human.address!, style: TextStyle(fontSize: 16),),
                  SizedBox(width: 10),
                  TextButton(onPressed: (){}, child: Icon(Icons.copy))
                ],
              ),
            ),
         const SizedBox(height: 39),
         const Padding(
            padding:  EdgeInsets.only(left:38.0),
            child: Text("Memberships:",style: TextStyle(fontSize: 19),),
          ),
          SizedBox(height: 19),
          Padding(
            padding:  EdgeInsets.only(left:38.0),
            child: Row(
              children: [
                Text("DAO Name"),
                SizedBox(width: 300),
                Text("Voting weight")
              ],
            ),
          ),
          Divider(),
          ...human.balances!.entries.map((entry) => 
          Padding(
            padding: const EdgeInsets.only(left:38.0,bottom:9),
            child: Row(
              children: [
                Text(entry.key.address.toString()),
                SizedBox(width: 100),
                Text(entry.value.toString()),
                SizedBox(width: 12),
                Text(entry.key.symbol)
              ],
            ),
          )),
        ],
      ),
    );
  }

}