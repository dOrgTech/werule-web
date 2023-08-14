import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../widgets/menu.dart';

class ProposalDetails extends StatefulWidget {
  const ProposalDetails({super.key});

  @override
  State<ProposalDetails> createState() => _ProposalDetailsState();
}

class _ProposalDetailsState extends State<ProposalDetails> {
  @override
  Widget build(BuildContext context) {
    return  Container(
          alignment: Alignment.topCenter,
          child: ListView( // Start of ListView
            shrinkWrap: true, // Set this property to true
            children: [
              Column( // Start of Column
                crossAxisAlignment: CrossAxisAlignment.center, // Set this property to center the items horizontally
                mainAxisSize: MainAxisSize.min, // Set this property to make the column fit its children's size vertically
                children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 80, 
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 1200),
                      child:Text("Text"))])])
                      
              );
  }
}