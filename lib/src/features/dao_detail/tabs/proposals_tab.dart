// lib/src/features/dao_detail/tabs/proposals_tab.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_detail/widgets/proposal_list_item.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/utils/proposal_status_helper.dart';

class ProposalsTab extends StatefulWidget {
  final Org org; 
  final String networkName;

  const ProposalsTab({
    super.key,
    required this.org,
    required this.networkName,
  });

  @override
  State<ProposalsTab> createState() => _ProposalsTabState();
}

class _ProposalsTabState extends State<ProposalsTab> {
  String _selectedType = 'All';
  String _selectedStatus = 'All';

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
    return Column(
      children: [
        _buildControls(),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            return Column(
              children: [
                if (!isMobile) _buildHeader(),
                if (!isMobile) const SizedBox(height: 8),
                StreamBuilder<List<Proposal>>(
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
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                       return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 148.0),
                            child: Text('No proposals created yet...', style: TextStyle(fontSize: 23, color: Colors.white24),),
                          ),
                        );
                    }
                    
                    final allProposals = snapshot.data!;
                    final filteredProposals = allProposals.where((p) {
                      final currentStatus = ProposalStatusHelper.calculateDisplayStatus(p, widget.org);
                      final typeMatch = _selectedType == 'All' ||
                          (p.type != null && p.type!.toLowerCase().contains(_selectedType.toLowerCase()));
                      final statusMatch = _selectedStatus == 'All' ||
                          _statusToString(currentStatus) == _selectedStatus;
                      return typeMatch && statusMatch;
                    }).toList();

                    return SizedBox(
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
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final typeDropdown = _buildDropdown(
            _selectedType, _typeOptions, (val) => setState(() => _selectedType = val!));
        final statusDropdown = _buildDropdown(_selectedStatus, _statusOptions,
            (val) => setState(() => _selectedStatus = val!));

        final createButton = ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Center(child: Text('Proposal creation coming soon!')),
                  duration: Duration(seconds: 2)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffa1d0d0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Create Proposal',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        );

        if (isMobile) {
          return Column(
            children: [
              Row(
                children: [
                  const Text("Type: "), Expanded(child: typeDropdown),
                  const SizedBox(width: 16),
                  const Text("Status: "), Expanded(child: statusDropdown),
                ],
              ),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerRight, child: createButton),
            ],
          );
        }

        return Row(
          children: [
            const Text("Type: "), const SizedBox(width: 8), typeDropdown,
            const SizedBox(width: 24),
            const Text("Status: "), const SizedBox(width: 8), statusDropdown,
            const Spacer(),
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
      underline: const SizedBox.shrink(),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
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
// lib/src/features/dao_detail/tabs/proposals_tab.dart