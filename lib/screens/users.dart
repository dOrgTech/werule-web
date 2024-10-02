import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../main.dart';
import '../utils/functions.dart';
import '../utils/reusable.dart';
import '../widgets/cutie.dart';
import '../widgets/footer.dart';
import '../widgets/hovermenu.dart';
import '../widgets/projectCard.dart';
import '../entities/human.dart';
import '../entities/project.dart';
import '../widgets/membersList.dart';
import '../widgets/menu.dart';
import '../widgets/usercard.dart';
import 'package:intl/intl.dart';

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
  for (int i = 0; i < 12 && i < users!.length; i++) {
  // userCards.add(UserCard(human: users![i].));
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
                                  // userDetails(humans[_selectedCardIndex])
                                  Text("You have selected something!")
                                ),
                              ),
                        ],
                      ),
                    )
                  ],
                ), 
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
                  FutureBuilder<Uint8List>(
                      future: generateAvatarAsync(hashString(human.address!)),  // Make your generateAvatar function return Future<Uint8List>
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: 40.0,
                            height: 40.0,
                            color: Colors.grey,
                          );
                        } else if (snapshot.hasData) {
                          print("generating on the right");
                          return Image.memory(snapshot.data!);
                        } else {
                          return Container(
                            width: 40.0,
                            height: 40.0,
                            color: Colors.red,  // Error color
                          );
                        }
                      },
                    ),
                 const SizedBox(width: 10),
                  Text(human.address!, style: TextStyle(fontSize: 16),),
                 const SizedBox(width: 10),
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
                SizedBox(width: 170),
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
                InkWell(
                  onTap: (){},
                  child: SizedBox(
                    width: 240,
                    child: Text(entry.key.name.toString()))),
                SizedBox(width: 10),
                Text(entry.value.toString()),
               const SizedBox(width: 12),
                Text(entry.key.symbol)
              ],
            ),
          )),
         const SizedBox(height: 39),
         const Padding(
            padding:  EdgeInsets.only(left:38.0),
            child: Text("Activity:",style: TextStyle(fontSize: 19),),
          ),
         const SizedBox(height: 19),
          Padding(
            padding: const EdgeInsets.only(left:38.0),
            child: Row(
              children: const [
                Text("Time"),
                SizedBox(width: 130),
                Text("Action"),
               
              ],
            ),
          ),
          Divider(),
          ...human.actions!.reversed.map((entry) => 
          Padding(
            padding: const EdgeInsets.only(left:18.0,bottom:9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
               const SizedBox(width: 20),
                SizedBox(width:120,child: Text(DateFormat('MMM d, yyyy').format(entry.time))),
                const SizedBox(width: 50),
                Text(entry.type),
  
              ],
            ),
          )),
        ],
      ),
    );
  }

}