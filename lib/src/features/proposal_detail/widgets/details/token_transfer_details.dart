// lib/src/features/proposal_detail/widgets/details/token_transfer_details.dart
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/treasury_provider.dart';
import 'package:werule/src/services/calldata_service.dart';
import 'package:werule/src/utils/reusable.dart';

class TokenTransferDetails extends StatelessWidget {
  final Proposal proposal;
  final Network network;
  final Org org;

  const TokenTransferDetails({
    super.key, 
    required this.proposal, 
    required this.network,
    required this.org,
  });

  @override
  Widget build(BuildContext context) {
    final calldataService = context.read<CalldataService>();
    final treasuryProvider = context.watch<TreasuryProvider>();

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
          final calldataBytes = hexToBytes(calldata);
          if (calldataBytes.length < 4) {
            throw const FormatException("Invalid calldata");
          }
          final selector = calldataBytes.sublist(0, 4);

          String to, displayAmount, symbol;

          if (listEquals(selector, CalldataService.transferNativeSelector)) {
            final params = calldataService.decodeCalldata(CalldataService.transferNativeDef, calldata);
            to = (params[0] as EthereumAddress).hex;
            final amount = params[1] as BigInt;
            displayAmount = formatTotalSupply(amount.toString(), 18);
            symbol = network.nativeCurrencySymbol;

          } else if (listEquals(selector, CalldataService.erc20TreasuryTransferSelector)) {
            final params = calldataService.decodeCalldata(CalldataService.erc20TreasuryTransferDef, calldata);
            final tokenAddressHex = (params[0] as EthereumAddress).hex;
            to = (params[1] as EthereumAddress).hex;
            final amount = params[2] as BigInt;
            
            // THE FIX: Safely find the token asset by checking for a null address first.
            final tokenAsset = treasuryProvider.tokenAssets.firstWhereOrNull(
              (asset) {
                final address = asset.token.address;
                if (address == null) return false;
                return address.toLowerCase() == tokenAddressHex.toLowerCase();
              }
            );

            if (tokenAsset != null) {
              // THE FIX: Safely handle nullable decimals by providing a default value.
              final decimals = tokenAsset.token.decimals ?? 18;
              displayAmount = formatTotalSupply(amount.toString(), decimals);
              symbol = tokenAsset.token.symbol;
            } else {
              displayAmount = amount.toString();
              symbol = 'tokens (wei)';
            }
          } else {
            return const ListTile(
              leading: Icon(Icons.help_outline, color: Colors.amber),
              title: Text('Unknown transfer type'),
              subtitle: Text('Could not identify the function call in the proposal.'),
            );
          }

          return ListTile(
            leading: const Icon(Icons.arrow_forward),
            title: Text('$displayAmount $symbol'),
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
// lib/src/features/proposal_detail/widgets/details/token_transfer_details.dart