import 'package:flutter/material.dart';
import 'package:Homebase/utils/reusable.dart';
import '../entities/org.dart';

import 'package:flutter/services.dart';

class ViewConfig extends StatelessWidget {
  final Org org;

  const ViewConfig({super.key, required this.org});

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
              const Text("DAO configuration", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 30),
              Row(
                children: [
                  Text(
                      'DAO Contract Address: ${getShortAddress(org.address!)}'),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: org.address!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          duration: Duration(seconds: 1),
                          content: Center(
                              child: Text('Address copied to clipboard'))));
                    },
                    child: const Icon(Icons.copy),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Treasury Contract Address: ${getShortAddress(org.registryAddress!)}'),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: org.registryAddress!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          duration: Duration(seconds: 1),
                          content: Center(
                              child: Text('Address copied to clipboard'))));
                    },
                    child: const Icon(Icons.copy),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Token Contract Address: ${getShortAddress(org.govTokenAddress!)}'),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: org.govTokenAddress!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          duration: Duration(seconds: 1),
                          content: Center(
                              child: Text('Address copied to clipboard'))));
                    },
                    child: const Icon(Icons.copy),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Text('Quorum : ${org.quorum}%'),
              const SizedBox(height: 20),
              Text(
                  'Proposal Threshold: ${org.proposalThreshold} ${org.symbol}'),
              const SizedBox(height: 20),
              Text('Voting Duration (minutes): ${org.votingDuration}'),
              const SizedBox(height: 10),
              Text('Voting Delay (minutes): ${org.votingDelay}'),
              const SizedBox(height: 10),
              Text('Execution Delay (minutes): ${org.executionDelay / 60}'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
