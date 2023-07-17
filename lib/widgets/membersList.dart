import 'package:flutter/material.dart';
String add1="https://i.ibb.co/2WbL5nC/add1.png";
String add2="https://i.ibb.co/6rmksXk/add2.png";


class Members extends StatelessWidget {
  const Members({super.key});

  @override
  Widget build(BuildContext context) {
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
                height: 22,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("Voting Weight"))
                ),
              
                Container(
                height: 22,
                color: const Color.fromARGB(0, 76, 175, 79),
                child:const Center(child: Text("Available Staked"))),
                   Container(
                height: 22,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("Total Staked"))),
                   Container(
                height: 22,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("Proposals Voted"))),
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
        children: <TableRow>[
          
          TableRow(
            children: <Widget>[
              Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child:  Padding(
                  padding: EdgeInsets.only(top:8.0,left:35),
                  child: Row(
                    children: [
                      Image.network(add1),
                      SizedBox(width: 10),
                      Text("tz1UVpbXS6pAtwPSQdQjPyPoGmVkCsNwn1K5", style: TextStyle(fontSize: 13),),
                      SizedBox(width: 10),
                      TextButton(onPressed: (){}, child: Icon(Icons.copy))
                    ],
                  ),
                ),
              ),
              Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("394213121"))
                ),
              
                Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child:const Center(child: Text("5000"))),
                   Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("5000"))),
                   Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("4"))),
            ],

          ),
          TableRow(
            children: <Widget>[
              Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child:  Padding(
                  padding: EdgeInsets.only(top:8.0,left:35),
                  child: Row(
                    children: [
                      Image.network(add2),
                      SizedBox(width: 10),
                      Text("tz1T5kk65F9oZw2z1YV4osfcrX7eD5KtLj3c", style: TextStyle(fontSize: 13),),
                      SizedBox(width: 10),
                      TextButton(onPressed: (){}, child: Icon(Icons.copy))
                    ],
                  ),
                ),
              ),
              Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("1524566"))
                ),
              
                Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child:const Center(child: Text("8888"))),
                   Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("8888"))),
                   Container(
                height: 42,
                color: const Color.fromARGB(0, 76, 175, 79),
                child: const Center(child: Text("1"))),
            ],

          )
         
          ],
        ),


      ],
    );
  }
}
