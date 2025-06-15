import 'dart:async';
import 'package:flutter/material.dart';

class Parent extends StatefulWidget {
  Parent({super.key});
  DateTime pending = DateTime.now();
  String status = "pending";

  @override
  State<Parent> createState() => _ParentState();
}

class _ParentState extends State<Parent> {
  int remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _updateStatus(); // Initial status update
  }

  void _updateStatus() {
    DateTime now = DateTime.now();

    // Define state transition times
    Map<String, DateTime> statusHistory = {
      "pending": widget.pending,
      "active": widget.pending.add(const Duration(seconds: 4)),
      "passed": widget.pending.add(const Duration(seconds: 8)),
      "executed": widget.pending.add(const Duration(seconds: 12)),
    };

    if (now.isAfter(statusHistory["active"]!) &&
        now.isBefore(statusHistory["passed"]!)) {
      widget.status = "active";
      remainingSeconds = statusHistory["passed"]!.difference(now).inSeconds;
    } else if (now.isAfter(statusHistory["passed"]!) &&
        now.isBefore(statusHistory["executed"]!)) {
      widget.status = "passed";
      remainingSeconds = statusHistory["executed"]!.difference(now).inSeconds;
    } else if (now.isAfter(statusHistory["executed"]!)) {
      widget.status = "executed";
      remainingSeconds = 0; // No countdown
    } else {
      widget.status = "pending";
      remainingSeconds = statusHistory["active"]!.difference(now).inSeconds;
    }

    setState(() {});
  }

  void _onCountdownComplete() {
    // Trigger state update to move to the next phase
    _updateStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.status,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 100),
            widget.status == "pending" ||
                    widget.status == "active" ||
                    widget.status == "passed"
                ? CNTDN(
                    remainingSeconds: remainingSeconds,
                    onCountdownComplete: _onCountdownComplete,
                  )
                : const Center(child: Text("Voting is over")),
          ],
        ),
      ),
    );
  }
}

class CNTDN extends StatefulWidget {
  const CNTDN(
      {super.key,
      required this.remainingSeconds,
      required this.onCountdownComplete});
  final int remainingSeconds;
  final VoidCallback onCountdownComplete;

  @override
  State<CNTDN> createState() => _CNTDNState();
}

class _CNTDNState extends State<CNTDN> {
  late Timer _timer;
  late int remainingSeconds;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.remainingSeconds;
    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant CNTDN oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remainingSeconds != oldWidget.remainingSeconds) {
      _timer.cancel();
      remainingSeconds = widget.remainingSeconds;
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        _timer.cancel();
        widget.onCountdownComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to prevent memory leaks.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildCountdownDisplay(),
    );
  }

  Widget _buildCountdownDisplay() {
    final days = remainingSeconds ~/ (24 * 3600);
    final hours = (remainingSeconds % (24 * 3600)) ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

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

    timeUnits.add(MapEntry("Seconds", seconds));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: timeUnits.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 238, 238, 238)),
              ),
              const SizedBox(height: 5),
              Text(
                _formatTime(entry.value),
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

String _formatTime(int value) => value.toString().padLeft(2, '0');
