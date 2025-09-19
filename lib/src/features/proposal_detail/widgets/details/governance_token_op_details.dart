// lib/src/features/proposal_detail/widgets/details/governance_token_op_details.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/shared_widgets.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/calldata_service.dart';

class GovernanceTokenOpDetails extends StatelessWidget {
  final Proposal proposal;
  final Org org;
  const GovernanceTokenOpDetails({super.key, required this.proposal, required this.org});

  @override
  Widget build(BuildContext context) {
    final calldataService = context.read<CalldataService>();
    final type = proposal.type?.toLowerCase() ?? "";
    
    if (proposal.callDatas.isEmpty) {
      return const Center(child: Text("No transaction data found."));
    }

    final calldata = proposal.callDatas[0];
    String address = "N/A";
    String amount = "N/A";

    try {
      final ContractFunction def = type.contains("mint") ? CalldataService.mintGovTokensDef : CalldataService.burnGovTokensDef;
      final params = calldataService.decodeCalldata(def, calldata);
      
      // THE FIX: The decoder now returns an EthereumAddress object. We must get its hex string.
      address = (params[0] as EthereumAddress).hex;
      final rawAmount = params[1] as BigInt;
      
      amount = (rawAmount / BigInt.from(pow(10, org.decimals))).toString();
    } catch(e) {
      address = "Error decoding data";
      amount = e.toString();
    }
    
    final opType = type.contains("mint") ? "Mint" : "Burn";
    final addressLabel = type.contains("mint") ? "To Address:" : "From Address:";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildDetailRow("Operation:", "$opType ${org.symbol} Tokens"),
          buildDetailRow(addressLabel, address, isCode: true),
          buildDetailRow("Amount:", amount, isCode: true),
        ],
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/details/governance_token_op_details.dart