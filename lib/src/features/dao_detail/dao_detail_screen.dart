// lib/src/features/dao_detail/dao_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_detail/tabs/account_tab.dart';
import 'package:werule/src/features/dao_detail/tabs/members_tab.dart';
import 'package:werule/src/features/dao_detail/tabs/overview_tab.dart';
import 'package:werule/src/features/dao_detail/tabs/proposals_tab.dart';
import 'package:werule/src/features/dao_detail/tabs/registry_tab.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/widgets/shared_app_bar.dart';

class DaoDetailScreen extends StatefulWidget {
  final String networkName;
  final String daoAddress;

  const DaoDetailScreen({
    super.key,
    required this.networkName,
    required this.daoAddress,
  });

  @override
  State<DaoDetailScreen> createState() => _DaoDetailScreenState();
}

class _DaoDetailScreenState extends State<DaoDetailScreen> {
  late Future<Map<String, dynamic>> _daoDetailsFuture;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NetworkProvider>().selectNetworkByName(widget.networkName);
      }
    });

    final firestoreService = context.read<FirestoreService>();
    _daoDetailsFuture = _fetchDetails(firestoreService);
  }

  Future<Map<String, dynamic>> _fetchDetails(FirestoreService service) async {
    final collection = 'idaos${widget.networkName}';
    final dao = await service.getDao(collection, widget.daoAddress);
    if (dao == null) {
      return {
        'error':
            'DAO ${widget.daoAddress} not found on network ${widget.networkName}.'
      };
    }
    final proposals = await service.getProposals(collection, widget.daoAddress);
    return {'dao': dao, 'proposals': proposals};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff222222),
      appBar: const SharedAppBar(),
      endDrawer: const MobileDrawer(
        isNetworkSelectorEnabled: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _daoDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.containsKey('error')) {
            return Center(
                child: Text(snapshot.data?['error'] ?? 'An error occurred.'));
          }

          final Org dao = snapshot.data!['dao'];
          final List<Proposal> proposals = snapshot.data!['proposals'];
          const tabCount = 5;

          return DefaultTabController(
            length: tabCount,
            child: Scaffold(
              backgroundColor: const Color(0xff222222),
              appBar: AppBar(
                primary: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        return TabBar(
                          // THE FIX: Added colors for selected and unselected tabs.
                          labelColor: Theme.of(context).indicatorColor,
                          unselectedLabelColor: Colors.grey[400],
                          indicatorColor: Theme.of(context).indicatorColor,
                          dividerColor: const Color.fromARGB(255, 59, 59, 59),
                          tabs: [
                            _buildTab("Overview", Icons.dashboard, isMobile),
                            _buildTab("Proposals", Icons.front_hand, isMobile),
                            _buildTab("Registry", Icons.list, isMobile),
                            _buildTab("Members", Icons.people, isMobile),
                            _buildTab("Account", Icons.person, isMobile),
                          ],
                        );
                      }
                    ),
                  ),
                ),
              ),
              body: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: TabBarView(
                    children: [
                      OverviewTab(dao: dao),
                      ProposalsTab(
                          proposals: proposals,
                          networkName: widget.networkName,
                          daoAddress: widget.daoAddress),
                      const RegistryTab(),
                      MembersTab(dao: dao),
                      const AccountTab(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String text, IconData icon, bool isMobile) {
    if (isMobile) {
      return Tab(icon: Icon(icon));
    }
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
// lib/src/features/dao_detail/dao_detail_screen.dart