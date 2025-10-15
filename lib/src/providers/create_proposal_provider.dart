// lib/src/providers/create_proposal_provider.dart
import 'dart:math';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/token.dart';
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
  contractCall,
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
      case ProposalType.contractCall: return 'contract_call';
    }
  }
}

// Base class for any action that can be part of a proposal
abstract class ProposalAction {
  final ProposalType type;
  ProposalAction(this.type);
}

class RegistryAction extends ProposalAction {
  String key = '';
  String value = '';
  RegistryAction() : super(ProposalType.registry);
}

class TransferAction extends ProposalAction {
  String recipient = '';
  String amount = '';
  TokenAsset? asset;
  TransferAction() : super(ProposalType.transfer);
}

class MintTokensAction extends ProposalAction {
  String recipient = '';
  String amount = '';
  MintTokensAction() : super(ProposalType.mintTokens);
}

class BurnTokensAction extends ProposalAction {
  String fromAddress = '';
  String amount = '';
  BurnTokensAction() : super(ProposalType.burnTokens);
}

class UpdateQuorumAction extends ProposalAction {
  String value = '';
  UpdateQuorumAction() : super(ProposalType.updateQuorum);
}

class UpdateVotingDelayAction extends ProposalAction {
  String value = '';
  UpdateVotingDelayAction() : super(ProposalType.updateVotingDelay);
}

class UpdateVotingPeriodAction extends ProposalAction {
  String value = '';
  UpdateVotingPeriodAction() : super(ProposalType.updateVotingPeriod);
}

class UpdateThresholdAction extends ProposalAction {
  String value = '';
  UpdateThresholdAction() : super(ProposalType.updateThreshold);
}

class ContractCallAction extends ProposalAction {
  String targetAddress = '';
  String functionSignature = '';
  List<String> paramValues = [];
  String rawCalldata = '';
  bool isRawMode = false;
  ContractCallAction() : super(ProposalType.contractCall);
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
  
  // A proposal is now a list of actions
  List<ProposalAction> actions = [RegistryAction()]; // Default to one action

  // State for prepared transaction data (for review and submit)
  List<String> preparedTargets = [];
  List<BigInt> preparedValues = [];
  List<Uint8List> preparedCalldatas = [];
  List<String> preparedCallDatasAsHex = [];

  ProposalType get selectedType => actions.isNotEmpty ? actions.first.type : ProposalType.registry;

  void setInitialProposalType(ProposalType newType) {
    if (actions.isNotEmpty && newType == selectedType) return;
    
    // Replace the first action with a new one of the selected type
    switch(newType) {
      case ProposalType.registry: actions = [RegistryAction()]; break;
      case ProposalType.transfer: actions = [TransferAction()]; break;
      case ProposalType.mintTokens: actions = [MintTokensAction()]; break;
      case ProposalType.burnTokens: actions = [BurnTokensAction()]; break;
      case ProposalType.updateQuorum: actions = [UpdateQuorumAction()]; break;
      case ProposalType.updateVotingDelay: actions = [UpdateVotingDelayAction()]; break;
      case ProposalType.updateVotingPeriod: actions = [UpdateVotingPeriodAction()]; break;
      case ProposalType.updateThreshold: actions = [UpdateThresholdAction()]; break;
      case ProposalType.contractCall: actions = [ContractCallAction()]; break;
    }
    notifyListeners();
  }

  void addAction(ProposalAction action) {
    actions.add(action);
    prepareProposalDataForReview(); // Re-prepare data when an action is added
    notifyListeners();
  }

  void removeActionAt(int index) {
    if (actions.length > 1 && index >= 0 && index < actions.length) {
      actions.removeAt(index);
      prepareProposalDataForReview(); // Re-prepare data
      notifyListeners();
    }
  }

  Future<String?> processCsvAndPopulateActions(String csvData, List<TokenAsset> availableAssets) async {
    try {
      final List<List<dynamic>> rows = const CsvToListConverter(shouldParseNumbers: false).convert(csvData);
      
      if (rows.length < 2) {
        return "CSV file must contain a header and at least one data row.";
      }

      final newActions = <ProposalAction>[];

      // Start from 1 to skip header
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 4) {
          return "Row ${i+1} is malformed. It must have 4 columns: type, asset, to, amount.";
        }

        final type = row[0].toString().toLowerCase().trim();
        final assetStr = row[1].toString().trim();
        final to = row[2].toString().trim();
        final amount = row[3].toString().trim();

        switch (type) {
          case 'transfer':
            final action = TransferAction();
            action.recipient = to;
            action.amount = amount;

            if (assetStr.toLowerCase() == 'native') {
              action.asset = availableAssets.firstWhere((a) => a.token.type == 'NATIVE', orElse: () => throw Exception("Native asset not found in treasury."));
            } else {
              action.asset = availableAssets.firstWhere(
                (a) => a.token.address?.toLowerCase() == assetStr.toLowerCase(),
                orElse: () {
                  final placeholderToken = Token(
                    address: assetStr,
                    name: 'Unknown Token',
                    symbol: '(N/A)',
                    decimals: 18, // Assume 18 decimals as a sensible default
                    type: 'ERC20',
                  );
                  // THE FIX: The TokenAsset model expects a String for balance, not a BigInt.
                  return TokenAsset(token: placeholderToken, balance: BigInt.zero.toString());
                }
              );
            }
            newActions.add(action);
            break;

          case 'mint':
            final action = MintTokensAction();
            action.recipient = to;
            action.amount = amount;
            newActions.add(action);
            break;

          case 'burn':
            final action = BurnTokensAction();
            action.fromAddress = to;
            action.amount = amount;
            newActions.add(action);
            break;

          default:
            return "Invalid action type '$type' found at row ${i+1}. Must be 'transfer', 'mint', or 'burn'.";
        }
      }
      
      actions = newActions;
      notifyListeners();
      return null;

    } catch (e) {
      return "Error processing CSV: ${e.toString()}";
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

  String? prepareProposalDataForReview() {
    try {
      if (title.isEmpty || description.isEmpty) {
        throw Exception("Title and description are required.");
      }
      if (actions.isEmpty) {
        throw Exception("At least one action is required for a proposal.");
      }

      List<String> targets = [];
      List<BigInt> values = [];
      List<Uint8List> calldatas = [];

      for(final action in actions) {
        switch (action.type) {
          case ProposalType.registry:
            final act = action as RegistryAction;
            if (act.key.isEmpty || act.value.isEmpty) throw Exception("Key and Value are required.");
            targets.add(org.registryAddress);
            values.add(BigInt.zero);
            calldatas.add(_calldata.encodeRegistryCall(act.key, act.value));
            break;

          case ProposalType.transfer:
            final act = action as TransferAction;
            if (act.recipient.isEmpty || act.amount.isEmpty) throw Exception("Recipient and Amount are required.");
            final currentAsset = act.asset;
            if (currentAsset == null) throw Exception("Please select an asset to transfer.");
            final recipient = EthereumAddress.fromHex(act.recipient);
            final decimals = currentAsset.token.decimals;
            if (decimals == null) throw Exception("Selected asset '${currentAsset.token.name}' has no decimals.");
            final amount = _parseAmount(act.amount, decimals);
            
            targets.add(org.registryAddress);
            values.add(BigInt.zero);

            if (currentAsset.token.type == 'NATIVE') {
              calldatas.add(_calldata.encodeTransferCall(recipient, amount));
            } else {
              final tokenAddress = currentAsset.token.address;
              if (tokenAddress == null || tokenAddress.isEmpty) throw Exception("Selected ERC20 has no address.");
              calldatas.add(_calldata.encodeErc20TreasuryTransferCall(
                EthereumAddress.fromHex(tokenAddress), recipient, amount));
            }
            break;

          case ProposalType.mintTokens:
            final act = action as MintTokensAction;
            if (act.recipient.isEmpty || act.amount.isEmpty) throw Exception("Recipient and Amount are required.");
            final recipient = EthereumAddress.fromHex(act.recipient);
            final amount = _parseAmount(act.amount, org.decimals);
            targets.add(org.govTokenAddress);
            values.add(BigInt.zero);
            calldatas.add(_calldata.encodeMintCall(recipient, amount));
            break;

          case ProposalType.burnTokens:
            final act = action as BurnTokensAction;
            if (act.fromAddress.isEmpty || act.amount.isEmpty) throw Exception("From Address and Amount are required.");
            final from = EthereumAddress.fromHex(act.fromAddress);
            final amount = _parseAmount(act.amount, org.decimals);
            targets.add(org.govTokenAddress);
            values.add(BigInt.zero);
            calldatas.add(_calldata.encodeBurnCall(from, amount));
            break;
          
          case ProposalType.updateQuorum:
            final act = action as UpdateQuorumAction;
            if (act.value.isEmpty) throw Exception("Quorum value is required.");
            targets.add(org.address);
            values.add(BigInt.zero);
            calldatas.add(_calldata.encodeQuorumCall(BigInt.parse(act.value)));
            break;
          
          case ProposalType.updateVotingDelay:
            final act = action as UpdateVotingDelayAction;
            if (act.value.isEmpty) throw Exception("Voting Delay value is required.");
            final seconds = BigInt.from(int.parse(act.value) * 60);
            targets.add(org.address);
            values.add(BigInt.zero);
            calldatas.add(_calldata.encodeVotingDelayCall(seconds));
            break;

          case ProposalType.updateVotingPeriod:
            final act = action as UpdateVotingPeriodAction;
            if (act.value.isEmpty) throw Exception("Voting Period value is required.");
            final seconds = BigInt.from(int.parse(act.value) * 60);
            targets.add(org.address);
            values.add(BigInt.zero);
            calldatas.add(_calldata.encodeVotingPeriodCall(seconds));
            break;

          case ProposalType.updateThreshold:
            final act = action as UpdateThresholdAction;
            if (act.value.isEmpty) throw Exception("Proposal Threshold value is required.");
            final threshold = _parseAmount(act.value, org.decimals);
            targets.add(org.address);
            values.add(BigInt.zero);
            calldatas.add(_calldata.encodeThresholdCall(threshold));
            break;

          case ProposalType.contractCall:
            final act = action as ContractCallAction;
            if (act.targetAddress.isEmpty) throw Exception("Target Contract Address is required.");
            targets.add(act.targetAddress);
            values.add(BigInt.zero);
            
            if (act.isRawMode) {
              if (act.rawCalldata.isEmpty) throw Exception("Raw Calldata is required.");
              calldatas.add(hexToBytes(act.rawCalldata));
            } else {
              if (act.functionSignature.isEmpty) throw Exception("Function Signature is required.");
              calldatas.add(_calldata.encodeArbitraryFunctionCall(act.functionSignature, act.paramValues));
            }
            break;
        }
      }
      
      preparedTargets = targets;
      preparedValues = values;
      preparedCalldatas = calldatas;
      preparedCallDatasAsHex = calldatas.map((cd) => bytesToHex(cd, include0x: true)).toList();
      notifyListeners();
      return null;

    } on FormatException catch (e) {
      return "Invalid format: ${e.message}";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> submitProposal() async {
    _isLoading = true;
    notifyListeners();
    
    String? error;
    try {
      if (preparedTargets.isEmpty || preparedCalldatas.isEmpty) {
        throw Exception("Proposal data not prepared. Please complete all steps.");
      }
      // THE FIX: Use 'batch' as the type if there are multiple actions.
      final typeString = actions.length > 1 ? 'batch' : actions.first.type.typeString;
      final packedDescription = "$title""0|||0""$typeString""0|||0""$description""0|||0""$link";
      
      await _blockchain.propose(org.address, signerAddress, preparedTargets, preparedValues, preparedCalldatas, packedDescription);

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