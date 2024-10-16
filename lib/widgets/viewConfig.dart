import 'package:flutter/material.dart';

import '../entities/org.dart';
import '../screens/creator.dart';


class ViewConfig extends StatelessWidget {
  final Org org;

  ViewConfig({
    required this.org
  });

  @override
  Widget build(BuildContext context) {
    // Helper function to format durations
    String formatDuration(Duration? duration) {
      if (duration == null) return 'Not set';
      int days = duration.inDays;
      int hours = duration.inHours % 24;
      int minutes = duration.inMinutes % 60;
      return '$days days, $hours hours, $minutes minutes';
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text('Contract Address: ${org.address}'),
              SizedBox(height: 10),
              SizedBox(height: 20),
              Text('Quorum Threshold: ${org.quorum}%'),
              SizedBox(height: 10),
              Text('Supermajority: ${org.supermajority}%'),
              SizedBox(height: 20),
              Text('Voting Duration (minutes): ${org.votingDuration}'),
              SizedBox(height: 10),
              Text('Voting Delay (minutes): ${org.votingDelay}'),
              SizedBox(height: 10),
              Text('Execution Availability (minutes): ${org.executionAvailability}'),
              SizedBox(height: 20),
             
            ],
          ),
        ),
      ),
    );
  }
}