// lib/src/features/proposal_detail/widgets/proposal_lifecycle_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_status_widget.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/proposal_detail_provider.dart';

class ProposalLifecycleCard extends StatelessWidget {
  final Proposal proposal;
  const ProposalLifecycleCard({super.key, required this.proposal});

  @override
  Widget build(BuildContext context) {
    // THE FIX: Read the full, calculated timeline from the provider.
    final timeline = context.select<ProposalDetailProvider, Map<ProposalStatus, DateTime>>((p) => p.fullTimeline);

    // Convert map to a list of entries and sort by date.
    final sortedEntries = timeline.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Card(
      color: const Color(0xff2c2c2c),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
        // THE FIX: Use ListView.builder for dynamic content, mimicking the old design.
        child: ListView.builder(
          // These properties are important when a ListView is inside a SingleChildScrollView
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            final status = entry.key;
            final date = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 9.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProposalStatusWidget(status: status),
                  Text(
                    DateFormat.yMMMd().add_jm().format(date),
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/proposal_lifecycle_card.dart