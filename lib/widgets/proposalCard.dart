import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../screens/proposalDetails.dart';

import '../entities/org.dart';
import '../entities/proposal.dart';
import '../screens/dao.dart';

class ProposalCard extends StatelessWidget {
  ProposalCard({super.key,required this.proposal, required this.org});
  Proposal proposal;
  Org org;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:8.0),
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: (){
              print("tapped on proposalCard");
              Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => 
                DAO(InitialTabIndex: 1,org:org,
                proposalId:proposal.id,
                )));
            },
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:25.0),
                  child: Container(
                    width: 90,
                    child:  Text(proposal.id.toString())),
                ),
                Expanded(
                  child: Padding(
                     padding: const EdgeInsets.only(left:8.0),
                     child: Text(proposal.name!),
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
                SizedBox(width: 150, child: Center(child: Text(proposal.type!))),
                Container(
                  padding: EdgeInsets.only(right:10),
                  height: 20,
                  // width: 100,
                  child: Center(child: proposal.statusPill(
                    proposal.statusHistory.entries
                      .reduce((a, b) => a.value.isAfter(b.value) ? a : b)
                      .key,
                    context))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}