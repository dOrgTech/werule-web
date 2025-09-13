// lib/src/features/proposal_detail/widgets/details/registry_details.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/shared_widgets.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/calldata_service.dart';

class RegistryDetails extends StatelessWidget {
  final Proposal proposal;
  const RegistryDetails({super.key, required this.proposal});

  @override
  Widget build(BuildContext context) {
    final calldataService = context.read<CalldataService>();

    if (proposal.callDatas.isEmpty) {
      return const Center(child: Text("No registry data found."));
    }

    return ListView.builder(
       shrinkWrap: true,
       physics: const NeverScrollableScrollPhysics(),
       itemCount: proposal.callDatas.length,
       itemBuilder: (context, index) {
          final calldata = proposal.callDatas[index];
          final params = calldataService.decodeRegistryCalldata(calldata);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                buildDetailRow("Key:", params[0]),
                buildDetailRow("Value:", params[1]),
              ],
            ),
          );
       }
    );
  }
}
// lib/src/features/proposal_detail/widgets/details/registry_details.dart