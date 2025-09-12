// lib/src/features/proposal_detail/proposal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/firestore_service.dart';

class ProposalDetailScreen extends StatefulWidget {
  final String networkName;
  final String daoAddress;
  final String proposalId;

  const ProposalDetailScreen({
    super.key,
    required this.networkName,
    required this.daoAddress,
    required this.proposalId,
  });

  @override
  State<ProposalDetailScreen> createState() => _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends State<ProposalDetailScreen> {
  late Future<Proposal?> _proposalFuture;

  @override
  void initState() {
    super.initState();
    final firestoreService = context.read<FirestoreService>();
    final collection = 'idaos${widget.networkName}';
    _proposalFuture = firestoreService.getProposal(collection, widget.daoAddress, widget.proposalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proposal Details'),
        leading: BackButton(onPressed: () => context.go('/${widget.networkName}/${widget.daoAddress}')),
      ),
      body: FutureBuilder<Proposal?>(
        future: _proposalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Proposal ${widget.proposalId} not found.'));
          }

          final proposal = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(proposal.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(proposal.description),
              const Divider(height: 40),
              ListTile(title: const Text('Author'), subtitle: Text(proposal.author)),
              ListTile(title: const Text('ID'), subtitle: Text(proposal.id)),
              ListTile(title: const Text('Votes For'), subtitle: Text(proposal.inFavor.toString())),
              ListTile(title: const Text('Votes Against'), subtitle: Text(proposal.against.toString())),
            ],
          );
        },
      ),
    );
  }
}
// lib/src/features/proposal_detail/proposal_detail_screen.dart