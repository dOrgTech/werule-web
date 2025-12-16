// lib/src/features/dao_detail/tabs/proposals_tab.dart
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/create_debate/create_debate_dialog.dart';
import 'package:werule/src/features/create_proposal/create_proposal_dialog.dart';
import 'package:werule/src/features/dao_detail/widgets/debate_list_item.dart';
import 'package:werule/src/features/dao_detail/widgets/proposal_list_item.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/create_proposal_provider.dart';
import 'package:werule/src/providers/debates_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/providers/treasury_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/calldata_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/services/treasury_service.dart';
import 'package:werule/src/utils/proposal_status_helper.dart';

class ProposalsTab extends StatefulWidget {
  final Org org;
  final String networkName;

  const ProposalsTab({
    super.key,
    required this.org,
    required this.networkName,
  });

  // THE FIX: Converted the dialog logic into a public static method.
  static void showCreateProposalDialog(BuildContext context, Org org, String networkName) {
    final auth = context.read<AuthProvider>();
    if (!auth.isConnected || auth.selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(child: Text("Please connect your wallet to create a proposal.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    final network = context.read<NetworkProvider>().networks.firstWhereOrNull((n) => n.name == networkName);
    if (network == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(child: Text("Cannot create proposal: Network details not found.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Use MultiProvider to make both providers available to the dialog.
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => CreateProposalProvider(
                org: org,
                signerAddress: auth.selectedAccount!,
                calldata: context.read<CalldataService>(),
                blockchain: context.read<BlockchainService>(),
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => TreasuryProvider(
                context.read<TreasuryService>(),
                org,
                network,
              ),
            ),
          ],
          child: CreateProposalDialog(org: org),
        );
      },
    );
  }

  /// Shows the create debate dialog
  static Future<void> showCreateDebateDialog(BuildContext context, Org org, String networkName, {DebatesProvider? existingProvider}) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isConnected || auth.selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(child: Text("Please connect your wallet to create a debate.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    final network = context.read<NetworkProvider>().networks.firstWhereOrNull((n) => n.name == networkName);
    if (network == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(child: Text("Cannot create debate: Network details not found.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    // Get debates factory address from Firestore
    final firestoreService = context.read<FirestoreService>();
    final debatesFactory = await firestoreService.getDebatesFactoryAddress(networkName);
    if (debatesFactory == null || debatesFactory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(child: Text("Debates are not yet available on this network.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    if (!context.mounted) return;

    // If using existing provider, fetch voting power before showing dialog
    if (existingProvider != null) {
      await existingProvider.fetchUserVotingPower();
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        // If an existing provider was passed, use it to avoid creating a new one
        if (existingProvider != null) {
          return ChangeNotifierProvider.value(
            value: existingProvider,
            child: CreateDebateDialog(org: org),
          );
        }
        // Create new provider and fetch voting power
        final provider = DebatesProvider(
          blockchainService: context.read<BlockchainService>(),
          authProvider: auth,
          org: org,
          network: network,
          debatesFactoryAddress: debatesFactory,
        );
        provider.fetchUserVotingPower();
        return ChangeNotifierProvider.value(
          value: provider,
          child: CreateDebateDialog(org: org),
        );
      },
    );

    // If debate was created successfully and we have an existing provider, refresh it
    if (result == true && existingProvider != null) {
      await existingProvider.fetchDebates();
    }
  }

  @override
  State<ProposalsTab> createState() => _ProposalsTabState();
}

class _ProposalsTabState extends State<ProposalsTab> {
  String _selectedType = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Toggle between proposals and debates
  bool _showDebates = false;
  DebatesProvider? _debatesProvider;
  String? _debatesFactoryAddress;
  bool _isLoadingDebatesFactory = true;

  late Stream<List<Proposal>> _proposalsStream;

  final List<String> _typeOptions = const [
    'All', 'Registry', 'Transfer', 'Contract Call', 'Mint', 'Burn', 'Quorum', 'Voting Delay', 'Voting Period', 'Threshold'
  ];
  final List<String> _statusOptions = const [
    'All', "Active", "Succeeded", "Queued", "Executable", "Executed", "Expired", "No Quorum", "Pending", "Rejected", "Defeated"
  ];

  @override
  void initState() {
    super.initState();
    final firestoreService = context.read<FirestoreService>();
    final collectionName = 'idaos${widget.networkName}';
    _proposalsStream = firestoreService.getProposalsStream(collectionName, widget.org.address);
    _initDebatesProvider();
  }

  Future<void> _initDebatesProvider() async {
    final firestoreService = context.read<FirestoreService>();
    _debatesFactoryAddress = await firestoreService.getDebatesFactoryAddress(widget.networkName);

    if (_debatesFactoryAddress != null && _debatesFactoryAddress!.isNotEmpty && mounted) {
      final network = context.read<NetworkProvider>().networks.firstWhereOrNull((n) => n.name == widget.networkName);
      if (network != null) {
        _debatesProvider = DebatesProvider(
          blockchainService: context.read<BlockchainService>(),
          authProvider: context.read<AuthProvider>(),
          org: widget.org,
          network: network,
          debatesFactoryAddress: _debatesFactoryAddress,
        );
      }
    }

    if (mounted) {
      setState(() => _isLoadingDebatesFactory = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debatesProvider?.dispose();
    super.dispose();
  }

  bool get _hasDebatesSupport => !_isLoadingDebatesFactory && _debatesFactoryAddress != null && _debatesFactoryAddress!.isNotEmpty;

  String _statusToString(ProposalStatus status) {
    switch (status) {
      case ProposalStatus.NoQuorum: return "No Quorum";
      default:
        final String name = status.toString().split('.').last;
        return name[0].toUpperCase() + name.substring(1);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Show debates view if toggle is set
    if (_showDebates && _debatesProvider != null) {
      return ListenableBuilder(
        listenable: _debatesProvider!,
        builder: (context, _) => _buildDebatesView(),
      );
    }

    return StreamBuilder<List<Proposal>>(
      stream: _proposalsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.only(top: 148.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allProposals = snapshot.data ?? [];
        final filteredProposals = allProposals.where((p) {
          final titleMatch = _searchQuery.isEmpty ||
                             (p.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          final currentStatus = ProposalStatusHelper.calculateDisplayStatus(p, widget.org);
          final typeMatch = _selectedType == 'All' ||
              (p.type != null && p.type!.toLowerCase().contains(_selectedType.toLowerCase()));
          final statusMatch = _selectedStatus == 'All' ||
              _statusToString(currentStatus) == _selectedStatus;
          return titleMatch && typeMatch && statusMatch;
        }).toList();

        return Column(
          children: [
            _buildControls(allProposals.length),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                return Column(
                  children: [
                    if (!isMobile) _buildHeader(),
                    if (!isMobile) const SizedBox(height: 8),
                    if (allProposals.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 148.0),
                          child: Text('No proposals created yet...', style: TextStyle(fontSize: 23, color: Colors.white24)),
                        ),
                      )
                    else
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 250,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredProposals.length,
                          itemBuilder: (context, index) {
                             final proposal = filteredProposals[index];
                             if (isMobile) {
                                return MobileProposalListItem(
                                  key: ValueKey(proposal.id),
                                  proposal: proposal,
                                  org: widget.org,
                                  networkName: widget.networkName,
                                );
                             } else {
                                return DesktopProposalListItem(
                                  key: ValueKey(proposal.id),
                                  proposal: proposal,
                                  org: widget.org,
                                  networkName: widget.networkName,
                                );
                             }
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDebatesView() {
    final debates = _debatesProvider!.debates;
    final isLoading = _debatesProvider!.isLoading;

    return Column(
      children: [
        _buildDebatesControls(debates.length),
        const SizedBox(height: 20),
        if (isLoading)
          const Center(child: Padding(
            padding: EdgeInsets.only(top: 148.0),
            child: CircularProgressIndicator(),
          ))
        else if (debates.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 148.0),
              child: Text('No debates created yet...', style: TextStyle(fontSize: 23, color: Colors.white24)),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              return Column(
                children: [
                  if (!isMobile) _buildDebatesHeader(),
                  if (!isMobile) const SizedBox(height: 8),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 250,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: debates.length,
                      itemBuilder: (context, index) {
                        final debate = debates[index];
                        return DebateListItemWidget(
                          key: ValueKey(debate.debateAddress),
                          debate: debate,
                          org: widget.org,
                          networkName: widget.networkName,
                          debatesProvider: _debatesProvider!,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildViewToggle() {
    if (!_hasDebatesSupport) return const SizedBox.shrink();

    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: false, label: Text('Proposals'), icon: Icon(Icons.article_outlined)),
        ButtonSegment(value: true, label: Text('Debates'), icon: Icon(Icons.forum_outlined)),
      ],
      selected: {_showDebates},
      onSelectionChanged: (selected) {
        setState(() => _showDebates = selected.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xffa1d0d0).withValues(alpha: 0.2);
          }
          return Colors.transparent;
        }),
      ),
    );
  }

  Widget _buildControls(int totalProposals) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final searchBar = SizedBox(
          width: isMobile ? double.infinity : 400,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by proposal title...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(width: 0.5),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        );

        final typeDropdown = _buildDropdown(
            _selectedType, _typeOptions, (val) => setState(() => _selectedType = val!));
        final statusDropdown = _buildDropdown(_selectedStatus, _statusOptions,
            (val) => setState(() => _selectedStatus = val!));

        final createButton = ElevatedButton(
          onPressed: () => ProposalsTab.showCreateProposalDialog(context, widget.org, widget.networkName),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffa1d0d0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Create Proposal',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        );

        final proposalCountLabel = Text('$totalProposals items');

        if (isMobile) {
          return Column(
            children: [
              if (_hasDebatesSupport) ...[
                _buildViewToggle(),
                const SizedBox(height: 16),
              ],
              searchBar,
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Type: "), Expanded(child: typeDropdown),
                  const SizedBox(width: 16),
                  const Text("Status: "), Expanded(child: statusDropdown),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  proposalCountLabel,
                  const SizedBox(width: 16),
                  createButton,
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            if (_hasDebatesSupport) ...[
              _buildViewToggle(),
              const SizedBox(width: 24),
            ],
            searchBar,
            const Spacer(),
            const Text("Type: ", style: TextStyle(fontSize: 12),), const SizedBox(width: 8), typeDropdown,
            const SizedBox(width: 24),
            const Text("Status: ",style: TextStyle(fontSize: 12)), const SizedBox(width: 8), statusDropdown,
            const SizedBox(width: 24),
            proposalCountLabel,
            const SizedBox(width: 16),
            createButton,
          ],
        );
      }),
    );
  }

  Widget _buildDebatesControls(int totalDebates) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final createDebateButton = ElevatedButton(
          onPressed: () => ProposalsTab.showCreateDebateDialog(
            context,
            widget.org,
            widget.networkName,
            existingProvider: _debatesProvider,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffa1d0d0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Create Debate',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        );

        final refreshButton = IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _debatesProvider?.fetchDebates(),
          tooltip: 'Refresh debates',
        );

        final debateCountLabel = Text('$totalDebates debates');

        if (isMobile) {
          return Column(
            children: [
              _buildViewToggle(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  refreshButton,
                  const SizedBox(width: 8),
                  debateCountLabel,
                  const SizedBox(width: 16),
                  createDebateButton,
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            _buildViewToggle(),
            const Spacer(),
            refreshButton,
            const SizedBox(width: 8),
            debateCountLabel,
            const SizedBox(width: 16),
            createDebateButton,
          ],
        );
      }),
    );
  }

  Widget _buildDebatesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
        child: const Row(
          children: [
            Expanded(flex: 3, child: Text("Title")),
            Expanded(flex: 2, child: Text("Creator")),
            SizedBox(width: 140, child: Text("Created")),
            SizedBox(width: 100, child: Text("Arguments")),
            SizedBox(width: 120, child: Text("Sentiment", textAlign: TextAlign.center)),
            SizedBox(width: 80, child: Text("Status", textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      focusColor: Colors.transparent,
    
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(fontSize: 12)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
        child: const Row(
          children: [
            SizedBox(width: 60, child: Text("ID #")),
            Expanded(flex: 3, child: Text("Title")),
            Expanded(flex: 2, child: Text("Author")),
            SizedBox(width: 140, child: Text("Posted")),
            Spacer(),
            SizedBox(width: 100, child: Text("Type")),
            SizedBox(width: 40),
            SizedBox(width: 110, child: Text("Status", textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}