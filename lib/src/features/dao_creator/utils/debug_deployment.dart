// lib/src/features/dao_creator/utils/debug_deployment.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/services/create_dao_service.dart';
// THE FIX: Import the new, isolated service instead of the main BlockchainService.

/// A one-click test function to deploy a DAO with hardcoded known-good values.
Future<void> hardcodedDeploy(BuildContext context) async {
  if (kDebugMode) {
    print("--- INITIATING HARDCODED DEPLOYMENT TEST ---");
  }

  // Read required providers from the context.
  final authProvider = context.read<AuthProvider>();
  final networkProvider = context.read<NetworkProvider>();

  final network = networkProvider.selectedNetwork;
  final signer = authProvider.selectedAccount;

  if (network == null || signer == null) {
    if (kDebugMode) {
      print("DEBUG ERROR: Wallet not connected or network not selected.");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Wallet not connected or network not selected."),
          backgroundColor: Colors.red),
    );
    return;
  }

  // --- HARDCODED VALUES FROM WORKING LOG ---
  const name = "berbely";
  const symbol = "ADE";
  const description = "aosidoaisd";
  const decimals = 2;
  const executionDelay = 60; // seconds
  const initialMembers = ["0x06E5b15Bc39f921e1503073dBb8A5dA2Fc6220E9"];
  const memberBalances = ["23300"]; // Balance WITH decimals
  const votingDelay = 1; // minutes
  const votingDuration = 2; // minutes
  const proposalThreshold = 1; // raw value
  const quorum = 4; // raw value
  final registry = <String, String>{};
  const isTransferrable = false;
  // --- END OF HARDCODED VALUES ---

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
        content: Text("Attempting hardcoded deployment... Check console."),
        backgroundColor: Colors.blue),
  );

  try {
    // Choose the correct wrapper contract based on transferability
    final factoryAddress = isTransferrable ? network.wrapperT : network.wrapper;

    // THE FIX: Call the new, isolated `createDAOFromWizard` function directly.
    final newDaoAddress = await createDAOFromWizard(
      factoryAddress: factoryAddress,
      name: name,
      symbol: symbol,
      description: description,
      decimals: decimals,
      executionDelay: executionDelay,
      initialMembers: initialMembers,
      memberBalances: memberBalances,
      votingDelay: votingDelay,
      votingDuration: votingDuration,
      proposalThreshold: proposalThreshold,
      quorum: quorum,
      registry: registry,
    );

    if (kDebugMode) {
      print("✅ ✅ ✅ HARDCODED DEPLOYMENT SUCCEEDED! ✅ ✅ ✅");
      print("New DAO Address: $newDaoAddress");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("SUCCESS! New DAO at: $newDaoAddress"),
          backgroundColor: Colors.green),
    );
  } catch (e) {
    if (kDebugMode) {
      print("❌ ❌ ❌ HARDCODED DEPLOYMENT FAILED ❌ ❌ ❌");
      print("Final Error: $e");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Hardcoded deployment failed: $e"),
          backgroundColor: Colors.red),
    );
  }
}