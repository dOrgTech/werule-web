// lib/src/models/proposal.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Proposal {
  final String id; // The document ID
  final String author;
  final String title;
  final String description;
  final BigInt inFavor;
  final BigInt against;
  final DateTime createdAt;

  Proposal({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.inFavor,
    required this.against,
    required this.createdAt,
  });

  factory Proposal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Proposal(
      id: doc.id,
      author: data['author'] ?? 'Unknown Author',
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No Description',
      inFavor: BigInt.tryParse(data['inFavor'] ?? '0') ?? BigInt.zero,
      against: BigInt.tryParse(data['against'] ?? '0') ?? BigInt.zero,
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }
}
// lib/src/models/proposal.dart