import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';

class NewProposal extends StatefulWidget {
  NewProposal({super.key, required this.p, required this.next});
  Proposal p;
  int stage = 0;
  var next;
  @override
  State<NewProposal> createState() => _NewProposalState();
}

class _NewProposalState extends State<NewProposal> {
  @override
  Widget build(BuildContext context) {
    return setInfo();
  }

  Widget everything() {
    return Container();
  }

  Widget setInfo() {
    return Container(
        padding: EdgeInsets.all(30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            width: 460, // Ensure consistent width
            child: TextField(
              onChanged: (value) {
                widget.p.name = value;
              },
              maxLength: 42,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "Proposal Title",
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 460, // Ensure consistent width
            child: TextField(
              onChanged: (value) {
                widget.p.description = value;
              },
              maxLength: 200,
              maxLines: 5,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "Proposal Description",
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 460, // Ensure consistent width
            child: TextField(
              onChanged: (value) {
                widget.p.externalResource = value;
              },
              maxLength: 42,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: "Discussion URL",
              ),
            ),
          ),
          const SizedBox(height: 130),
          ElevatedButton(
              onPressed: widget.next,
              child: SizedBox(
                  width: 120,
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Next"),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward)
                    ],
                  ))))
        ]));
  }
}
