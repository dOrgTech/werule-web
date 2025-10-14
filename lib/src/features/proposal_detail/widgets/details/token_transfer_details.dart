// lib/src/features/proposal_detail/widgets/details/token_transfer_details.dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/providers/treasury_provider.dart';
import 'package:werule/src/services/calldata_service.dart';
import 'package:werule/src/utils/reusable.dart';

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

    if (calldata == null && amount != null) {
      displayAmount = formatTotalSupply(amount.toString(), 18);
      symbol = network.nativeCurrencySymbol;
    } 
    else if (calldata != null) {
      try {
        final calldataService = context.read<CalldataService>();
        final treasuryProvider = context.watch<TreasuryProvider>();

        // THE FIX: Decoding the calldata according to the correct function definition
        // which returns a list of three separate parameters.
        final params = calldataService.decodeCalldata(CalldataService.erc20TreasuryTransferDef, calldata!);
        final tokenAddressHex = (params[0] as EthereumAddress).hex;
        displayTo = (params[1] as EthereumAddress).hex;
        final erc20Amount = params[2] as BigInt;
        
        final tokenAsset = treasuryProvider.tokenAssets.firstWhereOrNull(
          (asset) => asset.token.address?.toLowerCase() == tokenAddressHex.toLowerCase()
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
        return ListTile(
          leading: const Icon(Icons.error, color: Colors.red),
          title: const Text('Error decoding ERC20 transfer'),
          subtitle: Text(e.toString()),
        );
      }
    } 
    else {
      return const ListTile(
        leading: Icon(Icons.error, color: Colors.red),
        title: Text('Invalid transfer data provided'),
      );
    }

    return ListTile(
      leading: const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Icon(Icons.arrow_forward),
      ),
      title: Text('$displayAmount $symbol'),
      subtitle: Text('To: $displayTo', style: const TextStyle(fontFamily: 'monospace')),
    );
  }
}
// lib/src/features/proposal_detail/widgets/details/token_transfer_details.dart