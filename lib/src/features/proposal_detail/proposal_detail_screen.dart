// lib/src/features/proposal_detail/proposal_detail_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_detail/widgets/footer.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_actions_card.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_execution_details_card.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_lifecycle_card.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_status_widget.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_votes_card.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/providers/proposal_detail_provider.dart';
import 'package:werule/src/providers/treasury_provider.dart';
import 'package:werule/src/services/avatar_service.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/services/treasury_service.dart';
import 'package:werule/src/utils/reusable.dart';
import 'package:werule/src/widgets/shared_app_bar.dart';

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
  bool _isLoading = true;
  String? _error;
  ProposalDetailProvider? _proposalDetailProvider;
  TreasuryProvider? _treasuryProvider;
  StreamSubscription? _proposalSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final networkProvider = context.read<NetworkProvider>();
      final firestoreService = context.read<FirestoreService>();
      final blockchainService = context.read<BlockchainService>();
      final authProvider = context.read<AuthProvider>();
      final treasuryService = context.read<TreasuryService>();
      
      networkProvider.selectNetworkByName(widget.networkName);
      
      final collection = 'idaos${widget.networkName}';

      final org = await firestoreService.getDao(collection, widget.daoAddress);
      final initialProposal = await firestoreService.getProposal(collection, widget.daoAddress, widget.proposalId);
      final network = networkProvider.networks.firstWhereOrNull((n) => n.name == widget.networkName);
      
      if (org == null || initialProposal == null || network == null) {
        throw Exception("Could not find DAO, proposal, or network information.");
      }
      
      _proposalDetailProvider = ProposalDetailProvider(
        blockchainService: blockchainService,
        firestoreService: firestoreService,
        authProvider: authProvider,
        proposal: initialProposal,
        org: org,
        network: network,
      );

      _treasuryProvider = TreasuryProvider(
        treasuryService,
        org,
        network,
      );

      _proposalSubscription = firestoreService
          .getProposalStream(collection, widget.daoAddress, widget.proposalId)
          .listen((proposalUpdate) {
        if (proposalUpdate != null && mounted) {
          _proposalDetailProvider?.update(proposalUpdate, org);
        }
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _proposalSubscription?.cancel();
    _proposalDetailProvider?.dispose();
    _treasuryProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff222222),
      appBar: const SharedAppBar(),
      endDrawer: const MobileDrawer(isNetworkSelectorEnabled: false),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _proposalDetailProvider == null || _treasuryProvider == null) {
      return Center(child: Text("Error loading proposal: ${_error ?? 'Provider not initialized.'}"));
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _proposalDetailProvider!),
        ChangeNotifierProvider.value(value: _treasuryProvider!),
      ],
      child: const _ProposalDetailView(),
    );
  }
}


class _ProposalDetailView extends StatefulWidget {
  const _ProposalDetailView();

  @override
  State<_ProposalDetailView> createState() => _ProposalDetailViewState();
}

class _ProposalDetailViewState extends State<_ProposalDetailView> {
  bool _showHeader = false;
  bool _showActionsCard = false;
  bool _showExecutionDetailsCard = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showHeader = true);
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _showActionsCard = true);
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showExecutionDetailsCard = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProposalDetailProvider>();
    final proposal = provider.proposal;
    final org = provider.org;
    final network = provider.network;
    final status = provider.status;
    
    final isDefinitiveState = status == ProposalStatus.Executed ||
        status == ProposalStatus.Defeated ||
        status == ProposalStatus.NoQuorum ||
        status == ProposalStatus.Expired ||
        status == ProposalStatus.Canceled;

    const double kCardSpacing = 16.0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(kCardSpacing),
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
                    const SizedBox(height: kCardSpacing),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // --- MOBILE LAYOUT ---
                        if (constraints.maxWidth < 900) {
                          return Column(
                            children: [
                              _AnimatedFadeIn(isVisible: _showHeader, child: _ProposalHeader(proposal: proposal, isVertical: false)),
                              const SizedBox(height: kCardSpacing + 4),
                              if (!isDefinitiveState) ...[
                                _AnimatedFadeIn(isVisible: _showActionsCard, child: const ProposalActionsCard()),
                                const SizedBox(height: kCardSpacing),
                              ],
                              ProposalVotesCard(org: org),
                              const SizedBox(height: kCardSpacing),
                              _AnimatedFadeIn(isVisible: _showExecutionDetailsCard, child: ProposalExecutionDetailsCard(proposal: proposal, org: org, network: network)),
                              const SizedBox(height: kCardSpacing),
                              const ProposalLifecycleCard(),
                            ],
                          );
                        } 
                        // --- DESKTOP/WIDE LAYOUT ---
                        else {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 10,
                                child: Column(
                                  children: [
                                    _AnimatedFadeIn(
                                      isVisible: _showHeader,
                                      child: _ProposalHeader(proposal: proposal, isVertical: true),
                                    ),
                                    const SizedBox(height: kCardSpacing),
                                    _AnimatedFadeIn(
                                      isVisible: _showExecutionDetailsCard,
                                      child: ProposalExecutionDetailsCard(proposal: proposal, org: org, network: network),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: kCardSpacing),
                              Expanded(
                                flex: 9,
                                child: Column(
                                  children: [
                                    if (!isDefinitiveState) ...[
                                      _AnimatedFadeIn(
                                        isVisible: _showActionsCard,
                                        child: const ProposalActionsCard(),
                                      ),
                                      const SizedBox(height: kCardSpacing),
                                    ],
                                    ProposalVotesCard(org: org),
                                    const SizedBox(height: kCardSpacing),
                                    const ProposalLifecycleCard(),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverLayoutBuilder(
          builder: (BuildContext context, SliverConstraints constraints) {
            final contentHeight = constraints.precedingScrollExtent;
            final viewportHeight = constraints.viewportMainAxisExtent;
            const fixedFooterSpacing = 100.0;

            final double topPadding;
            if (contentHeight < viewportHeight) {
              topPadding = viewportHeight - contentHeight + fixedFooterSpacing;
            } else {
              topPadding = fixedFooterSpacing;
            }

            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: Footer(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ProposalHeader extends StatefulWidget {
  final Proposal proposal;
  final bool isVertical;
  const _ProposalHeader({required this.proposal, required this.isVertical});

  @override
  State<_ProposalHeader> createState() => _ProposalHeaderState();
}

class _ProposalHeaderState extends State<_ProposalHeader> {
  late Future<Uint8List> _avatarFuture;

  @override
  void initState() {
    super.initState();
    _avatarFuture = AvatarService.getAvatar(widget.proposal.author);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final typeText = widget.proposal.type != null ? widget.proposal.type! : "<unknown type>";
    final discussionLink = (widget.proposal.externalResource != null && widget.proposal.externalResource!.isNotEmpty)
      ? OldSchoolLink(text: widget.proposal.externalResource!, url: widget.proposal.externalResource!)
      : const Text("No link provided", style: TextStyle(color: Colors.grey));

    final titleWidget = Text(
      widget.proposal.title,
      textAlign: widget.isVertical ? TextAlign.left : TextAlign.center,
      style: textTheme.headlineMedium,
    );

    // THE FIX: The status and author are now combined into a single responsive row.
    final metadataRow = Row(
      children: [
        // Left side group
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<ProposalDetailProvider>(
                builder: (context, provider, child) {
                  return ProposalStatusWidget(status: provider.status);
                },
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "$typeText proposal",
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16), // Gutter space
        // Right side group
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("By: ", style: TextStyle(fontSize: 14)),
              FutureBuilder<Uint8List>(
                future: _avatarFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: ClipOval(child: Image.memory(snapshot.data!, width: 22, height: 22)),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircleAvatar(backgroundColor: Color(0xff3a3a3a)),
                    ),
                  );
                },
              ),
              Flexible(
                child: Text(
                  shortenString(widget.proposal.author),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
              IconButton(
                padding: const EdgeInsets.only(left: 8),
                constraints: const BoxConstraints(),
                splashRadius: 20,
                icon: const Icon(Icons.copy, size: 15),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.proposal.author));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Author address copied to clipboard'), duration: Duration(seconds: 1)));
                },
              ),
            ],
          ),
        ),
      ],
    );

    final descriptionWidget = Text(
      widget.proposal.description,
      style: TextStyle(color: Colors.grey[300], fontFamily: 'monospace'),
      textAlign: TextAlign.center,
    );

    final discussionWidget = Row(
      mainAxisAlignment: widget.isVertical ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
         const Text("Discussion: ", style: TextStyle(fontFamily: 'monospace')),
         discussionLink,
      ],
    );
    
    // --- Vertical Layout for Desktop ---
    if (widget.isVertical) {
      return Container(
        width: double.infinity,
        color: const Color(0xff2c2c2c),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 12),
              child: titleWidget,
            ),
            // THE FIX: The new metadataRow is placed here.
            Container(
              color: const Color(0xff3a3a3a),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: metadataRow,
            ),
            // THE FIX: The old, separate authorWidget has been removed.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 32.0),
              child: Center(
                child: descriptionWidget,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: discussionWidget,
            ),
          ],
        ),
      );
    }

    // --- Horizontal Layout for Mobile ---
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      color: const Color(0xff2c2c2c),
      child: Column(
        children: [
          titleWidget,
          const SizedBox(height: 12),
          // THE FIX: The new metadataRow is also used for the mobile layout.
          metadataRow,
          // THE FIX: The old, separate authorWidget has been removed.
          const SizedBox(height: 24),
          descriptionWidget,
          const SizedBox(height: 12),
          discussionWidget,
        ],
      ),
    );
  }
}


class _AnimatedFadeIn extends StatelessWidget {
  final bool isVisible;
  final Widget child;
  final Duration duration;

  const _AnimatedFadeIn({
    required this.isVisible,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: duration,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOut,
        transform: isVisible
            ? Matrix4.translationValues(0, 0, 0)
            : Matrix4.translationValues(0, 20, 0),
        child: child,
      ),
    );
  }
}
// lib/src/features/proposal_detail/proposal_detail_screen.dart