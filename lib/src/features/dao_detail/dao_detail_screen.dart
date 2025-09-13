// lib/src/features/dao_detail/dao_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_detail/widgets/dao_members_widget.dart';
import 'package:werule/src/features/dao_detail/widgets/dao_treasury_widget.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/utils/reusable.dart';
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
      return {'error': 'DAO ${widget.daoAddress} not found on network ${widget.networkName}.'};
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
          if (snapshot.hasError || snapshot.data == null || snapshot.data!.containsKey('error')) {
            return Center(child: Text(snapshot.data?['error'] ?? 'An error occurred.'));
          }

          final Org dao = snapshot.data!['dao'];
          final List<Proposal> proposals = snapshot.data!['proposals'];

          return DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: const Color(0xff222222),
              appBar: AppBar(
                primary: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                // THE FIX: Disable the automatic back button.
                automaticallyImplyLeading: false,
                // THE FIX: Constrain the width of the TabBar to match the page content.
                title: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: const TabBar(
                      tabs: [
                        Tab(text: 'Home'),
                        Tab(text: 'Members'),
                        Tab(text: 'Proposals'),
                      ],
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
                      _HomeTab(dao: dao),
                      _MembersTab(dao: dao),
                      _ProposalsTab(proposals: proposals, networkName: widget.networkName, daoAddress: widget.daoAddress),
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
}

// --- WIDGET FOR TAB 1: HOME ---
class _HomeTab extends StatelessWidget {
  final Org dao;
  const _HomeTab({required this.dao});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dao.name, style: Theme.of(context).textTheme.headlineMedium),
          Text("Registry: ${dao.registryAddress}", style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Text(dao.description),
          DaoTreasuryWidget(dao: dao),
        ],
      ),
    );
  }
}

// --- WIDGET FOR TAB 2: MEMBERS ---
class _MembersTab extends StatelessWidget {
  final Org dao;
  const _MembersTab({required this.dao});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
       padding: const EdgeInsets.symmetric(vertical: 16),
      child: DaoMembersWidget(dao: dao),
    );
  }
}

// --- WIDGET FOR TAB 3: PROPOSALS ---
class _ProposalsTab extends StatelessWidget {
  final List<Proposal> proposals;
  final String networkName;
  final String daoAddress;

  const _ProposalsTab({
    required this.proposals,
    required this.networkName,
    required this.daoAddress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (proposals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 48.0),
              child: Text('No proposals found for this DAO.'),
            ),
          )
        else
          ...proposals.map((p) => ListTile(
                title: Text(p.title),
                subtitle: Text('By: ${shortenString(p.author)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go('/$networkName/$daoAddress/proposals/${p.id}');
                },
              )),
      ],
    );
  }
}
// lib/src/features/dao_detail/dao_detail_screen.dart