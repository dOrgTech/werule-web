// lib/src/features/dao_detail/tabs/proposals_tab.dart
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/create_proposal/create_proposal_dialog.dart';
import 'package:werule/src/features/dao_detail/widgets/proposal_list_item.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/create_proposal_provider.dart';
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

  @override
  State<ProposalsTab> createState() => _ProposalsTabState();
}

class _ProposalsTabState extends State<ProposalsTab> {
  String _selectedType = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            SizedBox(width: 110, child: Text("Status", textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}