// lib/src/services/create_dao_service.dart

import 'dart:convert';
import 'dart:js_util';
import 'package:flutter/foundation.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';

/// Replicates the working `createDAO` logic by querying contract state post-transaction.
Future<String> createDAOFromWizard({
  required String factoryAddress,
  required String name,
  required String symbol,
  required String description,
  required int decimals,
  required int executionDelay,
  required List<String> initialMembers,
  required List<String> memberBalances,
  required int votingDelay,
  required int votingDuration,
  required int proposalThreshold,
  required int quorum,
  required Map<String, String> registry,
  required bool isTransferrable,
}) async {
  if (ethereum == null || !ethereum!.isConnected()) {
    throw Exception("A web3 wallet is required for this action.");
  }

  final provider = Web3Provider(ethereum!);

  final List<String> humanReadableAbi = [
    'function deployDAOwithToken((string name, string symbol, string description, uint8 decimals, uint256 executionDelay, address[] initialMembers, uint256[] amountsAndSettings, string[] keys, string[] values, bool transferrable) params)',
    'event NewDaoCreated(address indexed daoAddress, address indexed tokenAddress, address treasuryAddress, address registryAddress)',
    'function getNumberOfDAOs() view returns (uint256)',
    'function deployedDAOs(uint256 index) view returns (address)'
  ];

  var contractWithSigner = Contract(factoryAddress, humanReadableAbi, provider);
  contractWithSigner = contractWithSigner.connect(provider.getSigner());

  List<String> amounts = List<String>.from(memberBalances);
  amounts.addAll([
    votingDelay.toString(),
    votingDuration.toString(),
    proposalThreshold.toString(),
    quorum.toString(),
  ]);

  final parameters = [
    name,
    symbol,
    description,
    decimals.toString(),
    executionDelay.toString(),
    initialMembers,
    amounts,
    registry.keys.toList(),
    registry.values.toList(),
    isTransferrable.toString(),
  ];

  final jsDaoParams = jsify(parameters);

  if (kDebugMode) {
    print("--- DEBUG (ISOLATED SERVICE): PRE-FLIGHT CHECK ---");
    print("Calling Wrapper Contract at address: $factoryAddress");
    print("Final `params` structure (jsified List): ${jsonEncode(parameters)}");
    print("-------------------------------------------------");
  }

  try {
    final transaction = await promiseToFuture(
        callMethod(contractWithSigner, "deployDAOwithToken", [jsDaoParams]));

    final hash = getProperty(transaction, 'hash');
    final result = await promiseToFuture(
        callMethod(provider, 'waitForTransaction', [hash]));

    final status = getProperty(result, 'status');
    if (status != 1) {
      throw Exception("Transaction reverted on-chain.");
    }
    
    final readOnlyContract = Contract(factoryAddress, humanReadableAbi, provider);
    
    final newTotalBN = await promiseToFuture(callMethod(readOnlyContract, "getNumberOfDAOs", []));
    final newTotalString = callMethod(newTotalBN, 'toString', []);
    final daoCount = BigInt.parse(newTotalString);
    
    final indexToGet = daoCount - BigInt.one;

    final newDaoAddress = await promiseToFuture(
        callMethod(readOnlyContract, "deployedDAOs", [indexToGet.toString()]));

    if (newDaoAddress != null && newDaoAddress is String) {
      return newDaoAddress;
    }

    throw Exception("Could not retrieve a valid DAO address from factory contract at index $indexToGet.");

  } catch (e) {
    // THE FIX: Add more detailed logging in the catch block.
    if (kDebugMode) {
      print("--- DEBUG: TRANSACTION OR RETRIEVAL FAILED ---");
      // Use `console.dir` for a detailed, expandable object view in the browser console.
      final console = getProperty(globalThis, 'console');
      callMethod(console, 'dir', ["Full Error object from JS call:", e]);
    }
    throw Exception(e.toString());
  }
}