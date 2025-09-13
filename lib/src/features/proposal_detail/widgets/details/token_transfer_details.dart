// lib/src/features/proposal_detail/widgets/details/token_transfer_details.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/calldata_service.dart';

class TokenTransferDetails extends StatelessWidget {
  final Proposal proposal;
  final Network network;

  const TokenTransferDetails({super.key, required this.proposal, required this.network});

  @override
  Widget build(BuildContext context) {
    final calldataService = context.read<CalldataService>();

    if (proposal.callDatas.isEmpty) {
      return const Center(child: Text("No transfer data found."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: proposal.callDatas.length,
      itemBuilder: (context, index) {
        try {
          final calldata = proposal.callDatas[index];
          final params = calldataService.decodeCalldata(CalldataService.transferNativeDef, calldata);
          final to = params[0] as String;
          final amount = params[1] as BigInt;
          
          final double displayAmount = amount / BigInt.from(pow(10, 18));

          return ListTile(
            leading: const Icon(Icons.arrow_forward),
            title: Text('${displayAmount.toStringAsFixed(4)} ${network.nativeCurrencySymbol}'),
            subtitle: Text('To: $to', style: const TextStyle(fontFamily: 'monospace')),
          );
        } catch (e) {
          return ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: const Text('Error decoding transfer'),
            subtitle: Text(e.toString()),
          );
        }
      },
    );
  }
}
