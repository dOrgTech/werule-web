import 'dart:async';
import 'package:flutter/material.dart';

class Parent extends StatefulWidget {
  Parent({super.key});
  DateTime pending = DateTime.now();
  String? status;
  int? remainingSeconds;

  @override
  State<Parent> createState() => _ParentState();
}

class _ParentState extends State<Parent> {
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _updateStatus();
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateStatus();
    });
  }

  void _updateStatus() {
    String newStatus = "";
    DateTime now = DateTime.now();

    Map statushistory = {
      "pending": widget.pending,
      "active": widget.pending.add(Duration(seconds: 4)),
      "passed": widget.pending.add(Duration(seconds: 8)),
      "executed": widget.pending.add(Duration(seconds: 12))
    };

    if (now.isAfter(statushistory['active'])) {
      if (now.isBefore(statushistory['passed'])) {
        newStatus = "active";
        widget.remainingSeconds =
            statushistory['passed'].difference(now).inSeconds;
      } else {
        if (now.isBefore(statushistory['executed'])) {
          newStatus = "passed";
          widget.remainingSeconds =
              statushistory['executed'].difference(now).inSeconds;
        } else {
          newStatus = "executed";
          widget.remainingSeconds = 0; // No more countdown
        }
      }
    } else {
      newStatus = "pending";
      widget.remainingSeconds =
          statushistory['active'].difference(now).inSeconds;
    }

    if (widget.status != newStatus || widget.remainingSeconds == 0) {
      setState(() {
        widget.status = newStatus;
      });
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
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
              widget.status ?? "unknown",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 100),
            widget.status == "pending" ||
                    widget.status == "active" ||
                    widget.status == "passed"
                ? CNTDN(
                    key: ValueKey(widget.remainingSeconds),
                    remainingSeconds: widget.remainingSeconds!,
                  )
                : Center(child: Text("Voting is over")),
          ],
        ),
      ),
    );
  }
}

class CNTDN extends StatefulWidget {
  CNTDN({super.key, required this.remainingSeconds});
  int remainingSeconds;

  @override
  State<CNTDN> createState() => _CNTDNState();
}

class _CNTDNState extends State<CNTDN> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.remainingSeconds > 0) {
        setState(() {
          widget.remainingSeconds--;
        });
      } else {
        _timer.cancel();
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
    final days = widget.remainingSeconds ~/ (24 * 3600);
    final hours = (widget.remainingSeconds % (24 * 3600)) ~/ 3600;
    final minutes = (widget.remainingSeconds % 3600) ~/ 60;
    final seconds = widget.remainingSeconds % 60;

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
