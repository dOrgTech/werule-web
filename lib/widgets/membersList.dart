import 'package:Homebase/utils/reusable.dart';
import 'package:flutter/material.dart';
import '../screens/creator.dart';
import '../entities/org.dart';
import 'dart:typed_data';
String add1="https://i.ibb.co/2WbL5nC/add1.png";
String add2="https://i.ibb.co/6rmksXk/add2.png";
List<String> userPics=[add1, add2];

class MembersList extends StatelessWidget {
   MembersList({super.key, required this.org});
  Org org;
  @override
  Widget build(BuildContext context) {
    List<TableRow> tableRows=[];
    for (Member m in org.members){
      tableRows.add(MemberTableRow(m));
    }
    return Column(
      children: [
        Table(
        border: TableBorder.all(
          color: Colors.transparent
        ),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(2.4),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
          3:FlexColumnWidth(),
          4: FlexColumnWidth(),
          5: FlexColumnWidth(),
  
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: <TableRow>[
          TableRow(
            children: <Widget>[
              Container(
                height: 22,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const  Padding(
                  padding: EdgeInsets.only(top:4.0,left:75),
                  child: Text("Address"),
                ),
              ),
              Container(
                height: 35,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("Voting\nWeight", textAlign: TextAlign.center,))
                ),
                Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: Center(child: Text("Personal\n${org.symbol!} Balance", textAlign: TextAlign.center))),
                   Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child:  Center(child: Text("Proposals\nCreated", textAlign: TextAlign.center))),
                   Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("Proposals\nVoted", textAlign: TextAlign.center))),
            ],
          ),

         
          ],
        ),



Opacity(
  opacity: 0.5,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal:29.0),
    child: Divider(),
  )),
      Table(
        border: TableBorder.all(
          color: Colors.transparent
        ),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(2.4),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
          3:FlexColumnWidth(),
           4: FlexColumnWidth(),
          5: FlexColumnWidth(),
  
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows)]);
  }
}


class MemberTableRow extends TableRow {
  MemberTableRow(Member member)
      : super(
          children: <Widget>[
            InkWell(
              onTap: () {
                // Define tap action here if needed
              },
              child: Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 35),
                  child: Row(
                    children: [
                      FutureBuilder<Uint8List>(
                            future: generateAvatarAsync(hashString(member.address)),  // Make your generateAvatar function return Future<Uint8List>
                            builder: (context, snapshot) {
                              // Future.delayed(Duration(milliseconds: 500));
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                      color: Theme.of(context).canvasColor,
                                  ),
                                  width: 50.0,
                                  height:50.0,
                                );
                              } else if (snapshot.hasData) {
                                return Container(width: 50,height: 50,  
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0)
                                  ),
                                child: Image.memory(snapshot.data!));
                              } else {
                                return Container(
                                  width: 50.0,
                                  height: 50.0,
                                  color: Theme.of(context).canvasColor,  // Error color
                                );
                              }
                            },
                          ),
                      const SizedBox(width: 10),
                      Text(
                        member.address,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          // Copy functionality
                        },
                        child: const Icon(Icons.copy),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 42,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Center(
                child: Text(member.votingWeight?.toString() ?? "N/A"),
              ),
            ),
            Container(
              height: 42,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Center(
                child: Text(member.personalBalance ?? "N/A"),
              ),
            ),
            Container(
              height: 42,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Center(
                child: Text(member.proposalsCreated.length.toString()),
              ),
            ),
            Container(
              height: 42,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Center(
                child: Text(member.proposalsVoted.length.toString()),
              ),
            ),
          ],
        );
}


