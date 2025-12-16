// lib/src/features/dao_detail/tabs/debates_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/create_debate/create_debate_dialog.dart';
import 'package:werule/src/features/dao_detail/widgets/debate_list_item.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/debates_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:collection/collection.dart';

/// Tab for displaying and managing tokenized debates
class DebatesTab extends StatefulWidget {
  final Org org;
  final String networkName;

  const DebatesTab({
    super.key,
    required this.org,
    required this.networkName,
  });

  @override
  State<DebatesTab> createState() => _DebatesTabState();
}

class _DebatesTabState extends State<DebatesTab> {
  DebatesProvider? _debatesProvider;
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    final network = context.read<NetworkProvider>().networks.firstWhereOrNull(
          (n) => n.name == widget.networkName,
        );

    if (network == null) {
      setState(() {
        _initError = "Network not found";
        _isInitializing = false;
      });
      return;
    }

    // Get debates factory address from Firestore
    final firestoreService = context.read<FirestoreService>();
    final debatesFactory = await firestoreService.getDebatesFactoryAddress(widget.networkName);

    if (!mounted) return;

    if (debatesFactory == null || debatesFactory.isEmpty) {
      setState(() {
        _initError = "Debates are not yet available on this network.";
        _isInitializing = false;
      });
      return;
    }

    _debatesProvider = DebatesProvider(
      blockchainService: context.read<BlockchainService>(),
      authProvider: context.read<AuthProvider>(),
      org: widget.org,
      network: network,
      debatesFactoryAddress: debatesFactory,
    );

    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _showCreateDebateDialog() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isConnected || auth.selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(child: Text("Please connect your wallet to create a debate.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    if (_debatesProvider == null) return;

    // Fetch voting power before showing dialog
    await _debatesProvider!.fetchUserVotingPower();

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: _debatesProvider!,
          child: CreateDebateDialog(org: widget.org),
        );
      },
    );

    // If debate was created successfully, refresh
    if (result == true) {
      await _debatesProvider!.fetchDebates();
    }
  }

  @override
  void dispose() {
    _debatesProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_initError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _initError!,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_debatesProvider == null) {
      return const Center(child: Text("Failed to initialize debates"));
    }

    return ListenableBuilder(
      listenable: _debatesProvider!,
      builder: (context, _) {
        return Column(
          children: [
            _buildControls(),
            const SizedBox(height: 20),
            Expanded(child: _buildDebatesList()),
          ],
        );
      },
    );
  }

  Widget _buildControls() {
    final debates = _debatesProvider!.debates;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final createDebateButton = ElevatedButton(
          onPressed: _showCreateDebateDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffa1d0d0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.black),
              SizedBox(width: 8),
              Text('New Debate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.forum, color: Color(0xffa1d0d0)),
                  const SizedBox(width: 8),
                  Text(
                    '${debates.length} Debate${debates.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _debatesProvider!.fetchDebates(),
                    tooltip: 'Refresh debates',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              createDebateButton,
            ],
          );
        }

        return Row(
          children: [
            const Icon(Icons.forum, color: Color(0xffa1d0d0)),
            const SizedBox(width: 8),
            Text(
              '${debates.length} Debate${debates.length == 1 ? '' : 's'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _debatesProvider!.fetchDebates(),
              tooltip: 'Refresh debates',
            ),
            const SizedBox(width: 8),
            createDebateButton,
          ],
        );
      }),
    );
  }

  Widget _buildDebatesList() {
    if (_debatesProvider!.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_debatesProvider!.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_debatesProvider!.error!, style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _debatesProvider!.fetchDebates(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final debates = _debatesProvider!.debates;

    if (debates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No debates yet',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new debate to discuss important topics',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Desktop header
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth < 700) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff2c2c2c),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Expanded(flex: 3, child: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 2, child: Text('Creator', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(width: 140, child: Text('Created', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(width: 100, child: Text('Arguments', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(width: 120, child: Center(child: Text('Sentiment', style: TextStyle(fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 80, child: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)))),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: debates.length,
              itemBuilder: (context, index) {
                final debate = debates[index];
                return DebateListItemWidget(
                  debate: debate,
                  org: widget.org,
                  networkName: widget.networkName,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
