// lib/src/features/proposal_detail/widgets/details/contract_call_details.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/shared_widgets.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/utils/reusable.dart';

class ContractCallDetails extends StatelessWidget {
  final Proposal proposal;
  const ContractCallDetails({super.key, required this.proposal});

  @override
  Widget build(BuildContext context) {
    final target = proposal.targets.isNotEmpty ? proposal.targets[0] : "N/A";
    final calldata = proposal.callDatas.isNotEmpty ? proposal.callDatas[0] : "N/A";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildContractCallRow(context, "Target:", target),
          buildContractCallRow(context, "Calldata:", shortenString(calldata)),
        ],
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/details/contract_call_details.dart