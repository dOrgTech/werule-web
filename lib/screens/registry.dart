import 'package:flutter/material.dart';
import '../entities/org.dart';
import '../widgets/initiative.dart';
import '../widgets/regitemCard.dart';
import '../entities/proposal.dart';

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
                  padding: const EdgeInsets.only(left: 50),
                  width: 500,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(width: 0.1),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search by Key',
                      // other properties
                    ),
                    // other properties
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(right: 50),
                  height: 40,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).indicatorColor)),
                    onPressed: () {
                      Proposal p = Proposal(org: widget.org);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: const Padding(
                                padding: EdgeInsets.only(left: 18.0),
                                child: Text("Edit Registry"),
                              ),
                              content: Initiative(org: widget.org));
                        },
                      );
                    },
                    child: Text(
                      "Add/Edit Item",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            )),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Container(
                    padding: const EdgeInsets.only(left: 15),
                    width: 140,
                    child: const Text("Key")),
              ),
              Expanded(
                child: SizedBox(
                    width: 230,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 48.0),
                      child: Text("Value"),
                    )),
              ),
              const SizedBox(width: 150, child: Center(child: Text(" "))),
              const SizedBox(width: 150, child: Center(child: Text(""))),
            ],
          ),
        ),
        const Divider(),
        ...items
      ],
    );
  }
}
