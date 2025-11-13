// lib/src/services/create_dao_service.dart

import 'dart:convert';
import 'dart:js_util';
import 'package:flutter/foundation.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';

/// Replicates the working `createDAO` logic by querying contract state post-transaction.
/// The factoryAddress should be either 'wrapper' (non-transferable) or 'wrapper_t' (transferable).
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
}) async {
  if (ethereum == null || !ethereum!.isConnected()) {
    throw Exception("A web3 wallet is required for this action.");
  }

  final provider = Web3Provider(ethereum!);

  final List<String> humanReadableAbi = [
    'function deployDAOwithToken((string name, string symbol, string description, uint8 decimals, uint256 executionDelay, address[] initialMembers, uint256[] amountsAndSettings, string[] keys, string[] values) params)',
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
    // Log detailed error information to browser console (always, not just in debug mode)
    final console = getProperty(globalThis, 'console');
    callMethod(console, 'error', ["=== DAO DEPLOYMENT FAILED ==="]);
    callMethod(console, 'error', ["Factory Address: $factoryAddress"]);
    callMethod(console, 'error', ["Parameters sent:", jsonEncode(parameters)]);
    callMethod(console, 'error', ["Full error object:"]);
    callMethod(console, 'dir', [e]);
    callMethod(console, 'error', ["Error string: ${e.toString()}"]);
    callMethod(console, 'error', ["================================"]);

    if (kDebugMode) {
      print("--- DEBUG: TRANSACTION OR RETRIEVAL FAILED ---");
      print("See browser console for full error details");
    }
    throw Exception(e.toString());
  }
}

/// Creates a DAO with a wrapped ERC20 token for governance.
/// The factoryAddress should point to 'wrapper_w' factory.
Future<String> createDAOWithWrappedToken({
  required String factoryAddress,
  required String name,
  required String symbol,
  required String description,
  required int executionDelay,
  required String underlyingTokenAddress,
  required int votingDelay,
  required int votingDuration,
  required int proposalThreshold,
  required int quorum,
  required Map<String, String> registry,
  required String transferrableStr,
}) async {
  if (ethereum == null || !ethereum!.isConnected()) {
    throw Exception("A web3 wallet is required for this action.");
  }

  final provider = Web3Provider(ethereum!);

  final List<String> humanReadableAbi = [
    'function deployDAOwithWrappedToken((string name, string symbol, string description, uint256 executionDelay, address underlyingTokenAddress, uint256[] governanceSettings, string[] keys, string[] values, string transferrableStr) params)',
    'event DaoWrappedDeploymentInfo(address indexed daoAddress, address indexed wrappedTokenAddress, address indexed underlyingTokenAddress, address registryAddress, string daoName, string wrappedTokenSymbol, string description, uint8 quorumFraction, uint256 executionDelay, uint48 votingDelay, uint32 votingPeriod, uint256 proposalThreshold)',
    'function getNumberOfDAOs() view returns (uint256)',
    'function deployedDAOs(uint256 index) view returns (address)'
  ];

  var contractWithSigner = Contract(factoryAddress, humanReadableAbi, provider);
  contractWithSigner = contractWithSigner.connect(provider.getSigner());

  // governanceSettings array: [votingDelay (minutes), votingPeriod (minutes), proposalThreshold, quorumFraction (%)]
  final governanceSettings = [
    votingDelay.toString(),
    votingDuration.toString(),
    proposalThreshold.toString(),
    quorum.toString(),
  ];

  final parameters = [
    name,
    symbol,
    description,
    executionDelay.toString(),
    underlyingTokenAddress,
    governanceSettings,
    registry.keys.toList(),
    registry.values.toList(),
    transferrableStr,
  ];

  final jsDaoParams = jsify(parameters);

  if (kDebugMode) {
    print("--- DEBUG (WRAPPED TOKEN SERVICE): PRE-FLIGHT CHECK ---");
    print("Calling Wrapped Token Factory at address: $factoryAddress");
    print("Final `params` structure (jsified List): ${jsonEncode(parameters)}");
    print("-------------------------------------------------------");
  }

  try {
    final transaction = await promiseToFuture(
        callMethod(contractWithSigner, "deployDAOwithWrappedToken", [jsDaoParams]));

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
    // Log detailed error information to browser console
    final console = getProperty(globalThis, 'console');
    callMethod(console, 'error', ["=== WRAPPED DAO DEPLOYMENT FAILED ==="]);
    callMethod(console, 'error', ["Factory Address: $factoryAddress"]);
    callMethod(console, 'error', ["Parameters sent:", jsonEncode(parameters)]);
    callMethod(console, 'error', ["Full error object:"]);
    callMethod(console, 'dir', [e]);
    callMethod(console, 'error', ["Error string: ${e.toString()}"]);
    callMethod(console, 'error', ["====================================="]);

    if (kDebugMode) {
      print("--- DEBUG: WRAPPED TOKEN DEPLOYMENT FAILED ---");
      print("See browser console for full error details");
    }
    throw Exception(e.toString());
  }
}