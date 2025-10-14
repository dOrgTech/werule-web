// lib/src/features/proposal_detail/widgets/proposal_execution_details_card.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/contract_call_details.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/dao_configuration_details.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/governance_token_op_details.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/registry_details.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/token_transfer_details.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/calldata_service.dart';

class ProposalExecutionDetailsCard extends StatelessWidget {
  final Proposal proposal;
  final Org org;
  final Network network;
  const ProposalExecutionDetailsCard({super.key, required this.proposal, required this.org, required this.network});

  @override
  Widget build(BuildContext context) {
    if (proposal.targets.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xff2c2c2c),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: const Center(child: Text("No execution details for this proposal.")),
      );
    }
    
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff2c2c2c),
      ),
      width: double.infinity,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: proposal.targets.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[800], height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final target = proposal.targets[index];
          final value = proposal.values.isNotEmpty ? BigInt.tryParse(proposal.values[index]) ?? BigInt.zero : BigInt.zero;
          final calldata = proposal.callDatas[index];
          return _buildExecutionStepWidget(context, target, value, calldata);
        },
      ),
    );
  }

  Widget _buildExecutionStepWidget(BuildContext context, String target, BigInt value, String calldata) {
    final calldataBytes = hexToBytes(calldata);
    
    if (calldataBytes.isEmpty && value > BigInt.zero) {
      return TokenTransferDetails(to: target, amount: value, network: network);
    }

    if (calldataBytes.length < 4) {
      return ContractCallDetails(target: target, calldata: calldata);
    }
    
    final selector = calldataBytes.sublist(0, 4);

    // THE FIX: All comparisons now use the selectors from your actual CalldataService file.
    if (listEquals(selector, CalldataService.erc20TreasuryTransferDef.selector)) {
      return TokenTransferDetails(to: target, calldata: calldata, network: network);
    }
    if (listEquals(selector, CalldataService.mintGovTokensDef.selector)) {
      return GovernanceTokenOpDetails(calldata: calldata, org: org);
    }
    if (listEquals(selector, CalldataService.burnGovTokensDef.selector)) {
      return GovernanceTokenOpDetails(calldata: calldata, org: org);
    }
    if (listEquals(selector, CalldataService.editRegistryDef.selector)) {
      return RegistryDetails(calldata: calldata);
    }
    if (listEquals(selector, CalldataService.changeQuorumDef.selector)) {
      return DaoConfigurationDetails(calldata: calldata);
    }
    if (listEquals(selector, CalldataService.changeVotingDelayDef.selector)) {
      return DaoConfigurationDetails(calldata: calldata);
    }
    if (listEquals(selector, CalldataService.changeVotingPeriodDef.selector)) {
      return DaoConfigurationDetails(calldata: calldata);
    }
    if (listEquals(selector, CalldataService.changeProposalThresholdDef.selector)) {
      return DaoConfigurationDetails(calldata: calldata);
    }
    
    return ContractCallDetails(target: target, calldata: calldata);
  }
}
// lib/src/features/proposal_detail/widgets/proposal_execution_details_card.dart