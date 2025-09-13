// lib/src/features/explorer/widgets/app_bar_widgets.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/utils/reusable.dart';

class NetworkSelector extends StatelessWidget {
  final bool isEnabled;
  const NetworkSelector({super.key, this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    final authProvider = context.read<AuthProvider>();

    if (networkProvider.isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))));
    }
    if (networkProvider.networks.isEmpty || networkProvider.selectedNetwork == null) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text("No Networks")));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Network>(
          value: networkProvider.selectedNetwork,
          icon: const Icon(Icons.keyboard_arrow_down),
          // Use the `isEnabled` flag to disable the dropdown
          onChanged: isEnabled
              ? (Network? newNetwork) {
                  if (newNetwork != null) {
                    context.go('/${newNetwork.name}');
                    if (authProvider.isConnected) {
                      authProvider.switchWalletChain(newNetwork);
                    }
                  }
                }
              : null, // Setting onChanged to null disables the button
          items: networkProvider.networks.map<DropdownMenuItem<Network>>((Network network) {
            return DropdownMenuItem<Network>(
              value: network,
              child: Text(network.name),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class WalletConnector extends StatelessWidget {
  const WalletConnector({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading || auth.isAutoConnecting) {
      return const Center(child: Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))));
    }
    if (!auth.isConnected) {
      return ElevatedButton(
        onPressed: () {
          if (auth.isWalletAvailable) {
            context.read<AuthProvider>().connectWallet();
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: const Color(0xff2c2c2c),
                  title: const Text('No Wallet Detected'),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('A web3 wallet (like MetaMask or Rabby) is required to connect.'),
                        SizedBox(height: 8),
                        Text('Please install a browser extension and refresh the page.'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        child: const Text("Connect Wallet"),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: auth.selectedAccount,
          icon: const Icon(Icons.keyboard_arrow_down),
          onChanged: (String? newAccount) {
            context.read<AuthProvider>().selectAccount(newAccount);
          },
          items: auth.accounts.map<DropdownMenuItem<String>>((String account) {
            return DropdownMenuItem<String>(
              value: account,
              child: Text(shortenString(account)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
// lib/src/features/explorer/widgets/app_bar_widgets.dart