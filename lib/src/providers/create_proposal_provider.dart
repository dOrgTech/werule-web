// lib/src/providers/create_proposal_provider.dart
import 'package:flutter/material.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/calldata_service.dart';

enum ProposalType {
  registry,
  // Other types will be added here
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

  // Global state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Common proposal info
  String title = '';
  String description = '';
  String link = '';

  // Type selector
  ProposalType selectedType = ProposalType.registry;

  // Type-specific state
  // -- Registry
  String registryKey = '';
  String registryValue = '';

  void setProposalType(ProposalType? newType) {
    if (newType == null || newType == selectedType) return;
    selectedType = newType;
    notifyListeners();
  }

  Future<String?> submitProposal() async {
    _isLoading = true;
    notifyListeners();
    
    String? error;

    try {
      switch (selectedType) {
        case ProposalType.registry:
          if (title.isEmpty || description.isEmpty || registryKey.isEmpty || registryValue.isEmpty) {
            error = "All fields are required for a Registry proposal.";
            break;
          }
          final packedDescription = "$title""0|||0""registry""0|||0""$description""0|||0""$link";
          final targets = [org.registryAddress];
          final values = [BigInt.zero];
          final calldatas = [_calldata.encodeRegistryCall(registryKey, registryValue)];

          await _blockchain.propose(
            org.address,
            signerAddress,
            targets,
            values,
            calldatas,
            packedDescription,
          );
          break;
      }
    } on AccountMismatchException catch (e) {
      error = e.toString();
    } catch (e) {
      error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
    return error; // null on success
  }
}
// lib/src/providers/create_proposal_provider.dart