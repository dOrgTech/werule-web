// lib/src/models/org.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Org {
  final String name;
  final String address; // The document ID from Firestore
  final int decimals;
  final DateTime creationDate;
  final int executionDelay;
  final int holders;
  final bool nonTransferrable;
  final String proposalThreshold;
  final List proposals;
  final int quorum;
  final String registryAddress; 
  final String symbol;
  final String govTokenAddress; // Mapped from 'token' field
  final String totalSupply;
  final String? underlyingToken; // Made nullable
  final int votingDelay;
  final int votingDuration;
  final bool debatesOnly;
  final String description;
  final Map<String, String> registry; // THE FIX: Added the registry field.

  Org({
    required this.name,
    required this.address,
    required this.decimals,
    required this.creationDate,
    required this.executionDelay,
    required this.holders,
    required this.nonTransferrable,
    required this.proposalThreshold,
    required this.proposals,
    required this.quorum,
    required this.registryAddress,
    required this.symbol,
    required this.govTokenAddress,
    required this.totalSupply,
    this.underlyingToken,
    required this.votingDelay,
    required this.votingDuration,
    this.debatesOnly = false,
    required this.description,
    required this.registry, // THE FIX: Added to constructor.
  });

  factory Org.fromFirestore(Map<String, dynamic> json, String docId) {
    return Org(
      address: docId,
      name: json['name'] ?? 'Unnamed DAO',
      symbol: json['symbol'] ?? 'NO_SYM',
      description: json['description'] ?? 'No description provided.',
      decimals: json['decimals'] ?? 0,
      creationDate: (json['creationDate'] as Timestamp).toDate(),
      executionDelay: json['executionDelay'] ?? 0,
      holders: json['holders'] ?? 0,
      nonTransferrable: json['nonTransferrable'] ?? false,
      proposalThreshold: json['proposalThreshold']?.toString() ?? '0',
      proposals: json['proposals'] ?? [],
      quorum: json['quorum'] ?? 0,
      registryAddress: json['registryAddress'] as String? ?? '',
      govTokenAddress: json['token'] ?? '',
      totalSupply: json['totalSupply']?.toString() ?? '0',
      underlyingToken: json['underlyingToken'] ?? json['underlying'], 
      votingDelay: json['votingDelay'] ?? 0,
      votingDuration: json['votingDuration'] ?? 0,
      // THE FIX: Populate the registry map from the Firestore document.
      registry: json['registry'] != null ? Map<String, String>.from(json['registry']) : {},
    );
  }
}
// lib/src/models/org.dart