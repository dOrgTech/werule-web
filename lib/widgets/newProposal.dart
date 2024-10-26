import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../entities/org.dart';
import '../entities/proposal.dart';

class NewProposal extends StatefulWidget {
  NewProposal({super.key, required this.org});
  late Proposal p;
  Org org;
  
  @override
  State<NewProposal> createState() => _NewProposalState();
}

class _NewProposalState extends State<NewProposal> {
  
  @override
  Widget build(BuildContext context) {
    Proposal p=Proposal(org: widget.org, type: "transfer");

    return Container(
      width: 400,
      height: 400,
      child: Center(child: ElevatedButton(
        child: Text("Submit"),
        onPressed: (){
          
        },
      )),
    );
  }
}