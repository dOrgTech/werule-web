import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../widgets/tokenCard.dart';
import 'package:toggle_switch/toggle_switch.dart';

class Treasury extends StatefulWidget {
  const Treasury({super.key});
  @override
  State<Treasury> createState() => _TreasuryState();
}
class _TreasuryState extends State<Treasury> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        SizedBox(
          height: 120,
          child:Row(
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
                        hintText: 'Search by Token Symbol',
                        // other properties
                      ),
                      // other properties
                    ),
                ),
              const Spacer(),
            SizedBox(
              height: 32,
              child: ToggleSwitch(
                initialLabelIndex: 0,
                totalSwitches: 3,
                borderWidth: 1.5,
                activeBgColor: [Theme.of(context).cardColor],
                inactiveBgColor: Theme.of(context).canvasColor,
                borderColor: [Theme.of(context).cardColor],
                labels: const ['All', 'Tokens', 'NFTs'],
                onToggle: (index) {
                  print('switched to: $index');
              },
            ),
            ),
             const Spacer(),
               Container(
                      padding: const EdgeInsets.only(right: 50),
                      height: 40,
                      child: ElevatedButton(
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).indicatorColor)),
                        onPressed: (){},
                        child: Text("Propose Transfer",
                        style: TextStyle(fontSize: 16),
                        ),),
                    ),
            ],
          )
        ),
       const SizedBox(height: 31),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            TokenCard(),TokenCard(),TokenCard(),TokenCard(),TokenCard(),
          ],
        )
      ],
    );
  }
}