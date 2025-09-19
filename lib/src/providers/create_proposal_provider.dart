// lib/src/providers/create_proposal_provider.dart
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/token_asset.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/calldata_service.dart';

enum ProposalType {
  registry,
  transfer,
  mintTokens,
  burnTokens,
  updateQuorum,
  updateVotingDelay,
  updateVotingPeriod,
  updateThreshold,
}

extension ProposalTypeExtension on ProposalType {
  String get typeString {
    switch (this) {
      case ProposalType.registry: return 'registry';
      case ProposalType.transfer: return 'transfer';
      case ProposalType.mintTokens: return 'mint';
      case ProposalType.burnTokens: return 'burn';
      case ProposalType.updateQuorum: return 'quorum';
      case ProposalType.updateVotingDelay: return 'voting_delay';
      case ProposalType.updateVotingPeriod: return 'voting_period';
      case ProposalType.updateThreshold: return 'threshold';
    }
  }
}

class CreateProposalProvider extends ChangeNotifier {
  final Org org;
  final String signerAddress;
  final CalldataService _calldata;
  final BlockchainService _blockchain;

  CreateProposalProvider({
    required this.org,
    required this.signerAddress,
    required CalldataService calldata,
    required BlockchainService blockchain,
  }) : _calldata = calldata, _blockchain = blockchain;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Common state
  String title = '';
  String description = '';
  String link = '';
  ProposalType selectedType = ProposalType.registry;

  // Type-specific state
  String registryKey = '';
  String registryValue = '';
  String transferRecipient = '';
  String transferAmount = '';
  TokenAsset? selectedAsset;
  String mintRecipient = '';
  String mintAmount = '';
  String burnFromAddress = '';
  String burnAmount = '';
  String quorumValue = '';
  String votingDelayValue = '';
  String votingPeriodValue = '';
  String thresholdValue = '';

  void setProposalType(ProposalType? newType) {
    if (newType == null || newType == selectedType) return;
    selectedType = newType;
    notifyListeners();
  }

  void setSelectedAsset(TokenAsset? asset) {
    if (asset != selectedAsset) {
      selectedAsset = asset;
      notifyListeners();
    }
  }

  BigInt _parseAmount(String amountStr, int decimals) {
    if (amountStr.isEmpty) return BigInt.zero;
    
    final parts = amountStr.split('.');
    final wholeStr = parts[0];
    final BigInt wholePart = BigInt.parse(wholeStr) * BigInt.from(pow(10, decimals));

    if (parts.length == 1) {
      return wholePart;
    }

    String fractionalStr = parts[1];
    if (fractionalStr.length > decimals) {
      fractionalStr = fractionalStr.substring(0, decimals);
    }
    final BigInt fractionalPart = BigInt.parse(fractionalStr) * BigInt.from(pow(10, decimals - fractionalStr.length));
    
    return wholePart + fractionalPart;
  }

  Future<String?> submitProposal() async {
    _isLoading = true;
    notifyListeners();
    
    String? error;
    try {
      if (title.isEmpty || description.isEmpty) {
        throw Exception("Title and description are required.");
      }

      final packedDescription = "$title""0|||0""${selectedType.typeString}""0|||0""$description""0|||0""$link";
      List<String> targets = [];
      List<BigInt> values = [];
      List<Uint8List> calldatas = [];

      switch (selectedType) {
        case ProposalType.registry:
          if (registryKey.isEmpty || registryValue.isEmpty) throw Exception("Key and Value are required.");
          targets = [org.registryAddress];
          values = [BigInt.zero];
          calldatas = [_calldata.encodeRegistryCall(registryKey, registryValue)];
          break;

        case ProposalType.transfer:
          if (transferRecipient.isEmpty || transferAmount.isEmpty) throw Exception("Recipient and Amount are required.");
          
          final currentAsset = selectedAsset;
          if (currentAsset == null) throw Exception("Please select an asset to transfer.");

          final recipient = EthereumAddress.fromHex(transferRecipient);
          // THE FIX: Safely handle nullable decimals by providing a default value (18).
          final decimals = currentAsset.token.decimals;
          if (decimals == null) {
            throw Exception("Selected asset '${currentAsset.token.name}' has no decimals information.");
          }
          final amount = _parseAmount(transferAmount, decimals);
          
          targets = [org.registryAddress];
          values = [BigInt.zero];

          if (currentAsset.token.type == 'NATIVE') {
            calldatas = [_calldata.encodeTransferCall(recipient, amount)];
          } else {
            // THE FIX: Safely handle nullable token address with a proper check.
            final tokenAddress = currentAsset.token.address;
            if (tokenAddress == null || tokenAddress.isEmpty) {
              throw Exception("Selected ERC20 token '${currentAsset.token.name}' has no address.");
            }
            calldatas = [_calldata.encodeErc20TreasuryTransferCall(
              EthereumAddress.fromHex(tokenAddress),
              recipient,
              amount
            )];
          }
          break;

        case ProposalType.mintTokens:
          if (mintRecipient.isEmpty || mintAmount.isEmpty) throw Exception("Recipient and Amount are required.");
          final recipient = EthereumAddress.fromHex(mintRecipient);
          final amount = _parseAmount(mintAmount, org.decimals);
          targets = [org.govTokenAddress];
          values = [BigInt.zero];
          calldatas = [_calldata.encodeMintCall(recipient, amount)];
          break;

        case ProposalType.burnTokens:
          if (burnFromAddress.isEmpty || burnAmount.isEmpty) throw Exception("From Address and Amount are required.");
          final from = EthereumAddress.fromHex(burnFromAddress);
          final amount = _parseAmount(burnAmount, org.decimals);
          targets = [org.govTokenAddress];
          values = [BigInt.zero];
          calldatas = [_calldata.encodeBurnCall(from, amount)];
          break;

        case ProposalType.updateQuorum:
          if (quorumValue.isEmpty) throw Exception("Quorum value is required.");
          final quorum = BigInt.parse(quorumValue);
          targets = [org.address];
          values = [BigInt.zero];
          calldatas = [_calldata.encodeQuorumCall(quorum)];
          break;
        
        case ProposalType.updateVotingDelay:
          if (votingDelayValue.isEmpty) throw Exception("Voting Delay value is required.");
          final minutes = int.parse(votingDelayValue);
          final seconds = BigInt.from(minutes * 60);
          targets = [org.address];
          values = [BigInt.zero];
          calldatas = [_calldata.encodeVotingDelayCall(seconds)];
          break;

        case ProposalType.updateVotingPeriod:
          if (votingPeriodValue.isEmpty) throw Exception("Voting Period value is required.");
          final minutes = int.parse(votingPeriodValue);
          final seconds = BigInt.from(minutes * 60);
          targets = [org.address];
          values = [BigInt.zero];
          calldatas = [_calldata.encodeVotingPeriodCall(seconds)];
          break;

        case ProposalType.updateThreshold:
          if (thresholdValue.isEmpty) throw Exception("Proposal Threshold value is required.");
          final threshold = _parseAmount(thresholdValue, org.decimals);
          targets = [org.address];
          values = [BigInt.zero];
          calldatas = [_calldata.encodeThresholdCall(threshold)];
          break;
      }

      await _blockchain.propose(org.address, signerAddress, targets, values, calldatas, packedDescription);

    } on FormatException {
      error = "Invalid address or amount format.";
    } on AccountMismatchException catch (e) {
      error = e.toString();
    } catch (e) {
      error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
    return error;
  }
}
// lib/src/providers/create_proposal_provider.dart