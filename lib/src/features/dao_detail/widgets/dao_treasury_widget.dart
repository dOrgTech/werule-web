// lib/src/features/dao_detail/widgets/dao_treasury_widget.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_detail/tabs/proposals_tab.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/token_asset.dart';
import 'package:werule/src/providers/dao_provider.dart'; // for DataState
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/providers/treasury_provider.dart';
import 'package:werule/src/services/treasury_service.dart';
import 'package:werule/src/utils/reusable.dart';

class DaoTreasuryWidget extends StatelessWidget {
  final Org dao;
  const DaoTreasuryWidget({super.key, required this.dao});

  @override
  Widget build(BuildContext context) {
    final network = context.watch<NetworkProvider>().selectedNetwork;

    if (network == null) {
      return const Center(child: Text("Network not selected."));
    }

    return ChangeNotifierProvider(
      create: (context) => TreasuryProvider(
        context.read<TreasuryService>(),
        dao,
        network,
      ),
      child:  _TreasuryView(dao: dao,),
    );
  }
}

class _TreasuryView extends StatefulWidget {
  const _TreasuryView({required this.dao});
   final Org dao;
  @override
  State<_TreasuryView> createState() => _TreasuryViewState();
}

class _TreasuryViewState extends State<_TreasuryView> {
  int _selectedTab = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff2c2c2c),
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // THE FIX: "Treasury" text has been removed.
            _buildControls(),
            const SizedBox(height: 15),
            Consumer<TreasuryProvider>(
              builder: (context, provider, child) {
                if (provider.state == DataState.loading) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 58.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                if (provider.state == DataState.error) {
                  return Center(child: Text('Error: ${provider.errorMessage}'));
                }

                if (_selectedTab == 0) {
                  final displayedAssets = provider.tokenAssets.where((asset) {
                    if (_searchQuery.isEmpty) return true;
                    final query = _searchQuery.toLowerCase();
                    return asset.token.name.toLowerCase().contains(query) ||
                           asset.token.symbol.toLowerCase().contains(query) ||
                           (asset.token.address?.toLowerCase().contains(query) ?? false);
                  }).toList();

                  if (displayedAssets.isEmpty) {
                     return Center(
                        child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 58.0),
                        child: Text(
                          _searchQuery.isEmpty
                            ? "No tokens found in treasury."
                            : "No tokens found matching '$_searchQuery'.",
                            style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ));
                  }
                  
                  // THE FIX: Use a LayoutBuilder to choose the correct view.
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 700) {
                        return _buildTokensList(displayedAssets); // Mobile View
                      } else {
                        return _buildTokensTable(displayedAssets); // Desktop View
                      }
                    },
                  );
                } else {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 58.0),
                      child: Text("NFTs are not yet supported.",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final searchBar = TextField(
            onChanged: (value) {
              setState(() { _searchQuery = value; });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              prefixIcon: Icon(Icons.search),
              hintText: 'Find token by name, address, or symbol',
            ),
          );

        final toggleButtons = ToggleButtons(
          selectedColor: Theme.of(context).indicatorColor,
          isSelected: [_selectedTab == 0, _selectedTab == 1],
          onPressed: (index) { setState(() { _selectedTab = index; }); },
          borderRadius: BorderRadius.circular(8),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Tokens')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('NFTs')),
          ],
        );

        if (isMobile) {
          return Column(
            children: [ searchBar, const SizedBox(height: 16), toggleButtons ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // THE FIX: Use Flexible with a spacer to control search bar width.
            Flexible(flex: 2, child: searchBar),
            const Spacer(flex: 1),
            toggleButtons,
          ],
        );
      }
    );
  }

  // --- NEW: Mobile-friendly list view ---
  Widget _buildTokensList(List<TokenAsset> assets) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return Card(
          color: const Color(0xff3a3a3a),
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        asset.token.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayTokenValue(asset.balance, asset.token.decimals ?? 18),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  asset.token.symbol,
                  style: TextStyle(color: Theme.of(context).indicatorColor),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        asset.token.address == 'native'
                            ? "Native Token"
                            : shortenString(asset.token.address ?? ""),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (asset.token.address != 'native')
                      IconButton(
                        iconSize: 18,
                        splashRadius: 22,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: asset.token.address!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Center(child: Text('Copied token address to clipboard')),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, color: Colors.white70),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 30,
                  width: 120,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 196, 196, 196)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Center(child: Text('Transfers coming soon!')),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text("Transfer", style: TextStyle(color: Colors.black),),
                      
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Existing desktop table view ---
  Widget _buildTokensTable(List<TokenAsset> assets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2.0),
            1: FlexColumnWidth(0.8),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.0),
          },
          children: const [
            TableRow(
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: Text("TOKEN NAME")),
                Center(child: Text("SYMBOL")),
                Center(child: Text("AMOUNT")),
                Center(child: Text("ADDRESS")),
                SizedBox(),
              ],
            ),
          ],
        ),
        const Divider(),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2.0),
            1: FlexColumnWidth(0.8),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.0),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: assets.map((asset) => _buildAssetRow(asset)).toList(),
        ),
      ],
    );
  }

  TableRow _buildAssetRow(TokenAsset asset) {
     return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(asset.token.name, style: const TextStyle(fontSize: 14)),
        ),
        Center(
          child: Text(
            asset.token.symbol,
            style: TextStyle(color: Theme.of(context).indicatorColor, fontSize: 14),
          ),
        ),
        Center(
          child: Text(
            displayTokenValue(asset.balance, asset.token.decimals ?? 18),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  asset.token.address == 'native'
                      ? "Native Token"
                      : shortenString(asset.token.address ?? ""),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (asset.token.address != 'native')
              IconButton(
                iconSize: 16,
                splashRadius: 20,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: asset.token.address!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Copied token address to clipboard')),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child:    SizedBox(
                  height: 30,
                  width: 120,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        backgroundColor: const Color.fromARGB(255, 151, 151, 151)),
                      onPressed: () {
                         final networkName = widget.dao.address.contains("Etherlink-Testnet") ? "Etherlink-Testnet" : "Etherlink";
        ProposalsTab.showCreateProposalDialog(context, widget.dao, networkName);
                      },
                      child: const Text("Transfer", style: TextStyle(color: Colors.black),),
                      
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String displayTokenValue(String value, int decimals) {
    final BigInt intValue = BigInt.tryParse(value) ?? BigInt.zero;
    if (intValue == BigInt.zero) return '0.0000';
    final double doubleValue = intValue / BigInt.from(pow(10, decimals));
    if (doubleValue > 0 && doubleValue < 0.0001) {
      return '< 0.0001';
    }
    return doubleValue.toStringAsFixed(4);
  }
}
// lib/src/features/dao_detail/widgets/dao_treasury_widget.dart