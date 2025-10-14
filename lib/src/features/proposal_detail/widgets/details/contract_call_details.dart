// lib/src/features/proposal_detail/widgets/details/contract_call_details.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/shared_widgets.dart';
import 'package:werule/src/utils/reusable.dart';

// THE FIX: Widget now accepts target and calldata for a single execution step.
class ContractCallDetails extends StatelessWidget {
  final String target;
  final String calldata;
  const ContractCallDetails({super.key, required this.target, required this.calldata});

  @override
  Widget build(BuildContext context) {
    // THE FIX: Layout refactored for consistency.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Contract Call", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          buildContractCallRow(context, "Target:", target),
          buildContractCallRow(
            context,
            "Calldata:",
            shortenString(calldata),
            fullValueToCopy: calldata,
          ),
        ],
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/details/contract_call_details.dart