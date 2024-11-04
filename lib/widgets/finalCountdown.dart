import 'dart:async';
import 'package:flutter/material.dart';

class CountdownWidget extends StatelessWidget {
  final int remainingSeconds;

  CountdownWidget({Key? key, required this.remainingSeconds}) : super(key: key);

  String _formatTime(int value) => value.toString().padLeft(2, '0');

  Map<String, String> get _formattedCountdown {
    final days = remainingSeconds ~/ (24 * 3600);
    final hours = (remainingSeconds % (24 * 3600)) ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    return {
      'Days': _formatTime(days),
      'Hours': _formatTime(hours),
      'Minutes': _formatTime(minutes),
      'Seconds': _formatTime(seconds),
    };
  }

  @override
  Widget build(BuildContext context) {
    final countdownData = _formattedCountdown;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: countdownData.entries.map((entry) {
        return Column(
          children: [
            Text(
              entry.key,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              entry.value,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class PDetails extends StatefulWidget {
  @override
  State<PDetails> createState() => _PDetailsState();
}

class _PDetailsState extends State<PDetails> {
  Timer? _statusCheckTimer;
  int _remainingSeconds = 259200; // For example, 3 days in seconds

  @override
  void initState() {
    super.initState();

    // Initialize and start the timer
    _statusCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Proposal Details")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Countdown Timer", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            CountdownWidget(
                remainingSeconds:
                    _remainingSeconds), // Pass the updated remainingSeconds
          ],
        ),
      ),
    );
  }
}