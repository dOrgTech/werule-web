// lib/src/features/dao_detail/tabs/proposals_tab.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_status_widget.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/utils/proposal_status_helper.dart';
import 'package:werule/src/utils/reusable.dart';

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

// --- Stateful Desktop List Item ---
class DesktopProposalListItem extends StatefulWidget {
  final Proposal proposal;
  final Org org;
  final String networkName;

  const DesktopProposalListItem({
    super.key,
    required this.proposal,
    required this.org,
    required this.networkName,
  });

  @override
  State<DesktopProposalListItem> createState() => _DesktopProposalListItemState();
}

class _DesktopProposalListItemState extends State<DesktopProposalListItem> {
  late ProposalStatus _displayStatus;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateStatusAndScheduleNext();
  }

  // THE FIX: Implement didUpdateWidget to react to data changes from the parent.
  @override
  void didUpdateWidget(covariant DesktopProposalListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the proposal data from Firestore has changed, re-run our logic.
    // A simple check on the status history is a reliable indicator of change.
    if (widget.proposal.statusHistory != oldWidget.proposal.statusHistory) {
      _updateStatusAndScheduleNext();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateStatusAndScheduleNext() {
    // Always cancel any existing timer before setting a new one.
    _timer?.cancel();

    setState(() {
      _displayStatus = ProposalStatusHelper.calculateDisplayStatus(widget.proposal, widget.org);
    });
    
    _scheduleNextUpdate();
  }

  void _scheduleNextUpdate() {
    final now = DateTime.now();
    DateTime? nextTransitionTime;

    final voteStart = widget.proposal.createdAt.add(Duration(minutes: widget.org.votingDelay));
    final voteEnd = voteStart.add(Duration(minutes: widget.org.votingDuration));

    if (_displayStatus == ProposalStatus.Pending && voteStart.isAfter(now)) {
      nextTransitionTime = voteStart;
    } else if (_displayStatus == ProposalStatus.Active && voteEnd.isAfter(now)) {
      nextTransitionTime = voteEnd;
    } else if (_displayStatus == ProposalStatus.Queued) {
      final queuedTime = widget.proposal.statusHistory['queued'] ?? voteEnd;
      final executionETA = queuedTime.add(Duration(seconds: widget.org.executionDelay));
      if (executionETA.isAfter(now)) {
        nextTransitionTime = executionETA;
      }
    }

    if (nextTransitionTime != null) {
      final duration = nextTransitionTime.difference(now);
      _timer = Timer(duration, () {
        if (mounted) {
          // When the timer fires, re-run the whole logic.
          _updateStatusAndScheduleNext();
        }
      });
    }
  }
  
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
          context.go('/${widget.networkName}/${widget.org.address}/proposals/${widget.proposal.id}');
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
                    Clipboard.setData(ClipboardData(text: widget.proposal.id));
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
                  widget.proposal.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  shortenString(widget.proposal.author),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              SizedBox(
                width: 140,
                child: Text(
                  DateFormat('M/d/yyyy HH:mm').format(widget.proposal.createdAt),
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 100,
                child: Text(
                  widget.proposal.type ?? 'N/A',
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(
                width: 110,
                child: Center(child: ProposalStatusWidget(status: _displayStatus)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Stateful Mobile List Item ---
class MobileProposalListItem extends StatefulWidget {
  final Proposal proposal;
  final Org org;
  final String networkName;

  const MobileProposalListItem({
    super.key,
    required this.proposal,
    required this.org,
    required this.networkName,
  });

  @override
  State<MobileProposalListItem> createState() => _MobileProposalListItemState();
}

class _MobileProposalListItemState extends State<MobileProposalListItem> {
  late ProposalStatus _displayStatus;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateStatusAndScheduleNext();
  }

  // THE FIX: Implement didUpdateWidget to react to data changes from the parent.
  @override
  void didUpdateWidget(covariant MobileProposalListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.proposal.statusHistory != oldWidget.proposal.statusHistory) {
      _updateStatusAndScheduleNext();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateStatusAndScheduleNext() {
    _timer?.cancel();
    setState(() {
      _displayStatus = ProposalStatusHelper.calculateDisplayStatus(widget.proposal, widget.org);
    });
    _scheduleNextUpdate();
  }

  void _scheduleNextUpdate() {
    final now = DateTime.now();
    DateTime? nextTransitionTime;

    final voteStart = widget.proposal.createdAt.add(Duration(minutes: widget.org.votingDelay));
    final voteEnd = voteStart.add(Duration(minutes: widget.org.votingDuration));

    if (_displayStatus == ProposalStatus.Pending && voteStart.isAfter(now)) {
      nextTransitionTime = voteStart;
    } else if (_displayStatus == ProposalStatus.Active && voteEnd.isAfter(now)) {
      nextTransitionTime = voteEnd;
    } else if (_displayStatus == ProposalStatus.Queued) {
      final queuedTime = widget.proposal.statusHistory['queued'] ?? voteEnd;
      final executionETA = queuedTime.add(Duration(seconds: widget.org.executionDelay));
      if (executionETA.isAfter(now)) {
        nextTransitionTime = executionETA;
      }
    }

    if (nextTransitionTime != null) {
      final duration = nextTransitionTime.difference(now);
      _timer = Timer(duration, () {
        if (mounted) {
          _updateStatusAndScheduleNext();
        }
      });
    }
  }

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
          context.go('/${widget.networkName}/${widget.org.address}/proposals/${widget.proposal.id}');
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
                      widget.proposal.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ProposalStatusWidget(status: _displayStatus),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMobileDetailColumn("ID", shortenString(widget.proposal.id), context),
                  _buildMobileDetailColumn("Type", widget.proposal.type ?? 'N/A', context),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildMobileDetailColumn("Author", shortenString(widget.proposal.author), context, isMono: true),
                   _buildMobileDetailColumn("Posted", DateFormat('M/d/yy HH:mm').format(widget.proposal.createdAt), context),
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