// lib/src/features/proposal_detail/widgets/details/token_transfer_details.dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/providers/treasury_provider.dart';
import 'package:werule/src/services/calldata_service.dart';
import 'package:werule/src/utils/reusable.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/shared_widgets.dart';

class TokenTransferDetails extends StatelessWidget {
  final String? to;
  final BigInt? amount;
  final String? calldata;
  final Network network;

  const TokenTransferDetails({
    super.key, 
    this.to,
    this.amount,
    this.calldata,
    required this.network,
  });

  @override
  Widget build(BuildContext context) {
    String displayTo = to ?? 'N/A';
    String displayAmount;
    String symbol;
    String title;
    String? tokenAddressHex;

    // Native currency transfer (e.g., ETH)
    if (calldata == null && amount != null) {
      displayAmount = formatTotalSupply(amount.toString(), 18);
      symbol = network.nativeCurrencySymbol;
      title = "Transfer Native Currency";
    } 
    // ERC20 token transfer
    else if (calldata != null) {
      title = "Transfer ERC20 Token";
      try {
        final calldataService = context.read<CalldataService>();
        final treasuryProvider = context.watch<TreasuryProvider>();

        final params = calldataService.decodeCalldata(CalldataService.erc20TreasuryTransferDef, calldata!);
        tokenAddressHex = (params[0] as EthereumAddress).hex;
        displayTo = (params[1] as EthereumAddress).hex;
        final erc20Amount = params[2] as BigInt;
        
        final tokenAsset = treasuryProvider.tokenAssets.firstWhereOrNull(
          (asset) => asset.token.address?.toLowerCase() == tokenAddressHex?.toLowerCase()
        );

        if (tokenAsset != null) {
          final decimals = tokenAsset.token.decimals ?? 18;
          displayAmount = formatTotalSupply(erc20Amount.toString(), decimals);
          symbol = tokenAsset.token.symbol;
        } else {
          displayAmount = erc20Amount.toString();
          symbol = 'tokens (wei)';
        }
      } catch (e) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Error Decoding Transfer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
              const SizedBox(height: 12),
              buildDetailRow("Details:", e.toString()),
            ],
          ),
        );
      }
    } 
    else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Invalid Transfer Data", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 12),
            buildDetailRow("Details:", "No valid transfer data was provided to the widget."),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (tokenAddressHex != null)
            buildContractCallRow(context, "Token:", tokenAddressHex),
          buildContractCallRow(context, "To:", displayTo),
          buildDetailRow("Amount:", "$displayAmount $symbol", isCode: true),
        ],
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/details/token_transfer_details.dart