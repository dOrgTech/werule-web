// lib/src/features/proposal_detail/widgets/details/dao_configuration_details.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/shared_widgets.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/calldata_service.dart';

class DaoConfigurationDetails extends StatelessWidget {
  final Proposal proposal;
  const DaoConfigurationDetails({super.key, required this.proposal});

  @override
  Widget build(BuildContext context) {
    final calldataService = context.read<CalldataService>();
    final type = proposal.type?.toLowerCase().replaceAll('_', ' ') ?? "";

    if (proposal.callDatas.isEmpty) {
      return const Center(child: Text("No configuration data found."));
    }
    
    final calldata = proposal.callDatas[0];
    List<dynamic> params = [];
    String paramName = "Unknown Parameter";
    String paramValue = "Error decoding value";

    try {
      if (type.contains("quorum")) {
        params = calldataService.decodeCalldata(CalldataService.changeQuorumDef, calldata);
        paramName = "New Quorum Numerator";
        paramValue = params[0].toString();
      } else if (type.contains("voting delay")) {
        params = calldataService.decodeCalldata(CalldataService.changeVotingDelayDef, calldata);
        paramName = "New Voting Delay";
        // THE FIX: The contract value is in seconds.
        paramValue = "${params[0]} Seconds";
      } else if (type.contains("voting period")) {
        params = calldataService.decodeCalldata(CalldataService.changeVotingPeriodDef, calldata);
        paramName = "New Voting Period";
        // THE FIX: The contract value is in seconds.
        paramValue = "${params[0]} Seconds";
      } else if (type.contains("threshold")) {
        params = calldataService.decodeCalldata(CalldataService.changeProposalThresholdDef, calldata);
        paramName = "New Proposal Threshold";
        paramValue = "${params[0].toString()} (in wei)";
      }
    } catch (e) {
       paramValue = "Error decoding value: $e";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDetailRow("Parameter:", paramName),
          const SizedBox(height: 12),
          buildDetailRow("New Value:", paramValue, isCode: true),
        ],
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/details/dao_configuration_details.dart