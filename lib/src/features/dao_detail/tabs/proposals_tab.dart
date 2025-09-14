// lib/src/features/dao_detail/tabs/proposals_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_status_widget.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/utils/reusable.dart';

class ProposalsTab extends StatefulWidget {
  final List<Proposal> proposals;
  final String networkName;
  final String daoAddress;

  const ProposalsTab({
    super.key,
    required this.proposals,
    required this.networkName,
    required this.daoAddress,
  });

  @override
  State<ProposalsTab> createState() => _ProposalsTabState();
}

class _ProposalsTabState extends State<ProposalsTab> {
  String _selectedType = 'All';
  String _selectedStatus = 'All';

  final List<String> _typeOptions = const [
    'All', 'Registry', 'Transfer', 'Contract Call', 'Mint', 'Burn', 'Quorum', 'Voting Delay', 'Voting Period', 'Threshold'
  ];
  final List<String> _statusOptions = const [
    'All', "Active", "Succeeded", "Queued", "Executable", "Executed", "Expired", "No Quorum", "Pending", "Rejected", "Defeated"
  ];

  ProposalStatus _getProposalStatus(Proposal proposal) {
    if (proposal.statusHistory.isEmpty) {
      return ProposalStatus.Pending;
    }
    var latestEntry = proposal.statusHistory.entries
        .reduce((a, b) => a.value.isAfter(b.value) ? a : b);
    
    switch (latestEntry.key.toLowerCase()) {
      case 'active': return ProposalStatus.Active;
      case 'succeeded': return ProposalStatus.Succeeded;
      case 'passed': return ProposalStatus.Succeeded;
      case 'queued': return ProposalStatus.Queued;
      case 'executable': return ProposalStatus.Executable;
      case 'executed': return ProposalStatus.Executed;
      case 'expired': return ProposalStatus.Expired;
      case 'no quorum': return ProposalStatus.NoQuorum;
      case 'pending': return ProposalStatus.Pending;
      case 'rejected': return ProposalStatus.Rejected;
      case 'defeated': return ProposalStatus.Defeated;
      default: return ProposalStatus.Unknown;
    }
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
    final filteredProposals = widget.proposals.where((p) {
      final typeMatch = _selectedType == 'All' ||
          (p.type != null && p.type!.toLowerCase().contains(_selectedType.toLowerCase()));
      final statusMatch = _selectedStatus == 'All' ||
          _statusToString(_getProposalStatus(p)) == _selectedStatus;
      return typeMatch && statusMatch;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Column(
          children: [
            _buildControls(),
            const SizedBox(height: 20),
            if (!isMobile) _buildHeader(),
            if (!isMobile) const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredProposals.isEmpty ? 1 : filteredProposals.length,
                itemBuilder: (context, index) {
                   if (filteredProposals.isEmpty) {
                     return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 148.0),
                          child: Text('No proposals created yet...', style: TextStyle(fontSize: 23, color: Colors.white24),),
                        ),
                      );
                   }
                   final proposal = filteredProposals[index];
                   if (isMobile) {
                      return MobileProposalListItem(
                        proposal: proposal,
                        status: _getProposalStatus(proposal),
                        networkName: widget.networkName,
                        daoAddress: widget.daoAddress,
                      );
                   } else {
                      return DesktopProposalListItem(
                        proposal: proposal,
                        status: _getProposalStatus(proposal),
                        networkName: widget.networkName,
                        daoAddress: widget.daoAddress,
                      );
                   }
                },
              ),
            ),
          ],
        );
      },
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

class DesktopProposalListItem extends StatelessWidget {
  final Proposal proposal;
  final ProposalStatus status;
  final String networkName;
  final String daoAddress;

  const DesktopProposalListItem({
    super.key,
    required this.proposal,
    required this.status,
    required this.networkName,
    required this.daoAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(169, 54, 54, 54),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 8,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: InkWell(
        onTap: () {
          context.go('/$networkName/$daoAddress/proposals/${proposal.id}');
        },
        borderRadius: BorderRadius.zero,
        child: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 20),
                  splashRadius: 20,
                  tooltip: 'Copy Proposal ID',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: proposal.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Center(child: Text('Proposal ID copied to clipboard')),
                          duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  proposal.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  shortenString(proposal.author),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              SizedBox(
                width: 140,
                child: Text(
                  DateFormat('M/d/yyyy HH:mm').format(proposal.createdAt),
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 100,
                child: Text(
                  proposal.type ?? 'N/A',
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(
                width: 110,
                child: Center(child: ProposalStatusWidget(status: status)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileProposalListItem extends StatelessWidget {
  final Proposal proposal;
  final ProposalStatus status;
  final String networkName;
  final String daoAddress;

  const MobileProposalListItem({
    super.key,
    required this.proposal,
    required this.status,
    required this.networkName,
    required this.daoAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff3a3a3a),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: InkWell(
        onTap: () {
          context.go('/$networkName/$daoAddress/proposals/${proposal.id}');
        },
        borderRadius: BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      proposal.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ProposalStatusWidget(status: status),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMobileDetailColumn("ID", shortenString(proposal.id), context),
                  _buildMobileDetailColumn("Type", proposal.type ?? 'N/A', context),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildMobileDetailColumn("Author", shortenString(proposal.author), context, isMono: true),
                   _buildMobileDetailColumn("Posted", DateFormat('M/d/yy HH:mm').format(proposal.createdAt), context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDetailColumn(String label, String value, BuildContext context, {bool isMono = false}) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            style: isMono ? const TextStyle(fontFamily: 'monospace') : const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
// lib/src/features/dao_detail/tabs/proposals_tab.dart
