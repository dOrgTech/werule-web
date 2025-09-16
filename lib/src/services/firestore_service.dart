// lib/src/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/network.dart';
import '../models/org.dart';
import '../models/proposal.dart';
import '../models/vote.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Stream<List<Proposal>> getProposalsStream(String networkDaoCollection, String daoAddress) {
    try {
      final querySnapshot = _db
          .collection(networkDaoCollection)
          .doc(daoAddress)
          .collection('proposals')
          .orderBy('createdAt', descending: true)
          .snapshots();
      
      return querySnapshot.map((snapshot) => 
        snapshot.docs.map((doc) => Proposal.fromFirestore(doc)).toList()
      );
    } catch (e) {
      print("Error creating proposals stream: $e");
      return Stream.error(Exception('Failed to create proposals stream.'));
    }
  }

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

  Stream<Proposal?> getProposalStream(String networkDaoCollection, String daoAddress, String proposalId) {
    try {
      final docStream = _db
          .collection(networkDaoCollection)
          .doc(daoAddress)
          .collection('proposals')
          .doc(proposalId)
          .snapshots();

      return docStream.map((doc) {
        if (doc.exists) {
          return Proposal.fromFirestore(doc);
        }
        return null;
      });
    } catch (e) {
      print("Error creating proposal stream: $e");
      return Stream.error(Exception('Failed to create proposal stream.'));
    }
  }

  Future<List<Vote>> getVotes(String networkDaoCollection, String daoAddress, String proposalId) async {
    final path = '$networkDaoCollection/$daoAddress/proposals/$proposalId/votes';
    if (kDebugMode) {
      print('--------------------------------------------------');
      print('[VOTES_FETCH] Querying Firestore path: $path');
    }

    try {
      // THE FIX: Order by the correct field name 'cast'.
      final snapshot = await _db.collection(path).orderBy('cast', descending: true).get();
      if (kDebugMode) {
        print('[VOTES_FETCH] Success. Found ${snapshot.docs.length} vote documents.');
      }
      return snapshot.docs.map((doc) => Vote.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('[VOTES_FETCH] FAILED. Error: $e');
      }
      return [];
    }
  }
}
// lib/src/services/firestore_service.dart