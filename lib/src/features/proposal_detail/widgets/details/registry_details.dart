// lib/src/features/proposal_detail/widgets/details/registry_details.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/shared_widgets.dart';
import 'package:werule/src/services/calldata_service.dart';

class RegistryDetails extends StatelessWidget {
  final String calldata;
  const RegistryDetails({super.key, required this.calldata});

  @override
  Widget build(BuildContext context) {
    final calldataService = context.read<CalldataService>();
    // THE FIX: Using the existing decodeRegistryCalldata method from your service file.
    final params = calldataService.decodeRegistryCalldata(calldata);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Update Registry", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          buildDetailRow("Key:", params[0]),
          buildDetailRow("Value:", params[1]),
        ],
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/details/registry_details.dart