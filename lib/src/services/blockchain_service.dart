// lib/src/services/blockchain_service.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_web3/flutter_web3.dart' as web3;
import 'package:http/http.dart' as http;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'package:werule/src/services/erc20_gov_abi.dart';
import 'package:werule/src/services/governor_abi.dart';
import '../models/network.dart';

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
    if (chainId is int) return chainId;
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
      final result = await client.call(contract: contract, function: stateFunction, params: [proposalId]);
      return (result[0] as BigInt).toInt();
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
      final result = await client.call(contract: contract, function: votesFunction, params: [proposalId]);
      return result.cast<BigInt>();
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
      final result = await client.call(contract: contract, function: getVotesFunction, params: [EthereumAddress.fromHex(userAddress)]);
      return result[0] as BigInt;
    } finally {
      await client.dispose();
    }
  }

  Future<String?> getDelegate(String tokenAddress, String userAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(Erc20GovAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final delegatesFunction = contract.function('delegates');
      final result = await client.call(contract: contract, function: delegatesFunction, params: [EthereumAddress.fromHex(userAddress)]);
      return (result[0] as EthereumAddress).hex;
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
    final contract = web3.Contract(tokenAddress, Erc20GovAbi.abiJson, signer);
    final tx = await contract.send('delegate', [delegateeAddress]);
    await tx.wait();
    return tx.hash;
  }
  
  Future<String> castVote(String contractAddress, BigInt proposalId, int support, String signerAddress) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final contract = web3.Contract(contractAddress, governorAbi, signer);
    final tx = await contract.send('castVote', [proposalId, support]);
    await tx.wait();
    return tx.hash;
  }

  Future<String> propose( String contractAddress, String signerAddress, List<String> targets, List<BigInt> values, List<Uint8List> calldatas, String description) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final contract = web3.Contract(contractAddress, governorAbi, signer);
    final tx = await contract.send('propose', [targets, values, calldatas, description]);
    await tx.wait();
    return tx.hash;
  }

  Uint8List _getDescriptionHash(String description) {
    final encodedDescription = utf8.encode(description);
    return Uint8List.fromList(keccak256(encodedDescription));
  }

  Future<String> queueProposal( String contractAddress, String signerAddress, List<String> targets, List<BigInt> values, List<Uint8List> calldatas, String description) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final descriptionHashBytes = _getDescriptionHash(description);
    final descriptionHashHex = '0x${bytesToHex(descriptionHashBytes)}';
    final contract = web3.Contract(contractAddress, governorAbi, signer);
    final tx = await contract.send('queue', [targets, values, calldatas, descriptionHashHex]);
    await tx.wait();
    return tx.hash;
  }

  Future<String> executeProposal( String contractAddress, String signerAddress, List<String> targets, List<BigInt> values, List<Uint8List> calldatas, String description) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final descriptionHashBytes = _getDescriptionHash(description);
    final descriptionHashHex = '0x${bytesToHex(descriptionHashBytes)}';
    final contract = web3.Contract(contractAddress, governorAbi, signer);
    final tx = await contract.send('execute', [targets, values, calldatas, descriptionHashHex]);
    await tx.wait();
    return tx.hash;
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
}