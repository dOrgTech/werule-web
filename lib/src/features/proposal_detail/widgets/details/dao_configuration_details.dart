// lib/src/features/proposal_detail/widgets/details/dao_configuration_details.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/shared_widgets.dart';
import 'package:werule/src/services/calldata_service.dart';

class DaoConfigurationDetails extends StatelessWidget {
  final String calldata;
  const DaoConfigurationDetails({super.key, required this.calldata});

  @override
  Widget build(BuildContext context) {
    final calldataService = context.read<CalldataService>();
    
    String paramValue = "Error decoding value";
    String title = "DAO Configuration Change";

    try {
      final calldataBytes = hexToBytes(calldata);
      final selector = calldataBytes.sublist(0, 4);

      // THE FIX: Comparing against the correct selectors from your CalldataService.
      if (listEquals(selector, CalldataService.changeQuorumDef.selector)) {
        final params = calldataService.decodeQuorumCall(calldata);
        paramValue = params[0].toString();
        title = "Change Quorum";
      } else if (listEquals(selector, CalldataService.changeVotingDelayDef.selector)) {
        final params = calldataService.decodeVotingDelayCall(calldata);
        paramValue = "${params[0]} Seconds";
        title = "Change Voting Delay";
      } else if (listEquals(selector, CalldataService.changeVotingPeriodDef.selector)) {
        final params = calldataService.decodeVotingPeriodCall(calldata);
        paramValue = "${params[0]} Seconds";
        title = "Change Voting Period";
      } else if (listEquals(selector, CalldataService.changeProposalThresholdDef.selector)) {
        final params = calldataService.decodeThresholdCall(calldata);
        paramValue = "${params[0].toString()} (in wei)";
        title = "Change Proposal Threshold";
      }
    } catch (e) {
       paramValue = "Error decoding value: $e";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          buildDetailRow("New Value:", paramValue, isCode: true),
        ],
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/details/dao_configuration_details.dart