// lib/src/features/dao_detail/widgets/dao_treasury_widget.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/network.dart';
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
    // We need the current network to fetch balances
    final network = context.watch<NetworkProvider>().selectedNetwork;

    if (network == null) {
      return const Center(child: Text("Network not selected."));
    }

    // The provider will be responsible for fetching and holding the treasury state
    return ChangeNotifierProvider(
      create: (context) => TreasuryProvider(
        context.read<TreasuryService>(),
        dao,
        network,
      ),
      child: const _TreasuryView(),
    );
  }
}

class _TreasuryView extends StatefulWidget {
  const _TreasuryView();

  @override
  State<_TreasuryView> createState() => _TreasuryViewState();
}

class _TreasuryViewState extends State<_TreasuryView> {
  int _selectedTab = 0; // 0 for Tokens, 1 for NFTs
  String _searchQuery = ''; // THE FIX: State for the search query

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff2c2c2c),
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Treasury', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
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
                  // THE FIX: Apply search filter
                  final displayedAssets = provider.tokenAssets.where((asset) {
                    if (_searchQuery.isEmpty) {
                      return true;
                    }
                    final query = _searchQuery.toLowerCase();
                    return asset.token.name.toLowerCase().contains(query) ||
                           asset.token.symbol.toLowerCase().contains(query) ||
                           (asset.token.address?.toLowerCase().contains(query) ?? false);
                  }).toList();

                  // Fungible Tokens View
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
                  return _buildTokensTable(displayedAssets);
                } else {
                  // NFTs View
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
            // THE FIX: The text field is now enabled.
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              prefixIcon: const Icon(Icons.search),
              hintText: 'Find token by name, symbol, or address',
            ),
          );

        final toggleButtons = ToggleButtons(
          isSelected: [_selectedTab == 0, _selectedTab == 1],
          onPressed: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
          borderRadius: BorderRadius.circular(8),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Tokens'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('NFTs'),
            ),
          ],
        );

        if (isMobile) {
          return Column(
            children: [
              searchBar,
              const SizedBox(height: 16),
              toggleButtons,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: searchBar),
            const SizedBox(width: 24),
            toggleButtons,
          ],
        );
      }
    );
  }

  Widget _buildTokensTable(List<TokenAsset> assets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2.0), // Name
            1: FlexColumnWidth(0.8), // Symbol
            2: FlexColumnWidth(1.2), // Amount
            3: FlexColumnWidth(1.5), // Address
            4: FlexColumnWidth(1.0), // Actions
          },
          children: const [
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("TOKEN NAME"),
                ),
                Center(child: Text("SYMBOL")),
                Center(child: Text("AMOUNT")),
                Center(child: Text("ADDRESS")),
                SizedBox(), // For actions column header
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
          child: ElevatedButton(
             onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(child: Text('Transfers coming soon!')),
                      duration: Duration(seconds: 2),
                    ),
                  );
             },
             child: const Text("Transfer"),
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