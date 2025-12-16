// lib/src/services/blockchain_service.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_web3/flutter_web3.dart' as web3;
import 'package:http/http.dart' as http;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'package:werule/src/services/debates_abi.dart';
import 'package:werule/src/services/erc20_gov_abi.dart';
import 'package:werule/src/services/economy_abi.dart';
import 'package:werule/src/services/governor_abi.dart';
import 'package:werule/src/services/reptoken_abi.dart';
import '../models/debate.dart';
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

  // --- Debates Contract Methods ---

  /// Gets list of debates for a DAO's governance token
  Future<List<DebateListItem>> getDebateListByToken(String factoryAddress, String tokenAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(DebatesAbi.getDebateListByToken, 'DebatesFactory'),
        EthereumAddress.fromHex(factoryAddress),
      );
      final func = contract.function('getDebateListByToken');
      final result = await client.call(contract: contract, function: func, params: [EthereumAddress.fromHex(tokenAddress)]);

      final debates = (result[0] as List).map((data) {
        final tuple = data as List;
        return DebateListItem(
          debateAddress: (tuple[0] as EthereumAddress).hex,
          title: tuple[1] as String,
          creator: (tuple[2] as EthereumAddress).hex,
          createdAt: tuple[3] as BigInt,
          argumentCount: tuple[4] as BigInt,
          sentiment: tuple[5] as BigInt,
          isOpen: tuple[6] as bool,
        );
      }).toList();

      return debates;
    } finally {
      await client.dispose();
    }
  }

  /// Gets debate count for a token
  Future<BigInt> getDebateCountByToken(String factoryAddress, String tokenAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(DebatesAbi.getDebateCountByToken, 'DebatesFactory'),
        EthereumAddress.fromHex(factoryAddress),
      );
      final func = contract.function('getDebateCountByToken');
      final result = await client.call(contract: contract, function: func, params: [EthereumAddress.fromHex(tokenAddress)]);
      return result[0] as BigInt;
    } finally {
      await client.dispose();
    }
  }

  /// Gets full debate with all arguments
  Future<Debate> getFullDebate(String debateAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(DebatesAbi.getFullDebate, 'Debate'),
        EthereumAddress.fromHex(debateAddress),
      );
      final func = contract.function('getFullDebate');
      final result = await client.call(contract: contract, function: func, params: []);

      final data = result[0] as List;
      final argumentsData = data[9] as List;
      final arguments = argumentsData.map((argData) {
        final arg = argData as List;
        return DebateArgument(
          id: arg[0] as BigInt,
          parentId: arg[1] as BigInt,
          argType: (arg[2] as BigInt).toInt() == 0 ? ArgumentType.pro : ArgumentType.con,
          author: (arg[3] as EthereumAddress).hex,
          content: arg[4] as String,
          directWeight: arg[5] as BigInt,
          netScore: arg[6] as BigInt,
          proChildIds: (arg[7] as List).map((e) => e as BigInt).toList(),
          conChildIds: (arg[8] as List).map((e) => e as BigInt).toList(),
          isValid: arg[9] as bool,
        );
      }).toList();

      return Debate(
        debateAddress: (data[0] as EthereumAddress).hex,
        title: data[1] as String,
        token: (data[2] as EthereumAddress).hex,
        referenceBlock: data[3] as BigInt,
        totalSupplyAtCreation: data[4] as BigInt,
        totalStakedWeight: data[5] as BigInt,
        argumentCount: data[6] as BigInt,
        debateSentiment: data[7] as BigInt,
        isOpen: data[8] as bool,
        arguments: arguments,
      );
    } finally {
      await client.dispose();
    }
  }

  /// Gets user's remaining voting power in a debate
  Future<BigInt> getDebateRemainingVotingPower(String debateAddress, String userAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(DebatesAbi.getRemainingVotingPower, 'Debate'),
        EthereumAddress.fromHex(debateAddress),
      );
      final func = contract.function('getRemainingVotingPower');
      final result = await client.call(contract: contract, function: func, params: [EthereumAddress.fromHex(userAddress)]);
      return result[0] as BigInt;
    } finally {
      await client.dispose();
    }
  }

  /// Creates a new debate
  Future<String> createDebate(
    String factoryAddress,
    String tokenAddress,
    String title,
    String rootArgument,
    BigInt rootWeight,
    String signerAddress,
  ) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final contract = web3.Contract(factoryAddress, DebatesAbi.createDebate, signer);
    final tx = await contract.send('createDebate', [tokenAddress, title, rootArgument, rootWeight.toString()]);
    await tx.wait();
    return tx.hash;
  }

  /// Adds an argument to a debate
  Future<String> addDebateArgument(
    String debateAddress,
    BigInt parentId,
    ArgumentType argType,
    BigInt weight,
    String content,
    String signerAddress,
  ) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final contract = web3.Contract(debateAddress, DebatesAbi.addArgument, signer);
    final argTypeInt = argType == ArgumentType.pro ? 0 : 1;
    final tx = await contract.send('addArgument', [parentId.toString(), argTypeInt, weight.toString(), content]);
    await tx.wait();
    return tx.hash;
  }

  /// Adds weight to an existing argument
  Future<String> addDebateWeight(
    String debateAddress,
    BigInt argumentId,
    BigInt additionalWeight,
    String signerAddress,
  ) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final contract = web3.Contract(debateAddress, DebatesAbi.addWeight, signer);
    final tx = await contract.send('addWeight', [argumentId.toString(), additionalWeight.toString()]);
    await tx.wait();
    return tx.hash;
  }

  // --- Economy Contract Methods ---

  /// Gets user's financial profile from Economy contract
  Future<EconomyUserProfile> getEconomyUserProfile(String economyAddress, String userAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(EconomyAbi.abi, EthereumAddress.fromHex(economyAddress));
      final func = contract.function('getUser');
      final result = await client.call(contract: contract, function: func, params: [EthereumAddress.fromHex(userAddress)]);

      // Result is a tuple: (earnedTokens[], earnedAmounts[], spentTokens[], spentAmounts[], projectsAsAuthor[], projectsAsContractor[], projectsAsArbiter[])
      final profile = result[0] as List<dynamic>;

      final earnedTokens = (profile[0] as List<dynamic>).map((e) => (e as EthereumAddress).hex).toList();
      final earnedAmounts = (profile[1] as List<dynamic>).map((e) => e as BigInt).toList();
      final spentTokens = (profile[2] as List<dynamic>).map((e) => (e as EthereumAddress).hex).toList();
      final spentAmounts = (profile[3] as List<dynamic>).map((e) => e as BigInt).toList();
      final projectsAsAuthor = (profile[4] as List<dynamic>).map((e) => (e as EthereumAddress).hex).toList();
      final projectsAsContractor = (profile[5] as List<dynamic>).map((e) => (e as EthereumAddress).hex).toList();
      final projectsAsArbiter = (profile[6] as List<dynamic>).map((e) => (e as EthereumAddress).hex).toList();

      return EconomyUserProfile(
        earnedTokens: earnedTokens,
        earnedAmounts: earnedAmounts,
        spentTokens: spentTokens,
        spentAmounts: spentAmounts,
        projectsAsAuthor: projectsAsAuthor,
        projectsAsContractor: projectsAsContractor,
        projectsAsArbiter: projectsAsArbiter,
      );
    } finally {
      await client.dispose();
    }
  }

  // --- RepToken Methods ---

  /// Gets current passive income epoch ID
  Future<BigInt> getCurrentPassiveIncomeEpoch(String tokenAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(RepTokenAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('currentPassiveIncomeEpoch');
      final result = await client.call(contract: contract, function: func, params: []);
      return result[0] as BigInt;
    } finally {
      await client.dispose();
    }
  }

  /// Gets current delegate reward epoch ID
  Future<BigInt> getCurrentDelegateRewardEpoch(String tokenAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(RepTokenAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('currentDelegateRewardEpoch');
      final result = await client.call(contract: contract, function: func, params: []);
      return result[0] as BigInt;
    } finally {
      await client.dispose();
    }
  }

  /// Gets passive income epoch details
  Future<RewardEpoch> getPassiveIncomeEpoch(String tokenAddress, BigInt epochId, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(RepTokenAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('passiveIncomeEpochs');
      final result = await client.call(contract: contract, function: func, params: [epochId]);
      return RewardEpoch(
        budget: result[0] as BigInt,
        paymentToken: (result[1] as EthereumAddress).hex,
        startTimestamp: result[2] as BigInt,
      );
    } finally {
      await client.dispose();
    }
  }

  /// Gets delegate reward epoch details
  Future<RewardEpoch> getDelegateRewardEpoch(String tokenAddress, BigInt epochId, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(RepTokenAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('delegateRewardEpochs');
      final result = await client.call(contract: contract, function: func, params: [epochId]);
      return RewardEpoch(
        budget: result[0] as BigInt,
        paymentToken: (result[1] as EthereumAddress).hex,
        startTimestamp: result[2] as BigInt,
      );
    } finally {
      await client.dispose();
    }
  }

  /// Checks if user has claimed passive income for epoch
  Future<bool> hasClaimedPassiveIncome(String tokenAddress, BigInt epochId, String userAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(RepTokenAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('hasClaimedPassiveIncome');
      final result = await client.call(contract: contract, function: func, params: [epochId, EthereumAddress.fromHex(userAddress)]);
      return result[0] as bool;
    } finally {
      await client.dispose();
    }
  }

  /// Checks if user has claimed delegate reward for epoch
  Future<bool> hasClaimedDelegateReward(String tokenAddress, BigInt epochId, String userAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(RepTokenAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('hasClaimedDelegateReward');
      final result = await client.call(contract: contract, function: func, params: [epochId, EthereumAddress.fromHex(userAddress)]);
      return result[0] as bool;
    } finally {
      await client.dispose();
    }
  }

  /// Gets amount of earnings user has already claimed for a token
  Future<BigInt> getClaimedEarnings(String tokenAddress, String userAddress, String earnedTokenAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(RepTokenAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('claimedEarnings');
      final result = await client.call(contract: contract, function: func, params: [
        EthereumAddress.fromHex(userAddress),
        EthereumAddress.fromHex(earnedTokenAddress),
      ]);
      return result[0] as BigInt;
    } finally {
      await client.dispose();
    }
  }

  /// Gets amount of spendings user has already claimed for a token
  Future<BigInt> getClaimedSpendings(String tokenAddress, String userAddress, String spentTokenAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(RepTokenAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('claimedSpendings');
      final result = await client.call(contract: contract, function: func, params: [
        EthereumAddress.fromHex(userAddress),
        EthereumAddress.fromHex(spentTokenAddress),
      ]);
      return result[0] as BigInt;
    } finally {
      await client.dispose();
    }
  }

  /// Gets past total supply at a specific timepoint
  Future<BigInt> getPastTotalSupply(String tokenAddress, BigInt timepoint, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(RepTokenAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('getPastTotalSupply');
      final result = await client.call(contract: contract, function: func, params: [timepoint]);
      return result[0] as BigInt;
    } finally {
      await client.dispose();
    }
  }

  /// Gets total supply of RepToken
  Future<BigInt> getTotalSupply(String tokenAddress, String rpcUrl) async {
    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(RepTokenAbi.abi, EthereumAddress.fromHex(tokenAddress));
      final func = contract.function('totalSupply');
      final result = await client.call(contract: contract, function: func, params: []);
      return result[0] as BigInt;
    } finally {
      await client.dispose();
    }
  }

  // --- RepToken Write Methods ---

  /// Claims reputation from economy (converts economic activity to governance tokens)
  Future<String> claimReputationFromEconomy(String tokenAddress, String signerAddress) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final contract = web3.Contract(tokenAddress, RepTokenAbi.abiJson, signer);
    final tx = await contract.send('claimReputationFromEconomy', []);
    await tx.wait();
    return tx.hash;
  }

  /// Claims passive income for a specific epoch
  Future<String> claimPassiveIncome(String tokenAddress, BigInt epochId, String signerAddress) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final contract = web3.Contract(tokenAddress, RepTokenAbi.abiJson, signer);
    final tx = await contract.send('claimPassiveIncome', [epochId.toInt()]);
    await tx.wait();
    return tx.hash;
  }

  /// Claims representation reward for a specific epoch
  Future<String> claimRepresentationReward(String tokenAddress, BigInt epochId, String signerAddress) async {
    if (!web3.Ethereum.isSupported || web3.ethereum == null) {
      throw Exception("A web3 wallet is required for this action.");
    }
    final provider = web3.Web3Provider(web3.ethereum!);
    final signer = provider.getSigner();
    final contract = web3.Contract(tokenAddress, RepTokenAbi.abiJson, signer);
    final tx = await contract.send('claimRepresentationReward', [epochId.toInt()]);
    await tx.wait();
    return tx.hash;
  }
}

/// Represents a user's economic profile from the Economy contract
class EconomyUserProfile {
  final List<String> earnedTokens;
  final List<BigInt> earnedAmounts;
  final List<String> spentTokens;
  final List<BigInt> spentAmounts;
  final List<String> projectsAsAuthor;
  final List<String> projectsAsContractor;
  final List<String> projectsAsArbiter;

  EconomyUserProfile({
    required this.earnedTokens,
    required this.earnedAmounts,
    required this.spentTokens,
    required this.spentAmounts,
    required this.projectsAsAuthor,
    required this.projectsAsContractor,
    required this.projectsAsArbiter,
  });
}

/// Represents a reward epoch (passive income or delegate reward)
class RewardEpoch {
  final BigInt budget;
  final String paymentToken;
  final BigInt startTimestamp;

  RewardEpoch({
    required this.budget,
    required this.paymentToken,
    required this.startTimestamp,
  });

  bool get isValid => startTimestamp > BigInt.zero;
}