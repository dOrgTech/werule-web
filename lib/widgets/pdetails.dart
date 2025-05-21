import 'dart:async';
import 'package:flutter/material.dart';
import '../entities/proposal.dart'; // Import your Proposal class

class PDetails extends StatefulWidget {
  final Proposal p;

  const PDetails({super.key, required this.p});

  @override
  State<PDetails> createState() => _PDetailsState();
}

class _PDetailsState extends State<PDetails> {
  Timer? _statusCheckTimer;
  int _remainingSeconds = 320; // Example: 3 days in seconds

  @override
  void initState() {
    super.initState();

    // Start the countdown timer
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _statusCheckTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  String _formatTime(int value) => value.toString().padLeft(2, '0');

  // Helper method to format the countdown as days, hours, minutes, and seconds
  Widget _buildCountdownDisplay() {
    final days = _remainingSeconds ~/ (24 * 3600);
    final hours = (_remainingSeconds % (24 * 3600)) ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    // Determine which units to display based on the remaining time
    final timeUnits = <MapEntry<String, int>>[];

    if (days > 0) {
      timeUnits.add(MapEntry("Days", days));
      timeUnits.add(MapEntry("Hours", hours));
      timeUnits.add(MapEntry("Minutes", minutes));
    } else if (hours > 0) {
      timeUnits.add(MapEntry("Hours", hours));
      timeUnits.add(MapEntry("Minutes", minutes));
    } else if (minutes > 0) {
      timeUnits.add(MapEntry("Minutes", minutes));
    }
    // Always show seconds as the smallest unit
    timeUnits.add(MapEntry("Seconds", seconds));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: timeUnits.map((entry) {
        return Column(
          children: [
            Text(
              entry.key,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(entry.value),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    String stage = widget.p.stage.toString().split(".").last;
    if (stage == "noQuorum") {
      stage = "no quorum";
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Proposal Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.p.name ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.p.description ?? 'No Description',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Created At: ${widget.p.createdAt?.toString() ?? 'No Date'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Type: ${widget.p.type ?? 'No Type'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: ${widget.p.statusHistory.toString()}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            widget.p.statusPill(stage, context),
            const SizedBox(height: 20),
            const Text(
              "Countdown Timer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCountdownDisplay(), // Display countdown here
          ],
        ),
      ),
    );
  }
}
