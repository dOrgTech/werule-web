// lib/src/features/explorer/widgets/app_bar_widgets.dart

import 'dart:typed_data';

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

    // THE FIX: The entire button is wrapped in a Tooltip widget.
    return Tooltip(
      // The message is conditional: it's empty if enabled, and shows the text if disabled.
      message: isEnabled ? '' : "Can't change networks while viewing a DAO or a Proposal",
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(width: 0.1, color: Theme.of(context).indicatorColor),
          color: Theme.of(context).indicatorColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Network>(
            value: networkProvider.selectedNetwork,
            selectedItemBuilder: (context) {
              return networkProvider.networks.map<Widget>((network) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.connect_without_contact_sharp,
                        size: 23,
                        color: Theme.of(context).indicatorColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        network.name,
                        style: TextStyle(
                          fontFamily: 'CascadiaCode',
                          color: Theme.of(context).indicatorColor.withOpacity(0.7),
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                );
              }).toList();
            },
            items: networkProvider.networks.map<DropdownMenuItem<Network>>((Network network) {
              return DropdownMenuItem<Network>(
                value: network,
                child: Text(network.name),
              );
            }).toList(),
            onChanged: isEnabled
                ? (Network? newNetwork) {
                    if (newNetwork != null) {
                      context.go('/${newNetwork.name}');
                      if (authProvider.isConnected) {
                        authProvider.switchWalletChain(newNetwork);
                      }
                    }
                  }
                : null,
          ),
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
    
    return SizedBox(
      width: 210,
      height: 40,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildContent(context, auth),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthProvider auth) {
    // --- LOADING STATE ---
    if (auth.isLoading || auth.isAutoConnecting) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: LinearProgressIndicator(),
      );
    }
    // --- DISCONNECTED STATE ---
    if (!auth.isConnected) {
      return SizedBox(
      
        child: TextButton(
          key: const ValueKey('disconnected'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            minimumSize: const Size(175, 40),
          ),
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
        ),
      );
    }
    // --- CONNECTED STATE ---
    return DropdownButtonHideUnderline(
      key: const ValueKey('connected'),
      child: DropdownButton<String>(
        isExpanded: true, 
        value: auth.selectedAccount,
        selectedItemBuilder: (context) {
            return auth.accounts.map<Widget>((account) {
              return Row(
                children: [
                  FutureBuilder<Uint8List>(
                    future: generateAvatarAsync(hashString(auth.selectedAccount!), size: 32, pixelSize: 4),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                          return ClipOval(child: Image.memory(snapshot.data!));
                      }
                      return SizedBox(
                        width: 32,
                        height: 32,
                        child: CircleAvatar(backgroundColor: Colors.grey.shade800),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      shortenString(auth.selectedAccount!),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList();
        },
        items: auth.accounts.map<DropdownMenuItem<String>>((String account) {
          return DropdownMenuItem<String>(
            value: account,
            child: Text(shortenString(account)),
          );
        }).toList(),
        onChanged: (String? newAccount) {
          context.read<AuthProvider>().selectAccount(newAccount);
        },
      ),
    );
  }
}
// lib/src/features/explorer/widgets/app_bar_widgets.dart```