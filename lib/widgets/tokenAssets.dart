import 'package:Homebase/utils/reusable.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../entities/org.dart';
String add1="https://i.ibb.co/2WbL5nC/add1.png";
String add2="https://i.ibb.co/6rmksXk/add2.png";
List<String> userPics=[add1, add2];

class TokenAssets extends StatefulWidget {
  Org org;
  int status=0;
  TokenAssets({super.key, required this.org});

  @override
  State<TokenAssets> createState() => _TokenAssetsState();
}

class _TokenAssetsState extends State<TokenAssets> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom:28.0, left:9,right: 9),
        child: Column(
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
                        hintText: 'Find token by name or address',
                        // other properties
                      ),
                      // other properties
                    ),
                ),
             const Spacer(),
               Container(
                      padding: EdgeInsets.only(right: 50),
                      height: 40,
                      child: 
                      
                     ToggleSwitch(
                initialLabelIndex: widget.status,
                totalSwitches: 2,
                minWidth: 120,
                borderWidth: 1.5,
                activeFgColor: Theme.of(context).indicatorColor,
                inactiveFgColor: Color.fromARGB(255, 189, 189, 189),
                activeBgColor: [Color.fromARGB(255, 77, 77, 77)],
                inactiveBgColor: Theme.of(context).cardColor,
                borderColor: [Theme.of(context).cardColor],
                labels: ['Tokens','NFTs'],
                onToggle: (index) {
                  print('switched to: $index');
                 
            setState(() {
              widget.status=index!;
            });
              },
            )
                      
                    ),
            ],
          )
        ),
         SizedBox(height: 15),
            Table(
  border: TableBorder.all(
    color: Colors.transparent,
  ),
  columnWidths: const <int, TableColumnWidth>{
     0: FlexColumnWidth(1.8),  // Left-most item stays as is
    1: FlexColumnWidth(0.3),  // Slightly reduce column width for SYMBOL
    2: FlexColumnWidth(1.2),  // Slightly reduce column width for AMOUNT
    3: FlexColumnWidth(1.4),  // Slightly reduce column width for ADDRESS
    4: FixedColumnWidth(150), //// Extra space for the button
  },
  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
  children: <TableRow>[
    // Header row
    TableRow(
      children: <Widget>[
        Container(
          height: 22,
          color: const Color.fromARGB(0, 76, 175, 79),
          child: const Padding(
            padding: EdgeInsets.only(top: 4.0, left: 75),
            child: Text("TOKEN NAME",
            style: TextStyle(fontWeight: FontWeight.w100),
            ),
          ),
        ),
        Container(
          height: 22,
          color: const Color.fromARGB(0, 76, 175, 79),
          child: const Center(child: Text("SYMBOL")),
        ),
        Container(
          height: 22,
          color: const Color.fromARGB(0, 76, 175, 79),
          child: const Center(child: Text("AMOUNT")),
        ),
        Container(
          height: 22,
          color: const Color.fromARGB(0, 76, 175, 79),
          child: const Center(child: Text("ADDRESS")),
        ),
        // Empty header for button
        Container(
          height: 22,
          color: const Color.fromARGB(0, 76, 175, 79),
          child: const Center(child: Text("")),
        ),
      ],
    ),
  ],
),

const Opacity(
  opacity: 0.5,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 29.0),
    child: Divider(),
  ),
),

Table(
  border: TableBorder.all(
    color: Colors.transparent,
  ),
  columnWidths: const <int, TableColumnWidth>{
   0: FlexColumnWidth(1.8),  // Left-most item stays as is
    1: FlexColumnWidth(0.3),  // Slightly reduce column width for SYMBOL
    2: FlexColumnWidth(1.2),  // Slightly reduce column width for AMOUNT
    3: FlexColumnWidth(1.4),  // Slightly reduce column width for ADDRESS
    4: FixedColumnWidth(150), // Extra space for the button with more padding
  },
  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
  children: <TableRow>[
    TableRow(
      children: <Widget>[
        Container(
          height: 42,
          color: const Color.fromARGB(0, 76, 175, 79),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left:60.0),
              child: Text("Name of the Token"),
            ),
          ),
        ),
        Container(
          height: 42,
          color: const Color.fromARGB(0, 76, 175, 79),
          child: const Center(child: Text("SYM")),
        ),
        Container(
          height: 42,
          color: const Color.fromARGB(0, 76, 175, 79),
          child: const Center(child: Text("5001230")),
        ),
        Container(
          height: 42,
          color: const Color.fromARGB(0, 76, 175, 79),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: 
                Image.network(
                  add1,
                  height: 24, 
                )),
                const SizedBox(width: 10),
                Text(
                  getShortAddress("tz1UVpbXS6pAtwPSQdQjPyPoGmVkCsNwn1K5"),
                  style: TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {},
                  child: const Icon(Icons.copy),
                ),
              ],
            ),
          ),
        ),
        // ElevatedButton with more padding on the right
        Container(
          width: 60,
          color: const Color.fromARGB(0, 76, 175, 79),
          child: Padding(
            padding: const EdgeInsets.only(right: 40), // Adding right padding
            child: ElevatedButton(
              onPressed: () {
                // Transfer logic
              },
              child: const Text("Transfer"),
            ),
          ),
        ),
      ],
    ),
  ],
)

 ]     ),
     ) );
  }
}
