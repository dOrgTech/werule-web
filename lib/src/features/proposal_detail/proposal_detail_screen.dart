// lib/src/features/proposal_detail/proposal_detail_screen.dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_actions_card.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_execution_details_card.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_lifecycle_card.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_status_widget.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_votes_card.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/providers/proposal_detail_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/utils/reusable.dart';
import 'package:werule/src/widgets/shared_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late Stream<Proposal?> _proposalStream;
  late Future<Org?> _orgFuture;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NetworkProvider>().selectNetworkByName(widget.networkName);
      }
    });

    final firestoreService = context.read<FirestoreService>();
    final collection = 'idaos${widget.networkName}';
    _proposalStream = firestoreService.getProposalStream(collection, widget.daoAddress, widget.proposalId);
    _orgFuture = firestoreService.getDao(collection, widget.daoAddress);
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();

    return Scaffold(
      backgroundColor: const Color(0xff222222),
      appBar: const SharedAppBar(),
      endDrawer: const MobileDrawer(isNetworkSelectorEnabled: false),
      body: Builder(builder: (context) {
        if (networkProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final network = networkProvider.networks.firstWhereOrNull((n) => n.name == widget.networkName);

        if (network == null) {
          return Center(child: Text('Network configuration for "${widget.networkName}" not found.'));
        }

        return FutureBuilder<Org?>(
          future: _orgFuture,
          builder: (context, orgSnapshot) {
            if (!orgSnapshot.hasData) return const Center(child: CircularProgressIndicator());
            final org = orgSnapshot.data!;

            return StreamBuilder<Proposal?>(
              stream: _proposalStream,
              builder: (context, proposalSnapshot) {
                if (proposalSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (proposalSnapshot.hasError) {
                  return Center(child: Text('An error occurred: ${proposalSnapshot.error}'));
                }
                if (!proposalSnapshot.hasData || proposalSnapshot.data == null) {
                  return Center(child: Text('Proposal ${widget.proposalId} not found.'));
                }

                final proposal = proposalSnapshot.data!;

                return ChangeNotifierProvider(
                  create: (context) => ProposalDetailProvider(
                    blockchainService: context.read<BlockchainService>(),
                    proposal: proposal,
                    org: org,
                    network: network,
                  ),
                  child: _ProposalDetailView(
                    networkName: widget.networkName,
                    daoAddress: widget.daoAddress,
                    proposal: proposal,
                    org: org,
                    network: network, // Pass network down
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}

// --- Main View ---
class _ProposalDetailView extends StatelessWidget {
  final String networkName;
  final String daoAddress;
  final Proposal proposal;
  final Org org;
  final Network network; // Added network

  const _ProposalDetailView({
    required this.networkName,
    required this.daoAddress,
    required this.proposal,
    required this.org,
    required this.network, // Added network
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to DAO'),
                  onPressed: () => context.go('/$networkName/$daoAddress'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
              
              _ProposalHeader(proposal: proposal),
              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 900) {
                    return Column(
                      children: [
                        const ProposalActionsCard(),
                        const SizedBox(height: 16),
                        ProposalVotesCard(org: org),
                        const SizedBox(height: 16),
                        ProposalLifecycleCard(proposal: proposal),
                         const SizedBox(height: 16),
                        SizedBox(height: 300, child: ProposalExecutionDetailsCard(proposal: proposal, org: org, network: network)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(child: ProposalActionsCard()),
                            const SizedBox(width: 16),
                            Expanded(child: ProposalVotesCard(org: org)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: ProposalLifecycleCard(proposal: proposal)),
                            const SizedBox(width: 16),
                            Expanded(child: SizedBox(height: 300, child: ProposalExecutionDetailsCard(proposal: proposal, org: org, network: network))),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
               const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Header Widget ---
class _ProposalHeader extends StatelessWidget {
  final Proposal proposal;
  const _ProposalHeader({required this.proposal});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final typeText = proposal.type != null ? proposal.type! : "proposal";
    final discussionLink = (proposal.externalResource != null && proposal.externalResource!.isNotEmpty)
      ? OldSchoolLink(text: proposal.externalResource!, url: proposal.externalResource!)
      : const Text("No link provided", style: TextStyle(color: Colors.grey));

    final titleWidget = Text(
      proposal.title,
      textAlign: TextAlign.center,
      style: textTheme.headlineMedium?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold),
    );

    final statusWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Consumer<ProposalDetailProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
            if (provider.errorMessage != null) return Tooltip(message: "Could not get on-chain status: ${provider.errorMessage}", child: const Icon(Icons.error_outline, color: Colors.amber));
            return ProposalStatusWidget(status: provider.status);
          },
        ),
        const SizedBox(width: 12),
        Text(typeText, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
      ],
    );

    final authorWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Posted By: "),
        Text(shortenString(proposal.author), style: const TextStyle(fontFamily: 'monospace')),
        IconButton(
          splashRadius: 20,
          icon: const Icon(Icons.copy, size: 16),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: proposal.author));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Author address copied to clipboard'), duration: Duration(seconds: 1)));
          },
        ),
      ],
    );

    final descriptionWidget = Text(
      proposal.description,
      style: TextStyle(color: Colors.grey[300], fontFamily: 'monospace'),
      textAlign: TextAlign.center,
    );

    final discussionWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         const Text("Discussion: ", style: TextStyle(fontFamily: 'monospace')),
         discussionLink,
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      color: const Color(0xff2c2c2c),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return Column(
              children: [
                titleWidget,
                const SizedBox(height: 12),
                statusWidget,
                const SizedBox(height: 12),
                authorWidget,
                const SizedBox(height: 24),
                descriptionWidget,
                const SizedBox(height: 12),
                discussionWidget,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    titleWidget,
                    const SizedBox(height: 12),
                    statusWidget,
                    const SizedBox(height: 12),
                    authorWidget,
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    descriptionWidget,
                    const SizedBox(height: 12),
                    discussionWidget,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
// lib/src/features/proposal_detail/proposal_detail_screen.dart