import 'dart:async';
import 'package:flutter/material.dart';

import '../screens/proposalDetails.dart';

class CountdownTimerWidget extends StatefulWidget {
  final Duration duration;
  final String status;
  ProposalDetailsState stare; // Parent state to update

  CountdownTimerWidget({
    required this.stare,
    required this.duration,
    required this.status,
  });

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Duration remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.duration;
    if (widget.status == 'active' || widget.status == 'pending' || widget.status == 'executable') {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime -= Duration(seconds: 1);
        } else {
          _timer?.cancel();
          widget.stare.setState(() {
            widget.stare.widget.p.statusHistory.addAll({"active": DateTime.now()});
          }); // Trigger parent state update
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final blocks = (duration.inSeconds / 5).ceil();
    return "${days}d ${hours}h ${minutes}m ($blocks blocks)";
  }

  String _getStatusLabel() {
    switch (widget.status) {
      case 'pending':
        return "Voting starts in";
      case 'active':
        return "Time left to vote";
      case 'executable':
        return "Time left to execute";
      case 'passed':
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
          const Icon(
            Icons.hourglass_bottom,
            size: 50,
          ),
          Column(
            children: [
              Text(
                _getStatusLabel(),
                style: TextStyle(
                  color: Theme.of(context).indicatorColor,
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 10),
              if (widget.status == 'active' || widget.status == 'pending' || widget.status == 'executable')
                Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Text(
                    _formatTime(remainingTime),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
