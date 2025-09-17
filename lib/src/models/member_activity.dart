// lib/src/models/member_activity.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberActivity {
  final List<String> proposalsCreated;
  final List<String> proposalsVoted;

  MemberActivity({
    required this.proposalsCreated,
    required this.proposalsVoted,
  });

  factory MemberActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MemberActivity(
      proposalsCreated: List<String>.from(data['proposalsCreated'] ?? []),
      proposalsVoted: List<String>.from(data['proposalsVoted'] ?? []),
    );
  }

  // A factory for when a member document doesn't exist yet.
  factory MemberActivity.empty() {
    return MemberActivity(proposalsCreated: [], proposalsVoted: []);
  }
}
// lib/src/models/member_activity.dart