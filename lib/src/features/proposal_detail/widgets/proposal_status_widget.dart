// lib/src/features/proposal_detail/widgets/proposal_status_widget.dart
import 'package:flutter/material.dart';
import 'package:werule/src/models/proposal.dart';

class ProposalStatusWidget extends StatelessWidget {
  final ProposalStatus status;

  const ProposalStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final properties = _getStatusProperties(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: properties['bgColor'],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: properties['borderColor']!, width: 0.8),
      ),
      child: Text(
        properties['text']!,
        style: TextStyle(
          color: properties['textColor'],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // THE FIX: Colors have been adjusted to be more faded and less vibrant.
  Map<String, dynamic> _getStatusProperties(ProposalStatus status) {
    switch (status) {
      case ProposalStatus.Active:
        return {
          'text': 'ACTIVE',
          'textColor': const Color.fromARGB(255, 213, 203, 255),
          'bgColor': const Color.fromARGB(255, 68, 55, 130),
          'borderColor': const Color.fromARGB(255, 96, 82, 173),
        };
      case ProposalStatus.Pending:
        return {
          'text': 'PENDING',
          'textColor': const Color.fromARGB(255, 221, 214, 161),
          'bgColor': const Color.fromARGB(255, 92, 87, 52),
          'borderColor': const Color.fromARGB(255, 126, 119, 74),
        };
      case ProposalStatus.Succeeded:
        return {
          'text': 'SUCCEEDED',
          'textColor': const Color.fromARGB(255, 189, 233, 206),
          'bgColor': const Color.fromARGB(255, 21, 50, 65),
          'borderColor': const Color.fromARGB(255, 28, 81, 56),
        };
      case ProposalStatus.Queued:
        return {
          'text': 'QUEUED',
          'textColor': const Color.fromARGB(255, 194, 233, 236),
          'bgColor': const Color.fromARGB(255, 50, 90, 95),
          'borderColor': const Color.fromARGB(255, 78, 121, 125),
        };
      case ProposalStatus.Executable:
         return {
          'text': 'EXECUTABLE',
          'textColor': const Color.fromARGB(255, 17, 71, 55),
          'bgColor': const Color.fromARGB(255, 190, 220, 200),
          'borderColor': const Color.fromARGB(255, 29, 102, 80),
        };
      case ProposalStatus.Executed:
        return {
          'text': 'EXECUTED',
          'textColor': const Color.fromARGB(255, 198, 228, 209),
          'bgColor': const Color.fromARGB(255, 50, 90, 65),
          'borderColor': const Color.fromARGB(255, 76, 124, 94),
        };
      case ProposalStatus.Expired:
        return {
          'text': 'EXPIRED',
          'textColor': Colors.grey.shade300,
          'bgColor': Colors.grey.shade800,
          'borderColor': Colors.grey.shade700,
        };
      case ProposalStatus.NoQuorum:
        return {
          'text': 'NO QUORUM',
          'textColor': const Color.fromARGB(255, 230, 230, 230),
          'bgColor': const Color.fromARGB(255, 82, 82, 82),
          'borderColor': Colors.grey.shade600,
        };
      case ProposalStatus.Rejected:
        return {
          'text': 'REJECTED',
          'textColor': const Color.fromARGB(255, 255, 203, 203),
          'bgColor': const Color.fromARGB(255, 87, 65, 64),
          'borderColor': const Color.fromARGB(255, 119, 57, 64),
        };
      case ProposalStatus.Defeated:
        return {
          'text': 'DEFEATED',
          'textColor': const Color.fromARGB(255, 252, 203, 203),
          'bgColor': const Color.fromARGB(255, 87, 65, 64),
          'borderColor': const Color.fromARGB(255, 119, 57, 64),
        };
      case ProposalStatus.Canceled:
         return {
          'text': 'CANCELED',
          'textColor': const Color.fromARGB(255, 252, 203, 203),
          'bgColor': const Color.fromARGB(255, 87, 65, 64),
          'borderColor': const Color.fromARGB(255, 119, 57, 64),
        };
      default: // Unknown
        return {
          'text': 'UNKNOWN',
          'textColor': Colors.white,
          'bgColor': Colors.grey[800],
          'borderColor': Colors.grey[700],
        };
    }
  }
}
// lib/src/features/proposal_detail/widgets/proposal_status_widget.dart