import 'package:flutter/material.dart';


class ActionLabel extends StatefulWidget {
  final String status;

  const ActionLabel({super.key, 
    required this.status,
  });

  @override
  _ActionLabelState createState() => _ActionLabelState();
}

class _ActionLabelState extends State<ActionLabel> {
  @override
  void initState() {}

  String _getStatusLabel() {
    switch (widget.status) {
      case 'pending':
        return "Voting starts in:";
      case 'active':
        return "Time left to vote:";
      case 'queued':
        return "Execution available in";
      case 'passed':
        return "Queue for execution";
      case 'executed':
        return "Proposal executed";
      default:
        return "Voting concluded";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: _getStatusLabel() == "Voting concluded" ? 80 : 0),
          SizedBox(
            height: 55,
            child: Center(
              child: Text(
                _getStatusLabel(),
                style: TextStyle(
                  color: _getStatusLabel() == "Voting concluded"
                      ? Colors.grey
                      : Theme.of(context).indicatorColor,
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
