import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ProposalCard extends StatelessWidget {
  const ProposalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:8.0),
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: (){},
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:25.0),
                  child: Container(
                    width: 90,
                    child: Text("431")),
                ),
                Expanded(
                  child: Padding(
                     padding: const EdgeInsets.only(left:8.0),
                     child: Text("Title of the proposal max 80 characters"),
                   ),
                ),
                Container(
                  width: 230,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("0x3a84...3eds0"),
                      TextButton(onPressed: (){}, child: Icon(Icons.copy))
                    ],
                  )),
                SizedBox(width:150,child: Center(child: Text("6/8/2022 11:43"))),
                SizedBox(width: 150, child: Center(child: Text("Transfer"))),
                SizedBox(width:100, child: Center(child: Text("ACTIVE"))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}