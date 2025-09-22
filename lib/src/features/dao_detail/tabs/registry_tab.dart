// lib/src/features/dao_detail/tabs/registry_tab.dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/create_proposal/create_proposal_dialog.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/registry_item.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/create_proposal_provider.dart';
import 'package:werule/src/providers/dao_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/providers/registry_provider.dart';
import 'package:werule/src/providers/treasury_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/calldata_service.dart';
import 'package:werule/src/services/registry_service.dart';
import 'package:werule/src/services/treasury_service.dart';

class RegistryTab extends StatefulWidget {
  final Org dao;
  const RegistryTab({super.key, required this.dao});

  @override
  State<RegistryTab> createState() => _RegistryTabState();
}

class _RegistryTabState extends State<RegistryTab> {
  final _searchController = TextEditingController();
  List<RegistryItem> _filteredItems = [];
  List<RegistryItem> _allItems = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems
          .where((item) => item.key.toLowerCase().contains(query))
          .toList();
    });
  }

  void _showCreateProposalDialog() {
    final auth = context.read<AuthProvider>();
    if (!auth.isConnected || auth.selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(
            child: Text("Please connect your wallet to create a proposal.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    final network = context
        .read<NetworkProvider>()
        .networks
        .firstWhereOrNull((n) => n.name == widget.dao.name);
    if (network == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(
            child: Text("Cannot create proposal: Network details not found.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => CreateProposalProvider(
                org: widget.dao,
                signerAddress: auth.selectedAccount!,
                calldata: context.read<CalldataService>(),
                blockchain: context.read<BlockchainService>(),
              )..setProposalType(ProposalType.registry),
            ),
            ChangeNotifierProvider(
              create: (_) => TreasuryProvider(
                context.read<TreasuryService>(),
                widget.dao,
                network,
              ),
            ),
          ],
          child: CreateProposalDialog(org: widget.dao),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final network = context.watch<NetworkProvider>().selectedNetwork;
    if (network == null) {
      return const Center(child: Text("Please select a network."));
    }

    return ChangeNotifierProvider(
      create: (context) => RegistryProvider(
        context.read<RegistryService>(),
        widget.dao,
        network,
      ),
      child: Consumer<RegistryProvider>(
        builder: (context, provider, child) {
          if (provider.state == DataState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.state == DataState.error) {
            return Center(child: Text("Error: ${provider.errorMessage}"));
          }

          // Update local lists when provider finishes loading
          if (_allItems != provider.items) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _allItems = provider.items;
              _filterItems();
            });
          }

          return LayoutBuilder(builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Column(
                children: [
                  _buildControls(isMobile),
                  const SizedBox(height: 24),
                  if (_filteredItems.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text("No registry items found.",
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    Expanded(
                      child: isMobile
                          ? _buildMobileList()
                          : _buildDesktopTable(),
                    )
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildControls(bool isMobile) {
    final searchBar = TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: 'Search by Key',
      ),
    );

    final editButton = ElevatedButton(
      onPressed: _showCreateProposalDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).indicatorColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Add/Edit Item',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
    );

    if (isMobile) {
      return Column(
        children: [
          searchBar,
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerRight, child: editButton),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 2, child: searchBar),
        const Spacer(flex: 1),
        editButton,
      ],
    );
  }

  Widget _buildDesktopTable() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DefaultTextStyle(
            style:
                TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
            child: const Row(
              children: [
                SizedBox(width: 200, child: Text("KEY")),
                Expanded(child: Text("VALUE")),
              ],
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return _RegistryItemCardDesktop(item: item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _RegistryItemCardMobile(item: item);
      },
    );
  }
}

// --- Desktop Item Card ---
class _RegistryItemCardDesktop extends StatelessWidget {
  final RegistryItem item;
  const _RegistryItemCardDesktop({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: const Color(0xff2c2c2c),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(item.key,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  splashRadius: 22,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: item.value));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Center(child: Text("Value copied")),
                        duration: Duration(seconds: 1)));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Mobile Item Card ---
class _RegistryItemCardMobile extends StatelessWidget {
  final RegistryItem item;
  const _RegistryItemCardMobile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff2c2c2c),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.key,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 16),
            Text(item.value, style: TextStyle(color: Colors.grey[300])),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.value));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Center(child: Text("Value copied")),
                      duration: Duration(seconds: 1)));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
// lib/src/features/dao_detail/tabs/registry_tab.dart