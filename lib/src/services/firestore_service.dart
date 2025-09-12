// lib/src/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/network.dart';
import '../models/org.dart';
import '../models/proposal.dart'; 


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // NEW METHOD: Fetches all network configs from the 'contracts' collection
  Future<List<Network>> getNetworks() async {
    try {
      final snapshot = await _db.collection('contracts').get();
      if (snapshot.docs.isEmpty) {
        return [];
      }
      return snapshot.docs
          .map((doc) => Network.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching networks: $e");
      throw Exception('Failed to load networks from Firestore.');
    }
  }

  // MODIFIED METHOD: Now takes the specific collection name to query
  Future<List<Org>> getDaos(String networkDaoCollection) async {
    try {
      final snapshot = await _db.collection(networkDaoCollection).get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final daos = snapshot.docs
          .map((doc) => Org.fromFirestore(doc.data(), doc.id))
          .toList();

      return daos;
    } catch (e) {
      print("Error fetching DAOs for $networkDaoCollection: $e");
      throw Exception('Failed to load DAOs from Firestore.');
    }
  }


Future<Org?> getDao(String networkDaoCollection, String daoAddress) async {
    try {
      final doc = await _db.collection(networkDaoCollection).doc(daoAddress).get();
      if (doc.exists) {
        return Org.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching single DAO: $e");
      return null;
    }
  }

  // NEW: Get all proposals for a given DAO
  Future<List<Proposal>> getProposals(String networkDaoCollection, String daoAddress) async {
    try {
      final snapshot = await _db
          .collection(networkDaoCollection)
          .doc(daoAddress)
          .collection('proposals')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Proposal.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching proposals: $e");
      return [];
    }
  }

  // NEW: Get a single proposal by its ID
  Future<Proposal?> getProposal(String networkDaoCollection, String daoAddress, String proposalId) async {
    try {
      final doc = await _db
          .collection(networkDaoCollection)
          .doc(daoAddress)
          .collection('proposals')
          .doc(proposalId)
          .get();
      if (doc.exists) {
        return Proposal.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Error fetching single proposal: $e");
      return null;
    }
  }
}

// lib/src/services/firestore_service.dart