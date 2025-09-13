// lib/src/features/explorer/explorer_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/explorer/widgets/game_of_life.dart';
import 'package:werule/src/providers/auth_provider.dart';

import '../../models/network.dart';
import '../../providers/dao_provider.dart';
import '../../providers/network_provider.dart';
import '../../utils/reusable.dart';
// Import the new shared AppBar
import 'widgets/dao_card.dart';
import '../../widgets/shared_app_bar.dart';

class ExplorerScreen extends StatefulWidget {
  final String? networkName;
  const ExplorerScreen({super.key, this.networkName});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.networkName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<NetworkProvider>().selectNetworkByName(widget.networkName!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final networkProvider = context.watch<NetworkProvider>();

    final isChainSupported = !auth.isConnected || (auth.chainId != null && networkProvider.isChainSupported(auth.chainId!));

    return Scaffold(
      backgroundColor: const Color(0xff222222),
      appBar: const SharedAppBar(
        isNetworkSelectorEnabled: true,
      ),
      endDrawer: const MobileDrawer(
        isNetworkSelectorEnabled: true,
      ),
      body: Stack(
        children: [
          const Opacity(
            opacity: 0.03,
            child: GameOfLife(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 20.0),
                      child: _TopBar(),
                    ),
                    auth.isAutoConnecting
                        ? const Center(child: CircularProgressIndicator())
                        : !isChainSupported
                            ? const _WrongNetworkScreen()
                            : Consumer<DaoProvider>(
                                builder: (context, daoProvider, child) {
                                  // THE FIX: Use AnimatedSwitcher to fade between states (e.g., loading and loaded).
                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    child: _buildDaoContent(context, daoProvider),
                                  );
                                },
                              ),
                    const _PaginationControls(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // THE FIX: Extracted the content logic into a separate method for clarity.
  Widget _buildDaoContent(BuildContext context, DaoProvider daoProvider) {
    // A unique key is used for each state, telling AnimatedSwitcher to perform the transition.
    switch (daoProvider.state) {
      case DataState.loading:
        return const Center(
          key: ValueKey('loading'),
          child: CircularProgressIndicator(),
        );
      case DataState.error:
        return Center(
          key: const ValueKey('error'),
          child: Text('Error: ${daoProvider.errorMessage}'),
        );
      case DataState.loaded:
        if (daoProvider.displayedDaos.isEmpty) {
          return const Padding(
            key: ValueKey('empty'),
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('No DAOs found matching your search.')),
          );
        }
        return LayoutBuilder(
          key: ValueKey('loaded_${daoProvider.totalDaoCount}'), // Key changes when data reloads
          builder: (context, constraints) {
            int crossAxisCount;
            double childAspectRatio;
            if (constraints.maxWidth < 600) { crossAxisCount = 1; childAspectRatio = 1.8;
            } else if (constraints.maxWidth < 950) { crossAxisCount = 2; childAspectRatio = 1.6;
            } else { crossAxisCount = 3; childAspectRatio = 1.7; }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, mainAxisSpacing: 16.0, crossAxisSpacing: 16.0, childAspectRatio: childAspectRatio,
              ),
              itemCount: daoProvider.displayedDaos.length,
              itemBuilder: (context, index) {
                final org = daoProvider.displayedDaos[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  onTap: () {
                    final selectedNetwork = context.read<NetworkProvider>().selectedNetwork;
                    if (selectedNetwork != null) {
                      context.go('/${selectedNetwork.name}/${org.address}');
                    }
                  },
                  child: DAOCard(org: org),
                );
              },
            );
          });
      case DataState.initial:
        return const Center(
          key: ValueKey('initial'),
          child: Text("Select a network to begin."),
        );
    }
  }
}

class _WrongNetworkScreen extends StatelessWidget {
  const _WrongNetworkScreen();
  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    final authProvider = context.read<AuthProvider>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.amber, size: 60),
          const SizedBox(height: 24),
          const Text("Network Not Supported", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Please switch to one of the following networks in your wallet:"),
          const SizedBox(height: 24),
          ...networkProvider.networks.map((network) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () => authProvider.switchWalletChain(network),
              child: Text("Switch to ${network.name}"),
            ),
          )),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    final daoProvider = context.watch<DaoProvider>();
    final isMobile = MediaQuery.of(context).size.width < 700;
    final searchBar = TextField(onChanged: (value) => daoProvider.search(value), decoration: InputDecoration(hintText: 'Find DAO by name or address', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.grey)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).indicatorColor))));
    final daoCount = Text('${daoProvider.totalDaoCount} DAOs', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    final createDaoButton = ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffa1d0d0), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Create DAO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)));
    if (isMobile) {
      return Column(children: [searchBar, const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [daoCount, createDaoButton])]);
    } else {
      return Row(children: [Expanded(flex: 2, child: searchBar), const Spacer(flex: 1), daoCount, const SizedBox(width: 24), createDaoButton]);
    }
  }
}

class _PaginationControls extends StatelessWidget {
  const _PaginationControls();
  @override
  Widget build(BuildContext context) {
    final daoProvider = context.watch<DaoProvider>();
    if (daoProvider.state != DataState.loaded || daoProvider.totalPages <= 1) {
      return const SizedBox.shrink();
    }
    final currentPage = daoProvider.currentPage;
    final totalPages = daoProvider.totalPages;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: SizedBox(height: 52, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(icon: const Icon(Icons.first_page), onPressed: currentPage > 1 ? () => daoProvider.changePage(1) : null), IconButton(icon: const Icon(Icons.chevron_left), onPressed: currentPage > 1 ? () => daoProvider.changePage(currentPage - 1) : null), Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text('Page $currentPage of $totalPages')), IconButton(icon: const Icon(Icons.chevron_right), onPressed: currentPage < totalPages ? () => daoProvider.changePage(currentPage + 1) : null), IconButton(icon: const Icon(Icons.last_page), onPressed: currentPage < totalPages ? () => daoProvider.changePage(totalPages) : null)])),
    );
  }
}
// lib/src/features/explorer/explorer_screen.dart