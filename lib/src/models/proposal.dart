// lib/src/models/proposal.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:web3dart/crypto.dart'; 

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
  final String id;
  final String author;
  final String title;
  final String description;
  final BigInt inFavor;
  final BigInt against;
  final DateTime createdAt;
  final Map<String, DateTime> statusHistory;
  final String? type;
  final List<String> targets;
  final List<String> values; // THE FIX: Added this missing field.
  final List<String> callDatas;
  final String? externalResource;
  final String totalSupply;
  final int votesFor;
  final int votesAgainst;
  final String? executionHash;

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
    required this.values,
    required this.callDatas,
    this.externalResource,
    required this.totalSupply,
    required this.votesFor,
    required this.votesAgainst,
    this.executionHash,
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

    final rawCallDatas = data['callDatas'] as List<dynamic>? ?? [];
    final List<String> processedCallDatas = [];
    for (final item in rawCallDatas) {
      if (item is String) {
        processedCallDatas.add(item);
      } else if (item is Blob) {
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
      values: List<String>.from(data['values'] ?? []), // THE FIX: Hydrate from Firestore.
      callDatas: processedCallDatas,
      externalResource: data['externalResource'],
      totalSupply: data['totalSupply']?.toString() ?? '0',
      votesFor: data['votesFor'] ?? 0,
      votesAgainst: data['votesAgainst'] ?? 0,
      executionHash: data['executionHash'],
    );
  }

  List<ProposalTimelineEntry> get sortedTimeline {
    final entries = statusHistory.entries
        .map((e) => ProposalTimelineEntry(status: e.key, timestamp: e.value))
        .toList();
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is Proposal &&
        other.id == id &&
        other.inFavor == inFavor &&
        other.against == against &&
        other.votesFor == votesFor &&
        other.votesAgainst == votesAgainst &&
        other.totalSupply == totalSupply &&
        other.executionHash == executionHash &&
        mapEquals(other.statusHistory, statusHistory);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        inFavor.hashCode ^
        against.hashCode ^
        votesFor.hashCode ^
        votesAgainst.hashCode ^
        executionHash.hashCode ^
        statusHistory.hashCode ^
        totalSupply.hashCode;
  }
}
// lib/src/models/proposal.dart