// lib/src/services/blockchain_service.dart

import 'package:flutter_web3/flutter_web3.dart' as web3;
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:werule/src/services/governor_abi.dart';
import '../models/network.dart';

class BlockchainService {
  // THE FIX: A private helper function to reliably parse chain IDs
  // whether they come from the wallet as an int or a hex string.
  int _parseChainId(dynamic chainId) {
    if (chainId is int) {
      return chainId;
    }
    if (chainId is String) {
      return int.parse(
        // Remove '0x' prefix if it exists, then parse as base-16
        chainId.startsWith('0x') ? chainId.substring(2) : chainId,
        radix: 16,
      );
    }
    // As a fallback for any unexpected type, though this shouldn't happen.
    throw FormatException('Cannot parse chainId: $chainId');
  }

  bool isWalletAvailable() {
    return web3.Ethereum.isSupported;
  }

  Future<List<String>> connect() async {
    try {
      final accounts = await web3.ethereum!.requestAccount();
      return accounts.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getAccounts() async {
    try {
      final accounts = await web3.ethereum!.getAccounts();
      return accounts.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<int?> getChainId() async {
    try {
      final dynamic chainId = await web3.ethereum!.getChainId();
      // Apply the parsing function here as well for consistency.
      return _parseChainId(chainId);
    } catch (e) {
      return null;
    }
  }

  Future<void> switchChain(int chainId) async {
    try {
      await web3.ethereum!.walletSwitchChain(chainId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addChain(Network network) async {
    try {
      await web3.ethereum!.walletAddChain(
        chainId: network.chainId,
        chainName: network.name,
        nativeCurrency: web3.CurrencyParams(
          name: network.nativeCurrencyName,
          symbol: network.nativeCurrencySymbol,
          decimals: 18,
        ),
        rpcUrls: [network.rpcUrl],
      );
    } catch (e) {
      rethrow;
    }
  }

  void onAccountsChanged(Function(List<String>) callback) {
    web3.ethereum!.on('accountsChanged', (accounts) {
      callback((accounts as List<dynamic>).cast<String>());
    });
  }

  void onChainChanged(Function(int) callback) {
    web3.ethereum!.on('chainChanged', (chainId) {
      // Apply the parsing function to the event payload before calling the callback.
      // This is the core fix for the crash.
      callback(_parseChainId(chainId));
    });
  }

  // --- NEW METHODS for Governor Contract Interaction ---

  Future<int> getProposalState(String contractAddress, BigInt proposalId, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(governorAbi, 'Governor'),
        EthereumAddress.fromHex(contractAddress),
      );
      final stateFunction = contract.function('state');
      final result = await client.call(
        contract: contract,
        function: stateFunction,
        params: [proposalId],
      );
      // The result is a list containing the state enum, which is a uint8.
      if (result.isNotEmpty && result[0] is BigInt) {
        return (result[0] as BigInt).toInt();
      }
      throw Exception('Failed to parse proposal state from contract.');
    } catch (e) {
      print('[BlockchainService] Error getting proposal state: $e');
      rethrow;
    } finally {
      await client.dispose();
    }
  }

  Future<List<BigInt>> getProposalVotes(String contractAddress, BigInt proposalId, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(governorAbi, 'Governor'),
        EthereumAddress.fromHex(contractAddress),
      );
      final votesFunction = contract.function('proposalVotes');
      final result = await client.call(
        contract: contract,
        function: votesFunction,
        params: [proposalId],
      );
      // result is [againstVotes, forVotes, abstainVotes]
      if (result.length == 3) {
        return result.cast<BigInt>();
      }
      throw Exception('Failed to parse proposal votes from contract.');
    } catch (e) {
      print('[BlockchainService] Error getting proposal votes: $e');
      rethrow;
    } finally {
      await client.dispose();
    }
  }

  // --- NEW: Placeholder Action Methods ---

  Future<String> castVote(String contractAddress, BigInt proposalId, int support) async {
    // In a real app, this would use web3.personal!.sendTransaction to vote.
    print('Casting vote for proposal $proposalId with support $support on contract $contractAddress');
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    // throw Exception("User rejected transaction"); // Uncomment to test error case
    return "0x_mock_vote_tx_hash_${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<String> queueProposal(String contractAddress, BigInt proposalId) async {
    print('Queueing proposal $proposalId on contract $contractAddress');
    await Future.delayed(const Duration(seconds: 2));
    return "0x_mock_queue_tx_hash_${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<String> executeProposal(String contractAddress, BigInt proposalId) async {
    print('Executing proposal $proposalId on contract $contractAddress');
    await Future.delayed(const Duration(seconds: 2));
    return "0x_mock_execute_tx_hash_${DateTime.now().millisecondsSinceEpoch}";
  }
}
// lib/src/services/blockchain_service.dart