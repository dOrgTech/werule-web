import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:async';
import 'package:provider/provider.dart';

enum ElephantStatus { pending, voting, executionPending, executed }

class Elephant {
  final DateTime startTime;
  final Duration votingPeriod;
  final Duration executionDelay;

  Elephant({
    required this.startTime,
    required this.votingPeriod,
    required this.executionDelay,
  });

  ElephantStatus get status {
    final now = DateTime.now();
    if (now.isBefore(startTime)) return ElephantStatus.pending;
    if (now.isBefore(startTime.add(votingPeriod))) return ElephantStatus.voting;
    if (now.isBefore(startTime.add(votingPeriod).add(executionDelay)))
      return ElephantStatus.executionPending;
    return ElephantStatus.executed;
  }
}

class ElephantStatusWidget extends StatefulWidget {
  final Elephant elephant; // Accept an Elephant instance

  ElephantStatusWidget({required this.elephant});

  @override
  _ElephantStatusWidgetState createState() => _ElephantStatusWidgetState();
}

class _ElephantStatusWidgetState extends State<ElephantStatusWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoUpdate();
  }

  void _startAutoUpdate() {
    _timer = Timer.periodic(Duration(seconds: 10), (_) {
      setState(() {}); // Triggers a rebuild to reflect the updated status
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.elephant.status;

    return Text(
      'Proposal Status: ${status.toString().split('.').last}',
      style: TextStyle(fontSize: 24),
    );
  }
}
