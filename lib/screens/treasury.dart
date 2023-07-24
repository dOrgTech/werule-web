import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:homebase/widgets/tokenCard.dart';
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
              // Padding(
              //   padding: const EdgeInsets.only(left:28.0),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text("DAO Contract Address", style: TextStyle(fontSize: 19),),
              //       SizedBox(height: 11),
              //       Row(
              //         children: [
              //           Text("KT1LyPqdRVBFdQvhjyybG5osRCXnGSrk15M5"),
              //           const SizedBox(width: 20,),
              //           TextButton(
              //             onPressed: (){},
              //             child: const Icon(Icons.copy)),
              //         ],
              //       )
              //     ],
              //   ),
              // ),
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
                        hintText: 'Search by Token Symbol',
                        // other properties
                      ),
                      // other properties
                    ),
                ),
              Spacer(),
            SizedBox(
              height: 32,
              child: ToggleSwitch(
                initialLabelIndex: 0,
                totalSwitches: 3,
                borderWidth: 1.5,
                activeBgColor: [Theme.of(context).cardColor],
                inactiveBgColor: Theme.of(context).canvasColor,
                borderColor: [Theme.of(context).cardColor],
                labels: ['All', 'Tokens', 'NFTs'],
                onToggle: (index) {
                  print('switched to: $index');
              },
            ),
            ),
             const Spacer(),
               Container(
                      padding: EdgeInsets.only(right: 50),
                      height: 40,
                      child: ElevatedButton(
                        child: Text("Propose Transfer",
                        style: TextStyle(fontSize: 16),
                        ),
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).indicatorColor)),
                        onPressed: (){},),
                    ),
            ],
          )
        ),
       const SizedBox(height: 31),
        Wrap(
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