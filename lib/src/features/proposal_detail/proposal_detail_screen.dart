// lib/src/features/proposal_detail/proposal_detail_screen.dart
import 'dart:async';
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
  ProposalDetailProvider? _provider;
  StreamSubscription? _proposalSubscription;
  Future<dynamic>? _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    final networkProvider = context.read<NetworkProvider>();
    networkProvider.selectNetworkByName(widget.networkName);
    
    final firestoreService = context.read<FirestoreService>();
    final collection = 'idaos${widget.networkName}';

    final org = await firestoreService.getDao(collection, widget.daoAddress);
    final initialProposal = await firestoreService.getProposal(collection, widget.daoAddress, widget.proposalId);
    final network = networkProvider.networks.firstWhereOrNull((n) => n.name == widget.networkName);
    
    if (org == null || initialProposal == null || network == null) {
      throw Exception("Could not initialize proposal details.");
    }
    
    _provider = ProposalDetailProvider(
      blockchainService: context.read<BlockchainService>(),
      proposal: initialProposal,
      org: org,
      network: network,
    );

    _proposalSubscription = firestoreService
        .getProposalStream(collection, widget.daoAddress, widget.proposalId)
        .listen((proposalUpdate) {
      if (proposalUpdate != null && _provider != null) {
        _provider!.update(proposalUpdate, org);
      }
    });
  }

  @override
  void dispose() {
    _proposalSubscription?.cancel();
    _provider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff222222),
      appBar: const SharedAppBar(),
      endDrawer: const MobileDrawer(isNetworkSelectorEnabled: false),
      body: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || _provider == null) {
            return Center(child: Text("Error loading proposal: ${snapshot.error ?? 'Provider not initialized.'}"));
          }
          
          return ChangeNotifierProvider.value(
            value: _provider!,
            child: const _ProposalDetailView(),
          );
        },
      ),
    );
  }
}

class _ProposalDetailView extends StatelessWidget {
  const _ProposalDetailView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProposalDetailProvider>();
    final proposal = provider.proposal;
    final org = provider.org;
    final network = provider.network;
    
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
                  onPressed: () => context.go('/${network.name}/${org.address}'),
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
                        const ProposalLifecycleCard(),
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
                            const Expanded(child: ProposalLifecycleCard()),
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