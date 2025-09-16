// lib/src/features/dao_detail/widgets/proposal_list_item.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_status_widget.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/utils/proposal_status_helper.dart';
import 'package:werule/src/utils/reusable.dart';

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

  @override
  void didUpdateWidget(covariant DesktopProposalListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.proposal != oldWidget.proposal) {
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

  @override
  void didUpdateWidget(covariant MobileProposalListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.proposal != oldWidget.proposal) {
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
// lib/src/features/dao_detail/widgets/proposal_list_item.dart