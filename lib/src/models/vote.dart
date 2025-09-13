// lib/src/models/vote.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Vote {
  final String voter;
  final int option; // e.g., 0 for against, 1 for for
  final String weight;
  final DateTime castAt;

  Vote({
    required this.voter,
    required this.option,
    required this.weight,
    required this.castAt,
  });

  factory Vote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vote(
      voter: data['voter'] ?? 'Unknown Voter',
      option: data['option'] ?? -1,
      weight: data['weight']?.toString() ?? '0',
      castAt: (data['castAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }
}
// lib/src/models/vote.dart