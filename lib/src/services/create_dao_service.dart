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

/// Callback type for reporting deployment progress
typedef DeploymentProgressCallback = void Function(String message);

/// Helper function to create an ethers.js Interface and parse logs
/// In ethers v5, Interface is under ethers.utils.Interface
dynamic _createEthersInterface(List<dynamic> abi) {
  final ethers = getProperty(globalThis, 'ethers');
  // Try ethers v6 first (ethers.Interface)
  var interfaceClass = getProperty(ethers, 'Interface');
  if (interfaceClass == null) {
    // Fall back to ethers v5 (ethers.utils.Interface)
    final utils = getProperty(ethers, 'utils');
    interfaceClass = getProperty(utils, 'Interface');
  }
  if (interfaceClass == null) {
    throw Exception("Could not find ethers Interface class");
  }
  return callConstructor(interfaceClass, [jsify(abi)]);
}

/// Helper function to parse a log using an ethers Interface
Map<String, dynamic>? _parseLog(dynamic iface, dynamic log) {
  try {
    final parsed = callMethod(iface, 'parseLog', [log]);
    if (parsed == null) return null;
    return {
      'name': getProperty(parsed, 'name'),
      'args': getProperty(parsed, 'args'),
    };
  } catch (_) {
    return null;
  }
}

/// Creates an Economy DAO (Trustless Business) using the 3-step deployment process.
/// The factoryAddress should point to 'wrapper_trustless' factory.
///
/// Economy DAOs extend standard governance with a trustless marketplace for project-based work.
/// They require 3 separate transactions:
/// 1. deployInfrastructure - deploys Economy, TimelockController, and Registry
/// 2. deployDAOToken - deploys RepToken (governance token) and DAO (Governor)
/// 3. configureAndFinalize - configures the Economy contract, sets registry entries, and finalizes setup
Future<String> createEconomyDAO({
  required String factoryAddress,
  required String tokenName,
  required String tokenSymbol,
  required List<String> initialMembers,
  required List<String> memberBalances,
  required int timelockDelayMinutes,
  required int votingPeriodMinutes,
  required int proposalThreshold,
  required int quorumFraction,
  required int arbitrationFeeBps,
  required int platformFeeBps,
  required int authorFeeBps,
  required int coolingOffPeriodSeconds,
  required int backersQuorumBps,
  required int projectThresholdWei,
  required int appealPeriodSeconds,
  required String nativeProjectImpl,
  required String erc20ProjectImpl,
  required Map<String, String> registry,
  DeploymentProgressCallback? onProgress,
}) async {
  // Debug logging at entry
  final console = getProperty(globalThis, 'console');
  callMethod(console, 'log', ["=== createEconomyDAO ENTRY ==="]);
  callMethod(console, 'log', ["factoryAddress: $factoryAddress"]);
  callMethod(console, 'log', ["tokenName: $tokenName"]);
  callMethod(console, 'log', ["tokenSymbol: $tokenSymbol"]);
  callMethod(console, 'log', ["initialMembers: $initialMembers"]);
  callMethod(console, 'log', ["memberBalances: $memberBalances"]);
  callMethod(console, 'log', ["timelockDelayMinutes: $timelockDelayMinutes"]);
  callMethod(console, 'log', ["nativeProjectImpl: $nativeProjectImpl"]);
  callMethod(console, 'log', ["erc20ProjectImpl: $erc20ProjectImpl"]);

  if (ethereum == null || !ethereum!.isConnected()) {
    throw Exception("A web3 wallet is required for this action.");
  }

  callMethod(console, 'log', ["Ethereum connected, creating provider..."]);

  final provider = Web3Provider(ethereum!);

  callMethod(console, 'log', ["Provider created, defining ABI..."]);

  // Human-readable ABI for flutter_web3_provider Contract class
  final List<String> humanReadableAbi = [
    'function deployInfrastructure(uint48 timelockDelayInMinutes, uint256 arbitrationFeeBps)',
    'function deployDAOToken(address registryAddr, address timelockAddr, tuple(string name, string symbol, address[] initialMembers, uint256[] initialAmounts) tokenParams, tuple(string name, uint48 timelockDelay, uint32 votingPeriod, uint256 proposalThreshold, uint8 quorumFraction) govParams)',
    'function configureAndFinalize(tuple(address[2] implAddresses, address[5] contractAddresses) addressParams, tuple(uint256 arbitrationFeeBps, uint256 initialPlatformFeeBps, uint256 initialAuthorFeeBps, uint256 initialCoolingOffPeriod, uint256 initialBackersQuorumBps, uint256 initialProjectThreshold, uint256 initialAppealPeriod) economyParams, string[] registryKeys, string[] registryValues)',
    'event InfrastructureDeployed(address economy, address registry, address timelock)',
    'event DAOTokenDeployed(address repToken, address dao)',
    'event SuiteConfigured(address deployer, address indexed economy, address registry, address timelock, address indexed repToken, address indexed dao)',
  ];

  callMethod(console, 'log', ["Creating contract with human-readable ABI..."]);

  var contractWithSigner = Contract(factoryAddress, humanReadableAbi, provider);

  callMethod(console, 'log', ["Contract created, connecting signer..."]);

  contractWithSigner = contractWithSigner.connect(provider.getSigner());

  callMethod(console, 'log', ["Signer connected, creating ethers Interface..."]);

  // Create an ethers Interface for parsing logs
  final iface = _createEthersInterface(humanReadableAbi);

  callMethod(console, 'log', ["Interface created: $iface"]);

  if (kDebugMode) {
    print("--- DEBUG (ECONOMY DAO SERVICE): Starting 3-step deployment ---");
    print("Factory Address: $factoryAddress");
  }

  try {
    // ============================================
    // STEP 1: Deploy Infrastructure
    // ============================================
    onProgress?.call("Step 1/3: Deploying infrastructure...");

    if (kDebugMode) {
      print("Step 1: Calling deployInfrastructure($timelockDelayMinutes)");
    }

    callMethod(console, 'log', ["About to call deployInfrastructure..."]);

    // Gas override - estimation fails for this contract, need to specify manually
    // In ethers.js v5: contract.functionName(arg1, arg2, {gasLimit: ...})
    // The override object is passed as the last argument after all function params
    // deployInfrastructure deploys 3 contracts (Economy, Registry, Timelock) - needs ~8-10M gas
    final gasOverride = jsify({'gasLimit': '10000000'});  // 10M gas

    dynamic tx1;
    try {
      callMethod(console, 'log', ["Calling with gas override:"]);
      callMethod(console, 'dir', [gasOverride]);

      // Pass timelockDelayMinutes, arbitrationFeeBps, and override object as separate args to callMethod
      // This translates to: contract.deployInfrastructure(timelockDelayMinutes, arbitrationFeeBps, {gasLimit: ...})
      tx1 = await promiseToFuture(
          callMethod(contractWithSigner, "deployInfrastructure", [timelockDelayMinutes, arbitrationFeeBps, gasOverride]));
      callMethod(console, 'log', ["deployInfrastructure returned:"]);
      callMethod(console, 'dir', [tx1]);
    } catch (e) {
      callMethod(console, 'error', ["deployInfrastructure FAILED:"]);
      callMethod(console, 'dir', [e]);
      rethrow;
    }

    final hash1 = getProperty(tx1, 'hash');
    callMethod(console, 'log', ["Step 1 tx hash: $hash1"]);
    onProgress?.call("Step 1/3: Waiting for transaction confirmation...");

    // Use tx.wait() to get full receipt with logs
    final receipt1 = await promiseToFuture(callMethod(tx1, 'wait', []));

    callMethod(console, 'log', ["Receipt1 from tx.wait():"]);
    callMethod(console, 'dir', [receipt1]);

    final status1 = getProperty(receipt1, 'status');
    callMethod(console, 'log', ["Receipt1 status: $status1"]);
    if (status1 != 1) {
      throw Exception("Step 1 (deployInfrastructure) transaction reverted.");
    }

    // Also try getTransactionReceipt for comparison
    final receipt1Alt = await promiseToFuture(
        callMethod(provider, 'getTransactionReceipt', [hash1]));
    callMethod(console, 'log', ["Receipt1 from getTransactionReceipt():"]);
    callMethod(console, 'dir', [receipt1Alt]);

    // Check both receipts for logs
    var logs1 = getProperty(receipt1, 'logs');
    var logs1Length = getProperty(logs1, 'length') as int;

    callMethod(console, 'log', ["Logs from tx.wait(): $logs1Length"]);

    // If no logs from tx.wait(), try from getTransactionReceipt
    if (logs1Length == 0 && receipt1Alt != null) {
      logs1 = getProperty(receipt1Alt, 'logs');
      logs1Length = getProperty(logs1, 'length') as int;
      callMethod(console, 'log', ["Logs from getTransactionReceipt(): $logs1Length"]);
    }
    String? economyAddr;
    String? registryAddr;
    String? timelockAddr;

    callMethod(console, 'log', ["Receipt logs count: $logs1Length"]);
    callMethod(console, 'log', ["Receipt logs object:"]);
    callMethod(console, 'dir', [logs1]);

    for (int i = 0; i < logs1Length; i++) {
      // Use array index access instead of .at()
      final log = getProperty(logs1, i);
      callMethod(console, 'log', ["Log $i:"]);
      callMethod(console, 'dir', [log]);

      final parsed = _parseLog(iface, log);
      callMethod(console, 'log', ["Parsed log $i: $parsed"]);

      if (parsed != null && parsed['name'] == 'InfrastructureDeployed') {
        final args = parsed['args'];
        callMethod(console, 'log', ["Found InfrastructureDeployed event, args:"]);
        callMethod(console, 'dir', [args]);
        economyAddr = getProperty(args, 'economy')?.toString();
        registryAddr = getProperty(args, 'registry')?.toString();
        timelockAddr = getProperty(args, 'timelock')?.toString();
        callMethod(console, 'log', ["Extracted: economy=$economyAddr, registry=$registryAddr, timelock=$timelockAddr"]);
        break;
      }
    }

    if (economyAddr == null || registryAddr == null || timelockAddr == null) {
      throw Exception("Failed to parse InfrastructureDeployed event. Could not retrieve deployed addresses.");
    }

    if (kDebugMode) {
      print("Step 1 complete. Economy: $economyAddr, Registry: $registryAddr, Timelock: $timelockAddr");
    }

    // ============================================
    // STEP 2: Deploy DAO and Token
    // ============================================
    onProgress?.call("Step 2/3: Deploying DAO and token...");

    final tokenParams = [
      tokenName,
      tokenSymbol,
      initialMembers,
      memberBalances,
    ];

    final govParams = [
      tokenName, // Governor name (can be same as token name)
      timelockDelayMinutes, // timelockDelay in minutes (converted in Dao.sol)
      votingPeriodMinutes, // votingPeriod in minutes (converted in Dao.sol)
      proposalThreshold.toString(),
      quorumFraction,
    ];

    if (kDebugMode) {
      print("Step 2: Calling deployDAOToken with tokenParams: ${jsonEncode(tokenParams)}");
      print("govParams: ${jsonEncode(govParams)}");
    }

    final tx2 = await promiseToFuture(
        callMethod(contractWithSigner, "deployDAOToken", [
          registryAddr,
          timelockAddr,
          jsify(tokenParams),
          jsify(govParams),
        ]));

    final hash2 = getProperty(tx2, 'hash');
    onProgress?.call("Step 2/3: Waiting for transaction confirmation...");

    final receipt2 = await promiseToFuture(
        callMethod(provider, 'waitForTransaction', [hash2]));

    final status2 = getProperty(receipt2, 'status');
    if (status2 != 1) {
      throw Exception("Step 2 (deployDAOToken) transaction reverted.");
    }

    // Parse the DAOTokenDeployed event
    final logs2 = getProperty(receipt2, 'logs');
    final logs2Length = getProperty(logs2, 'length') as int;
    String? repTokenAddr;
    String? daoAddr;

    for (int i = 0; i < logs2Length; i++) {
      final log = callMethod(logs2, 'at', [i]);
      final parsed = _parseLog(iface, log);
      if (parsed != null && parsed['name'] == 'DAOTokenDeployed') {
        final args = parsed['args'];
        repTokenAddr = getProperty(args, 'repToken')?.toString();
        daoAddr = getProperty(args, 'dao')?.toString();
        break;
      }
    }

    if (repTokenAddr == null || daoAddr == null) {
      throw Exception("Failed to parse DAOTokenDeployed event. Could not retrieve deployed addresses.");
    }

    if (kDebugMode) {
      print("Step 2 complete. RepToken: $repTokenAddr, DAO: $daoAddr");
    }

    // ============================================
    // STEP 3: Configure and Finalize
    // ============================================
    onProgress?.call("Step 3/3: Configuring and finalizing...");

    // AddressParams: implAddresses[2], contractAddresses[5]
    // implAddresses: [nativeProjectImpl, erc20ProjectImpl]
    // contractAddresses: [economy, registry, timelock, repToken, dao]
    final addressParams = [
      [nativeProjectImpl, erc20ProjectImpl],
      [economyAddr, registryAddr, timelockAddr, repTokenAddr, daoAddr],
    ];

    // EconomyParams (arbitrationFeeBps must match the value passed in Step 1)
    final economyParams = [
      arbitrationFeeBps,
      platformFeeBps,
      authorFeeBps,
      coolingOffPeriodSeconds,
      backersQuorumBps,
      projectThresholdWei.toString(),
      appealPeriodSeconds,
    ];

    // Registry keys and values for initial configuration
    final registryKeys = registry.keys.toList();
    final registryValues = registry.values.toList();

    if (kDebugMode) {
      print("Step 3: Calling configureAndFinalize");
      print("addressParams: ${jsonEncode(addressParams)}");
      print("economyParams: ${jsonEncode(economyParams)}");
      print("registryKeys: ${jsonEncode(registryKeys)}");
      print("registryValues: ${jsonEncode(registryValues)}");
    }

    callMethod(console, 'log', ["Step 3 registry keys: ${jsonEncode(registryKeys)}"]);
    callMethod(console, 'log', ["Step 3 registry values: ${jsonEncode(registryValues)}"]);

    final tx3 = await promiseToFuture(
        callMethod(contractWithSigner, "configureAndFinalize", [
          jsify(addressParams),
          jsify(economyParams),
          jsify(registryKeys),
          jsify(registryValues),
        ]));

    final hash3 = getProperty(tx3, 'hash');
    onProgress?.call("Step 3/3: Waiting for transaction confirmation...");

    final receipt3 = await promiseToFuture(
        callMethod(provider, 'waitForTransaction', [hash3]));

    final status3 = getProperty(receipt3, 'status');
    if (status3 != 1) {
      throw Exception("Step 3 (configureAndFinalize) transaction reverted.");
    }

    if (kDebugMode) {
      print("Step 3 complete. Economy DAO fully deployed!");
      print("DAO Address: $daoAddr");
    }

    onProgress?.call("Economy DAO deployed successfully!");

    return daoAddr;

  } catch (e) {
    // Log detailed error information to browser console
    final console = getProperty(globalThis, 'console');
    callMethod(console, 'error', ["=== ECONOMY DAO DEPLOYMENT FAILED ==="]);
    callMethod(console, 'error', ["Factory Address: $factoryAddress"]);
    callMethod(console, 'error', ["Full error object:"]);
    callMethod(console, 'dir', [e]);
    callMethod(console, 'error', ["Error string: ${e.toString()}"]);
    callMethod(console, 'error', ["======================================"]);

    if (kDebugMode) {
      print("--- DEBUG: ECONOMY DAO DEPLOYMENT FAILED ---");
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