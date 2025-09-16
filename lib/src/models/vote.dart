// lib/src/models/vote.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Vote {
  final String voter;
  final int option;
  final String weight;
  final DateTime castAt;
  final String hash;

  Vote({
    required this.voter,
    required this.option,
    required this.weight,
    required this.castAt,
    required this.hash,
  });

  factory Vote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    DateTime parsedDate;
    try {
      // THE FIX: Read the 'cast' field which is a String, and parse it.
      final dateString = data['cast'] as String?;
      if (dateString != null) {
        parsedDate = DateTime.parse(dateString);
      } else {
        parsedDate = DateTime.now(); // Fallback if field is missing
      }
    } catch (e) {
      // Fallback if parsing fails for any reason
      parsedDate = DateTime.now();
    }

    return Vote(
      voter: data['voter'] ?? 'Unknown Voter',
      option: data['option'] ?? -1,
      weight: data['weight']?.toString() ?? '0',
      castAt: parsedDate,
      hash: data['hash'] ?? '',
    );
  }
}
// lib/src/models/vote.dart