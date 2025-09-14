// lib/src/features/proposal_detail/widgets/proposal_actions_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/proposal_detail_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';

class ProposalActionsCard extends StatelessWidget {
  const ProposalActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProposalDetailProvider>();
    final auth = context.watch<AuthProvider>();

    Widget content;
    if (provider.isActionBusy) {
      content = const Center(child: CircularProgressIndicator());
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionLabel(status: provider.status),
          if (provider.showCountdown)
            _Countdown(remainingSeconds: provider.remainingSeconds),
          const SizedBox(height: 24),
          _ActionButtons(
            status: provider.status,
            isConnected: auth.isConnected,
          ),
        ],
      );
    }

    return Card(
      color: const Color(0xff2c2c2c),
      child: Container(
        height: 280,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }
}

// --- Action Buttons ---
class _ActionButtons extends StatelessWidget {
  final ProposalStatus status;
  final bool isConnected;

  const _ActionButtons({required this.status, required this.isConnected});

  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(child: Text(message)),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProposalDetailProvider>();

    switch (status) {
      case ProposalStatus.Active:
        return _buildVoteButtons(context, provider);
      case ProposalStatus.Succeeded:
        return _buildQueueButton(context, provider);
      case ProposalStatus.Executable:
        return _buildExecuteButton(context, provider);
      case ProposalStatus.Executed:
        // In a real app, you would get the execution hash from the proposal model
        return const Text("Execution TX: 0x_mock_hash...");
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVoteButtons(BuildContext context, ProposalDetailProvider provider) {
    final bool isEnabled = isConnected; 
    const Color supportColor = Color.fromARGB(255, 20, 78, 49);
    const Color rejectColor = Color.fromARGB(255, 88, 20, 20);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // SUPPORT BUTTON
        ElevatedButton.icon(
          onPressed: isEnabled ? () async {
            final error = await provider.handleAction(() => 
              context.read<BlockchainService>().castVote("0xTODO", BigInt.zero, 1)
            );
            if (context.mounted) {
              if (error != null) {
                _showSnackbar(context, error, isError: true);
              } else {
                _showSnackbar(context, "Vote cast successfully!");
              }
            }
          } : null,
          icon: Icon(Icons.thumb_up, color: isEnabled ? supportColor : Colors.grey),
          label: Text("Support", style: TextStyle(color: isEnabled ? supportColor : Colors.grey)),
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? const Color.fromARGB(255, 141, 255, 244) : Colors.grey[800],
            fixedSize: const Size(140, 40),
          ),
        ),
        // REJECT BUTTON
        ElevatedButton.icon(
           onPressed: isEnabled ? () async {
            final error = await provider.handleAction(() => 
              context.read<BlockchainService>().castVote("0xTODO", BigInt.zero, 0)
            );
             if (context.mounted) {
              if (error != null) {
                _showSnackbar(context, error, isError: true);
              } else {
                _showSnackbar(context, "Vote cast successfully!");
              }
            }
          } : null,
          icon: Icon(Icons.thumb_down, color: isEnabled ? rejectColor : Colors.grey),
          label: Text("Reject", style: TextStyle(color: isEnabled ? rejectColor : Colors.grey)),
           style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? const Color.fromARGB(255, 255, 135, 135) : Colors.grey[800],
            fixedSize: const Size(140, 40),
          ),
        ),
      ],
    );
  }

   Widget _buildQueueButton(BuildContext context, ProposalDetailProvider provider) {
    return ElevatedButton(
      onPressed: () async {
         final error = await provider.handleAction(() => 
          context.read<BlockchainService>().queueProposal("0xTODO", BigInt.zero)
        );
        if (context.mounted) {
          if (error != null) {
            _showSnackbar(context, error, isError: true);
          } else {
            _showSnackbar(context, "Proposal queued for execution!");
          }
        }
      },
      child: const Text("Queue for Execution"),
    );
  }

  Widget _buildExecuteButton(BuildContext context, ProposalDetailProvider provider) {
     return ElevatedButton(
      onPressed: () async {
        final error = await provider.handleAction(() => 
          context.read<BlockchainService>().executeProposal("0xTODO", BigInt.zero)
        );
         if (context.mounted) {
          if (error != null) {
            _showSnackbar(context, error, isError: true);
          } else {
            _showSnackbar(context, "Proposal executed!");
          }
        }
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      child: const Text("EXECUTE"),
    );
  }
}


// --- Action Label ---
class _ActionLabel extends StatelessWidget {
  final ProposalStatus status;
  const _ActionLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    switch (status) {
      case ProposalStatus.Pending:
        text = 'Voting begins in:';
        break;
      case ProposalStatus.Active:
        text = 'Voting ends in:';
        break;
      case ProposalStatus.Queued:
        text = 'Executable in:';
        break;
      default:
        text = 'Voting has ended';
    }
    return Text(text, style: const TextStyle(fontSize: 16));
  }
}

// --- Countdown Timer ---
class _Countdown extends StatelessWidget {
  final int remainingSeconds;
  const _Countdown({required this.remainingSeconds});

  @override
  Widget build(BuildContext context) {
    final d = (remainingSeconds / (24 * 3600)).floor();
    final h = (remainingSeconds % (24 * 3600) / 3600).floor();
    final m = (remainingSeconds % 3600 / 60).floor();
    final s = remainingSeconds % 60;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (d > 0) _buildTimeBox(d, 'DAYS'),
          _buildTimeBox(h, 'HOURS'),
          _buildTimeBox(m, 'MINS'),
          _buildTimeBox(s, 'SECS'),
        ],
      ),
    );
  }

  Widget _buildTimeBox(int time, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(time.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/proposal_actions_card.dart