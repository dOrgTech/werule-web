import 'package:flutter/material.dart';
import 'package:Homebase/utils/reusable.dart';
import '../entities/org.dart';
import '../screens/creator.dart';

import 'package:flutter/services.dart';

class ViewConfig extends StatelessWidget {
  final Org org;

  ViewConfig({required this.org});

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
              Row(
                children: [
                  Text('Contract Address: ' + getShortAddress(org.address!)),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: org.address!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          duration: Duration(seconds: 1),
                          content: Center(
                              child: Text('Address copied to clipboard'))));
                    },
                    child: Icon(Icons.copy),
                  )
                ],
              ),
              SizedBox(height: 10),
              SizedBox(height: 20),
              Text('Quorum Threshold: ${org.quorum}%'),
              SizedBox(height: 20),
              Text('Voting Duration (minutes): ${org.votingDuration}'),
              SizedBox(height: 10),
              Text('Voting Delay (minutes): ${org.votingDelay}'),
              SizedBox(height: 10),
              Text('Execution Availability (minutes): ${org.executionDelay}'),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
