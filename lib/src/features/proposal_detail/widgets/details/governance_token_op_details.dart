// lib/src/features/proposal_detail/widgets/details/governance_token_op_details.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/shared_widgets.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/services/calldata_service.dart';

class GovernanceTokenOpDetails extends StatelessWidget {
  final String calldata;
  final Org org;
  const GovernanceTokenOpDetails({super.key, required this.calldata, required this.org});

  @override
  Widget build(BuildContext context) {
    final calldataService = context.read<CalldataService>();
    String address = "N/A";
    String amount = "N/A";
    String opType = "Unknown";
    String addressLabel = "Address:";

    try {
      final calldataBytes = hexToBytes(calldata);
      final selector = calldataBytes.sublist(0, 4);

      // THE FIX: Comparing against the correct selector from your CalldataService.
      final isMint = listEquals(selector, CalldataService.mintGovTokensDef.selector);
      final def = isMint ? CalldataService.mintGovTokensDef : CalldataService.burnGovTokensDef;
      final params = calldataService.decodeCalldata(def, calldata);
      
      address = (params[0] as EthereumAddress).hex;
      final rawAmount = params[1] as BigInt;
      
      amount = (rawAmount / BigInt.from(pow(10, org.decimals))).toString();
      opType = isMint ? "Mint" : "Burn";
      addressLabel = isMint ? "To Address:" : "From Address:";

    } catch(e) {
      address = "Error decoding data";
      amount = e.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$opType ${org.symbol} Tokens", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          buildDetailRow(addressLabel, address, isCode: true),
          buildDetailRow("Amount:", amount, isCode: true),
        ],
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/details/governance_token_op_details.dart