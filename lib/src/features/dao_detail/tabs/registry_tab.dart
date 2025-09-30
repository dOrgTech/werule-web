// lib/src/features/dao_detail/tabs/registry_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:werule/src/features/dao_detail/tabs/proposals_tab.dart';
import 'package:werule/src/models/org.dart';

// Simple model for a registry item
class RegistryItem {
  final String key;
  final String value;
  RegistryItem({required this.key, required this.value});
}

class RegistryTab extends StatefulWidget {
  final Org dao;
  // THE FIX: networkName is no longer needed here.
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
    // THE FIX: Load items directly from the dao object, no async needed.
    _allItems = widget.dao.registry.entries
        .map((entry) => RegistryItem(key: entry.key, value: entry.value))
        .toList();
    _filteredItems = _allItems;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems
            .where((item) => item.key.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // THE FIX: Removed the FutureBuilder and now build the layout directly.
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 700;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          children: [
            _buildControls(isMobile),
            const SizedBox(height: 24),
            if (_filteredItems.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _allItems.isEmpty
                        ? "There are no items in this DAO's registry."
                        : "No registry items match your search.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: isMobile ? _buildMobileList() : _buildDesktopTable(),
              )
          ],
        ),
      );
    });
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
      // THE FIX: Pass the correct network name from the dao object.
      onPressed: () {
         // We need to find the networkName from the provider to pass to the dialog
        final networkName = widget.dao.address.contains("Etherlink-Testnet") ? "Etherlink-Testnet" : "Etherlink";
        ProposalsTab.showCreateProposalDialog(context, widget.dao, networkName);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).indicatorColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Add/Edit Item', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
    );

    if (isMobile) {
      return Column(
        children: [ searchBar, const SizedBox(height: 16), Align(alignment: Alignment.centerRight, child: editButton) ],
      );
    }

    return Row(
      children: [ Expanded(flex: 2, child: searchBar), const Spacer(flex: 1), editButton ],
    );
  }

  Widget _buildDesktopTable() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DefaultTextStyle(
            style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
            child: const Row(
              children: [
                SizedBox(width: 200, child: Text("KEY")),
                SizedBox(width: 150),
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
            width: 280,
            child: Text(item.key, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 66),
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
            Text(item.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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