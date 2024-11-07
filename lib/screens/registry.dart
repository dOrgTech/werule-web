import 'package:flutter/material.dart';

import '../entities/org.dart';
import '../widgets/regitemCard.dart';

class Registry extends StatefulWidget {
  Org org;
  Registry({super.key, required this.org});

  @override
  State<Registry> createState() => _RegistryState();
}

class _RegistryState extends State<Registry> {
  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    widget.org.registry.forEach(
      (key, value) {
        items.add(
          RegItemCard(
            itemKey: key,
            itemValue: value,
          ),
        );
      },
    );
    return Column(
      children: [
        SizedBox(
            height: 120,
            child: Row(
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
                    child: Text(
                      "Add/Edit Item",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).indicatorColor)),
                    onPressed: () {},
                  ),
                ),
              ],
            )),
        SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Container(
                    padding: EdgeInsets.only(left: 15),
                    width: 140,
                    child: Text("Key")),
              ),
              Expanded(
                child: Container(
                    width: 230,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 48.0),
                      child: Text("Value"),
                    )),
              ),
              SizedBox(width: 150, child: Center(child: Text("Last Updated"))),
              SizedBox(width: 150, child: Center(child: Text(""))),
            ],
          ),
        ),
        Divider(),
        ...items
      ],
    );
  }
}
