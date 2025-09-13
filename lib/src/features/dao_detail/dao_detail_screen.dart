// lib/src/features/dao_detail/dao_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
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
      // Use the SharedAppBar, selector is disabled by default.
      appBar: const SharedAppBar(),
      // Add the endDrawer for mobile.
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

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(dao.name, style: Theme.of(context).textTheme.headlineMedium),
                  Text(dao.address, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  Text(dao.description),
                  const Divider(height: 40),
                  Text('Proposals', style: Theme.of(context).textTheme.headlineSmall),
                  if (proposals.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('No proposals found for this DAO.'),
                    )
                  else
                    ...proposals.map((p) => ListTile(
                          title: Text(p.title),
                          subtitle: Text('By: ${p.author.substring(0, 10)}...'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.go('/${widget.networkName}/${widget.daoAddress}/proposals/${p.id}');
                          },
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// lib/src/features/dao_detail/dao_detail_screen.dart