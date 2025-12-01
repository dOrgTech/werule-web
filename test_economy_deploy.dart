// Test script for Economy DAO deployment
// Run with: dart run test_economy_deploy.dart (in web context)

import 'dart:convert';
import 'dart:js_util';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter_web3_provider/ethers.dart';

// Test the Economy DAO deployment step by step
Future<void> testEconomyDaoDeployment() async {
  final factoryAddress = '0xFB3dE5d465264557464950a9E824eBf1acc33394';

  print("=== ECONOMY DAO DEPLOYMENT TEST ===");
  print("Factory Address: $factoryAddress");

  // Check ethereum connection
  if (ethereum == null) {
    print("ERROR: ethereum is null");
    return;
  }

  if (!ethereum!.isConnected()) {
    print("ERROR: ethereum is not connected");
    return;
  }

  print("Ethereum connected: true");

  final provider = Web3Provider(ethereum!);
  print("Provider created");

  // Test ABI
  final List<String> humanReadableAbi = [
    'function deployInfrastructure(uint48 timelockDelayInMinutes) external',
    'event InfrastructureDeployed(address economy, address registry, address timelock)',
    'function deployDAOToken(address registryAddr, address timelockAddr, (string name, string symbol, address[] initialMembers, uint256[] initialAmounts) tokenParams, (string name, uint48 timelockDelay, uint32 votingPeriod, uint256 proposalThreshold, uint8 quorumFraction) govParams) external',
    'event DAOTokenDeployed(address repToken, address dao)',
    'function configureAndFinalize((address[2] implAddresses, address[5] contractAddresses) addressParams, (uint initialPlatformFeeBps, uint initialAuthorFeeBps, uint initialCoolingOffPeriod, uint initialBackersQuorumBps, uint initialProjectThreshold, uint initialAppealPeriod) economyParams) external',
  ];

  print("ABI defined with ${humanReadableAbi.length} entries");

  // Create contract
  try {
    var contract = Contract(factoryAddress, humanReadableAbi, provider);
    print("Contract created (read-only)");

    contract = contract.connect(provider.getSigner());
    print("Contract connected to signer");

    // Try calling deployInfrastructure
    final timelockDelayMinutes = 2;
    print("Calling deployInfrastructure($timelockDelayMinutes)...");

    final tx = await promiseToFuture(
      callMethod(contract, "deployInfrastructure", [timelockDelayMinutes])
    );

    print("Transaction sent!");
    print("Transaction object type: ${tx.runtimeType}");

    final hash = getProperty(tx, 'hash');
    print("Transaction hash: $hash");

    print("Waiting for confirmation...");
    final receipt = await promiseToFuture(
      callMethod(provider, 'waitForTransaction', [hash])
    );

    print("Transaction confirmed!");
    print("Receipt status: ${getProperty(receipt, 'status')}");

    // Parse logs
    final logs = getProperty(receipt, 'logs');
    print("Logs type: ${logs.runtimeType}");
    print("Logs: $logs");

    // Try to get logs length
    try {
      final logsLength = getProperty(logs, 'length');
      print("Logs length: $logsLength");
    } catch (e) {
      print("Error getting logs length: $e");
    }

  } catch (e) {
    print("ERROR: $e");
    print("Error type: ${e.runtimeType}");

    // Log to browser console for more details
    final console = getProperty(globalThis, 'console');
    callMethod(console, 'error', ["Full error object:"]);
    callMethod(console, 'dir', [e]);
  }
}

void main() {
  print("Test script loaded. Call testEconomyDaoDeployment() to run.");
}
