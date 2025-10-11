// lib/src/features/proposal_detail/widgets/proposal_actions_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/proposal_detail_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/utils/reusable.dart';
import 'package:url_launcher/url_launcher.dart';

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
          const SizedBox(height: 16),
          if (auth.isConnected)
            _PastVoteWeightDisplay(status: provider.status),
          const SizedBox(height: 16),
          _ActionButtons(
            status: provider.status,
            isConnected: auth.isConnected,
            pastVoteWeight: provider.pastVotingWeight ?? BigInt.zero,
            hasVoted: provider.hasUserVoted,
          ),
        ],
      );
    }

    return Card(
      color: const Color(0xff2c2c2c),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        height: 280,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
    );
  }
}

class _PastVoteWeightDisplay extends StatelessWidget {
  final ProposalStatus status;
  const _PastVoteWeightDisplay({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status != ProposalStatus.Active) {
      return const SizedBox.shrink();
    }

    final provider = context.watch<ProposalDetailProvider>();
    final weight = provider.pastVotingWeight;
    final org = provider.org;
    
    if (weight == null) {
      return const SizedBox(
        height: 24, 
        width: 24, 
        child: CircularProgressIndicator(strokeWidth: 2)
      );
    }

    final displayWeight = formatTotalSupply(weight.toString(), org.decimals);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.grey, fontFamily: 'CascadiaCode'),
          children: [
            const TextSpan(text: "Your voting weight for this proposal is "),
            TextSpan(
              text: displayWeight, 
              style: TextStyle(color: Theme.of(context).indicatorColor, fontWeight: FontWeight.bold)
            ),
          ]
        ),
      ),
    );
  }
}


// --- Action Buttons ---
class _ActionButtons extends StatelessWidget {
  final ProposalStatus status;
  final bool isConnected;
  final BigInt pastVoteWeight;
  final bool hasVoted;

  const _ActionButtons({
    required this.status, 
    required this.isConnected,
    required this.pastVoteWeight,
    required this.hasVoted,
  });

  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(child: Text(message)),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  void _showAccountMismatchDialog(BuildContext context, AccountMismatchException e) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff2c2c2c),
        title: const Text("Account Mismatch"),
        content: Text(e.toString()),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProposalDetailProvider>();
    final auth = context.read<AuthProvider>();
    final signerAddress = auth.selectedAccount;

    if (signerAddress == null && (status == ProposalStatus.Active || status == ProposalStatus.Succeeded || status == ProposalStatus.Executable)) {
      return const SizedBox.shrink();
    }

    switch (status) {
      case ProposalStatus.Active:
        if (hasVoted) {
          return const Text("You have already voted.", style: TextStyle(color: Colors.grey));
        }
        return _buildVoteButtons(context, provider, signerAddress!);
      case ProposalStatus.Succeeded:
        return _buildQueueButton(context, provider, signerAddress!);
      case ProposalStatus.Executable:
        return _buildExecuteButton(context, provider, signerAddress!);
      case ProposalStatus.Executed:
        final hash = provider.proposal.executionHash;
        final explorerUrl = provider.network.blockExplorerUrl;
        if (hash == null || hash.isEmpty || explorerUrl.isEmpty) {
          return const Text("Proposal Executed", style: TextStyle(color: Colors.grey));
        }
        
        String txUrl = "$explorerUrl/tx/$hash";
        if (!hash.startsWith('0x')) {
          txUrl = "$explorerUrl/tx/0x$hash";
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Execution Transaction:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => launchUrl(Uri.parse(txUrl)),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shortenString(hash),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color.fromARGB(255, 168, 216, 255),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new, size: 16, color: Color.fromARGB(255, 168, 216, 255)),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVoteButtons(BuildContext context, ProposalDetailProvider provider, String signerAddress) {
    final bool isEnabled = isConnected && pastVoteWeight > BigInt.zero; 
    const Color supportColor = Color.fromARGB(255, 20, 78, 49);
    const Color rejectColor = Color.fromARGB(255, 88, 20, 20);
    final proposal = provider.proposal;
    final org = provider.org;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: isEnabled ? () async {
            try {
              await provider.handleAction(() => 
                context.read<BlockchainService>().castVote(org.address, BigInt.parse(proposal.id), 1, signerAddress)
              );
              if (context.mounted) _showSnackbar(context, "Vote cast successfully!");
            } on AccountMismatchException catch(e) {
              if (context.mounted) _showAccountMismatchDialog(context, e);
            } catch (e) {
              if (context.mounted) _showSnackbar(context, e.toString(), isError: true);
            }
          } : null,
          icon: Icon(Icons.thumb_up, color: isEnabled ? supportColor : Colors.grey),
          label: Text("Support", style: TextStyle(color: isEnabled ? supportColor : Colors.grey)),
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? const Color.fromARGB(255, 141, 255, 244) : Colors.grey[800],
            fixedSize: const Size(140, 40),
          ),
        ),
        ElevatedButton.icon(
           onPressed: isEnabled ? () async {
            try {
              await provider.handleAction(() => 
                context.read<BlockchainService>().castVote(org.address, BigInt.parse(proposal.id), 0, signerAddress)
              );
              if (context.mounted) _showSnackbar(context, "Vote cast successfully!");
            } on AccountMismatchException catch(e) {
              if (context.mounted) _showAccountMismatchDialog(context, e);
            } catch (e) {
              if (context.mounted) _showSnackbar(context, e.toString(), isError: true);
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

  Future<void> _handleQueueOrExecute(BuildContext context, Function action, String successMessage) async {
    try {
      await context.read<ProposalDetailProvider>().handleAction(action);
      if (context.mounted) _showSnackbar(context, successMessage);
    } on AccountMismatchException catch (e) {
      if (context.mounted) _showAccountMismatchDialog(context, e);
    } catch (e) {
      if (context.mounted) _showSnackbar(context, e.toString(), isError: true);
    }
  }

   Widget _buildQueueButton(BuildContext context, ProposalDetailProvider provider, String signerAddress) {
    return ElevatedButton(
      onPressed: () async {
        final proposal = provider.proposal;
        final org = provider.org;
        final packedDescription = "${proposal.title}0|||0${proposal.type ?? ''}0|||0${proposal.description}0|||0${proposal.externalResource ?? ''}";
        final valuesAsBigInt = proposal.values.map((v) => BigInt.tryParse(v) ?? BigInt.zero).toList();
        // THE FIX: Convert List<String> from model to List<Uint8List> for the service call.
        final calldatasAsBytes = proposal.callDatas.map((cd) => hexToBytes(cd)).toList();

        await _handleQueueOrExecute(
          context,
          () => context.read<BlockchainService>().queueProposal(
                org.address,
                signerAddress,
                proposal.targets,
                valuesAsBigInt,
                calldatasAsBytes,
                packedDescription,
              ),
          "Proposal queued successfully!",
        );
      },
      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 196, 196, 196)),
      child: const Text("Queue for Execution", style: TextStyle(color: Colors.black),),
    );
  }

  Widget _buildExecuteButton(BuildContext context, ProposalDetailProvider provider, String signerAddress) {
     return ElevatedButton(
      onPressed: () async {
        final proposal = provider.proposal;
        final org = provider.org;
        final packedDescription = "${proposal.title}0|||0${proposal.type ?? ''}0|||0${proposal.description}0|||0${proposal.externalResource ?? ''}";
        final valuesAsBigInt = proposal.values.map((v) => BigInt.tryParse(v) ?? BigInt.zero).toList();
        // THE FIX: Convert List<String> from model to List<Uint8List> for the service call.
        final calldatasAsBytes = proposal.callDatas.map((cd) => hexToBytes(cd)).toList();

        await _handleQueueOrExecute(
          context,
          () => context.read<BlockchainService>().executeProposal(
                org.address,
                signerAddress,
                proposal.targets,
                valuesAsBigInt,
                calldatasAsBytes,
                packedDescription,
              ),
          "Proposal executed successfully!",
        );
      },
      style: ElevatedButton.styleFrom(
        elevation: 4,
        backgroundColor: const Color.fromARGB(255, 121, 240, 248)),
      child: const Text("EXECUTE", style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold),),
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