// lib/src/services/blockchain_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_web3/flutter_web3.dart' as web3;
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:werule/src/services/erc20_gov_abi.dart';
import 'package:werule/src/services/governor_abi.dart';
import '../models/network.dart';

// THE FIX: A custom exception to identify this specific error case.
class AccountMismatchException implements Exception {
  final String requiredAddress;
  final String activeAddress;
  AccountMismatchException({required this.requiredAddress, required this.activeAddress});

  @override
  String toString() {
    final shortAddress = "${requiredAddress.substring(0, 6)}...${requiredAddress.substring(requiredAddress.length - 4)}";
    return "Account mismatch. Please set the active wallet account to $shortAddress.";
  }
}

class BlockchainService {
  int _parseChainId(dynamic chainId) {
    if (chainId is int) {
      return chainId;
    }
    if (chainId is String) {
      return int.parse(
        chainId.startsWith('0x') ? chainId.substring(2) : chainId,
        radix: 16,
      );
    }
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
      callback(_parseChainId(chainId));
    });
  }

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
      if (result.isNotEmpty && result[0] is BigInt) {
        return (result[0] as BigInt).toInt();
      }
      throw Exception('Failed to parse proposal state from contract.');
    } catch (e) {
      if (kDebugMode) print('[BlockchainService] Error getting proposal state: $e');
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
      if (result.length == 3) {
        return result.cast<BigInt>();
      }
      throw Exception('Failed to parse proposal votes from contract.');
    } catch (e) {
      if (kDebugMode) print('[BlockchainService] Error getting proposal votes: $e');
      rethrow;
    } finally {
      await client.dispose();
    }
  }

  Future<BigInt> getVotes(String tokenAddress, String userAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(
        Erc20GovAbi.abi,
        EthereumAddress.fromHex(tokenAddress),
      );
      final getVotesFunction = contract.function('getVotes');
      final result = await client.call(
        contract: contract,
        function: getVotesFunction,
        params: [EthereumAddress.fromHex(userAddress)],
      );

      if (result.isNotEmpty && result[0] is BigInt) {
        return result[0] as BigInt;
      }
      throw Exception('Failed to parse voting weight from token contract.');
    } catch (e) {
      if (kDebugMode) print('[BlockchainService] Error getting votes: $e');
      return BigInt.zero;
    } finally {
      await client.dispose();
    }
  }

  Future<String?> getDelegate(String tokenAddress, String userAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(Erc20GovAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final delegatesFunction = contract.function('delegates');
      final result = await client.call(
        contract: contract,
        function: delegatesFunction,
        params: [EthereumAddress.fromHex(userAddress)],
      );

      if (result.isNotEmpty && result[0] is EthereumAddress) {
        return (result[0] as EthereumAddress).hex;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('[BlockchainService] Error getting delegate: $e');
      return null;
    } finally {
      await client.dispose();
    }
  }

  Future<String> delegate(String tokenAddress, String delegateeAddress, String signerAddress) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final activeAddress = await signer.getAddress();

    if (kDebugMode) {
      print("[BlockchainService] Attempting 'delegate' transaction.");
      print("  > App's selected signer: $signerAddress");
      print("  > Wallet's active signer: $activeAddress");
    }

    if (activeAddress.toLowerCase() != signerAddress.toLowerCase()) {
      throw AccountMismatchException(requiredAddress: signerAddress, activeAddress: activeAddress);
    }

    final contract = web3.Contract(tokenAddress, Erc20GovAbi.abiJson, signer);
    try {
      final tx = await contract.send('delegate', [delegateeAddress]);
      await tx.wait();
      return tx.hash;
    } catch (e) {
      if (kDebugMode) print("Delegation error: $e");
      throw Exception("Transaction failed. It may have been rejected or encountered an error.");
    }
  }

  Future<String> castVote(String contractAddress, BigInt proposalId, int support, String signerAddress) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final activeAddress = await signer.getAddress();

    if (kDebugMode) {
      print("[BlockchainService] Attempting 'castVote' transaction.");
      print("  > App's selected signer: $signerAddress");
      print("  > Wallet's active signer: $activeAddress");
    }

    if (activeAddress.toLowerCase() != signerAddress.toLowerCase()) {
      throw AccountMismatchException(requiredAddress: signerAddress, activeAddress: activeAddress);
    }
    
    final contract = web3.Contract(contractAddress, governorAbi, signer);
    try {
      final tx = await contract.send('castVote', [proposalId, support]);
      await tx.wait();
      return tx.hash;
    } catch (e) {
      if (kDebugMode) print("Cast vote error: $e");
      throw Exception("Transaction failed. You may not have had voting power when this proposal was created.");
    }
  }
  
  Future<BigInt> getProposalSnapshotTimestamp(String contractAddress, BigInt proposalId, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(ContractAbi.fromJson(governorAbi, 'Governor'), EthereumAddress.fromHex(contractAddress));
      final func = contract.function('proposalSnapshot');
      final result = await client.call(contract: contract, function: func, params: [proposalId]);
      return result.isNotEmpty ? result[0] as BigInt : BigInt.zero;
    } finally {
      await client.dispose();
    }
  }

  Future<BigInt> getPastVotes(String tokenAddress, String userAddress, BigInt timepoint, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(Erc20GovAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('getPastVotes');
      final result = await client.call(contract: contract, function: func, params: [EthereumAddress.fromHex(userAddress), timepoint]);
      return result.isNotEmpty ? result[0] as BigInt : BigInt.zero;
    } finally {
      await client.dispose();
    }
  }

  Future<String> queueProposal(String contractAddress, BigInt proposalId, String signerAddress) async {
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final activeAddress = await signer.getAddress();
    
    if (kDebugMode) {
      print("[BlockchainService] Attempting 'queue' transaction.");
      print("  > App's selected signer: $signerAddress");
      print("  > Wallet's active signer: $activeAddress");
    }

    if (activeAddress.toLowerCase() != signerAddress.toLowerCase()) {
      throw AccountMismatchException(requiredAddress: signerAddress, activeAddress: activeAddress);
    }

    // Mocking the rest of the call for now
    await Future.delayed(const Duration(seconds: 2));
    return "0x_mock_queue_tx_hash_${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<String> executeProposal(String contractAddress, BigInt proposalId, String signerAddress) async {
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final activeAddress = await signer.getAddress();

    if (kDebugMode) {
      print("[BlockchainService] Attempting 'execute' transaction.");
      print("  > App's selected signer: $signerAddress");
      print("  > Wallet's active signer: $activeAddress");
    }

    if (activeAddress.toLowerCase() != signerAddress.toLowerCase()) {
      throw AccountMismatchException(requiredAddress: signerAddress, activeAddress: activeAddress);
    }

    // Mocking the rest of the call for now
    await Future.delayed(const Duration(seconds: 2));
    return "0x_mock_execute_tx_hash_${DateTime.now().millisecondsSinceEpoch}";
  }
}
// lib/src/services/blockchain_service.dart