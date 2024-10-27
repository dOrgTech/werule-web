import 'package:flutter/material.dart';
import '../entities/org.dart';
import '../widgets/membersList.dart';
import '../widgets/voteConcentration.dart';


class Members extends StatefulWidget {
   Members({super.key, required this.org});
  Org org;
  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20),
         SizedBox(
          height: 230,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        hintText: 'Find user by address',
                        // other properties
                      ),
                      // other properties
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right:38.0),
                  child: VotingPowerWidget(),
                )
                
                ])),
       const SizedBox(height: 30),

        MembersList(org:widget.org), 
      ],
    );
  }
}