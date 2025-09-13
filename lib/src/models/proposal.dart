// lib/src/models/proposal.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web3dart/crypto.dart'; // THE FIX: Import for bytesToHex utility.

enum ProposalStatus {
  Pending,
  Active,
  Canceled,
  Defeated,
  Succeeded,
  Queued,
  Expired,
  Executed,
  // Custom states derived from Defeated
  Rejected, // Voted against
  NoQuorum, // Not enough votes
  // Custom state derived from Queued
  Executable,
  // Fallback
  Unknown,
}

class ProposalTimelineEntry {
  final String status;
  final DateTime timestamp;

  ProposalTimelineEntry({required this.status, required this.timestamp});
}

class Proposal {
  final String id; // The document ID
  final String author;
  final String title;
  final String description;
  final BigInt inFavor;
  final BigInt against;
  final DateTime createdAt;
  final Map<String, DateTime> statusHistory;
  final String? type;
  final List<String> targets;
  final List<String> callDatas;
  final String? externalResource;

  Proposal({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.inFavor,
    required this.against,
    required this.createdAt,
    required this.statusHistory,
    this.type,
    required this.targets,
    required this.callDatas,
    this.externalResource,
  });

  factory Proposal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final Map<String, DateTime> history = {};
    if (data['statusHistory'] is Map) {
      (data['statusHistory'] as Map).forEach((key, value) {
        if (value is Timestamp) {
          history[key] = value.toDate();
        }
      });
    }

    // THE FIX: Process `callDatas` to handle both String and Blob types.
    final rawCallDatas = data['callDatas'] as List<dynamic>? ?? [];
    final List<String> processedCallDatas = [];
    for (final item in rawCallDatas) {
      if (item is String) {
        processedCallDatas.add(item);
      } else if (item is Blob) {
        // A Blob from Firestore contains raw bytes. Convert them to a hex string.
        // The bytesToHex function from web3dart's crypto utility is perfect for this.
        processedCallDatas.add(bytesToHex(item.bytes, include0x: true));
      }
    }

    return Proposal(
      id: doc.id,
      author: data['author'] ?? 'Unknown Author',
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No Description',
      inFavor: BigInt.tryParse(data['inFavor']?.toString() ?? '0') ?? BigInt.zero,
      against: BigInt.tryParse(data['against']?.toString() ?? '0') ?? BigInt.zero,
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      statusHistory: history,
      type: data['type'],
      targets: List<String>.from(data['targets'] ?? []),
      callDatas: processedCallDatas, // Use the safely processed list.
      externalResource: data['externalResource'],
    );
  }

  // Helper to get a sorted timeline
  List<ProposalTimelineEntry> get sortedTimeline {
    final entries = statusHistory.entries
        .map((e) => ProposalTimelineEntry(status: e.key, timestamp: e.value))
        .toList();
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }
}
// lib/src/models/proposal.dart