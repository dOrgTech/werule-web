// lib/src/models/account_details.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountDetails {
  final List<String> proposalsCreated;
  final List<String> proposalsVoted;

  AccountDetails({
    required this.proposalsCreated,
    required this.proposalsVoted,
  });

  factory AccountDetails.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AccountDetails(
      proposalsCreated: List<String>.from(data['proposalsCreated'] ?? []),
      proposalsVoted: List<String>.from(data['proposalsVoted'] ?? []),
    );
  }

  // A factory for when a member document doesn't exist yet.
  factory AccountDetails.empty() {
    return AccountDetails(proposalsCreated: [], proposalsVoted: []);
  }
}
// lib/src/models/account_details.dart