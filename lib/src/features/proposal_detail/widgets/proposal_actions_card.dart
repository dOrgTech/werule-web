// lib/src/features/proposal_detail/widgets/proposal_actions_card.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/proposal_detail_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/utils/reusable.dart';
import 'package:url_launcher/url_launcher.dart';

// An enum to represent the card's self-contained state.
enum _CardStatus { idle, awaitingWallet, awaitingIndexer }

class ProposalActionsCard extends StatefulWidget {
  const ProposalActionsCard({super.key});

  @override
  State<ProposalActionsCard> createState() => _ProposalActionsCardState();
}

class _ProposalActionsCardState extends State<ProposalActionsCard> {
  _CardStatus _status = _CardStatus.idle;
  int _lastSeenProposalVersion = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProposalDetailProvider>();
    final auth = context.watch<AuthProvider>();
    final currentProposalVersion = provider.proposal.hashCode;

    // If the proposal data from the provider has changed, the indexer has
    // delivered an update. We can safely reset our internal state to idle.
    if (currentProposalVersion != _lastSeenProposalVersion) {
      _status = _CardStatus.idle;
      _lastSeenProposalVersion = currentProposalVersion;
    }

    Widget content;

    switch (_status) {
      case _CardStatus.awaitingWallet:
        content = const _WaitingWidget(
          message: "Waiting for confirmation in your wallet...",
        );
        break;
      case _CardStatus.awaitingIndexer:
        content = const _WaitingWidget(
          message: "Transaction sent. Waiting for update...",
        );
        break;
      case _CardStatus.idle:
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
              // THE FIX: Correctly referencing the getter from the provided provider file.
              hasVoted: provider.hasUserVoted,
              onStatusChange: (newStatus) {
                if (mounted) {
                  setState(() {
                    _status = newStatus;
                  });
                }
              },
            ),
          ],
        );
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: content,
    );
  }
}

class _WaitingWidget extends StatelessWidget {
  final String message;
  const _WaitingWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          width: 100,
          child: Opacity(
            opacity: 0.7,
            child: Lottie.asset("assets/d4.json"),
          ),
        ),
      ],
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
  final void Function(_CardStatus) onStatusChange;

  const _ActionButtons({
    required this.status, 
    required this.isConnected,
    required this.pastVoteWeight,
    required this.hasVoted,
    required this.onStatusChange,
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

  Future<void> _handleAction(BuildContext context, Function action) async {
    onStatusChange(_CardStatus.awaitingWallet);
    try {
      await context.read<ProposalDetailProvider>().handleAction(action);
      onStatusChange(_CardStatus.awaitingIndexer);
    } on AccountMismatchException catch (e) {
      onStatusChange(_CardStatus.idle);
      if (context.mounted) _showAccountMismatchDialog(context, e);
    } catch (e) {
      onStatusChange(_CardStatus.idle);
      if (context.mounted) _showSnackbar(context, e.toString(), isError: true);
    }
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProposalDetailProvider>();
    final auth = context.read<AuthProvider>();
    final signerAddress = auth.selectedAccount;

    switch (status) {
      case ProposalStatus.Active:
        if (hasVoted) {
          return const Text("You have already voted.", style: TextStyle(color: Colors.grey));
        }
        return _buildVoteButtons(context, provider, signerAddress);
      case ProposalStatus.Succeeded:
        return _buildQueueButton(context, provider, signerAddress);
      case ProposalStatus.Executable:
        return _buildExecuteButton(context, provider, signerAddress);
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

  Widget _buildVoteButtons(BuildContext context, ProposalDetailProvider provider, String? signerAddress) {
    final bool isEnabled = isConnected && pastVoteWeight > BigInt.zero; 
    const Color supportColor = Color.fromARGB(255, 20, 78, 49);
    const Color rejectColor = Color.fromARGB(255, 88, 20, 20);
    final proposal = provider.proposal;
    final org = provider.org;

    final buttonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(140, 50),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );

    Widget supportButton = ElevatedButton.icon(
      onPressed: isEnabled ? () async {
        if (signerAddress == null) return;
        await _handleAction(
          context,
          () => context.read<BlockchainService>().castVote(org.address, BigInt.parse(proposal.id), 1, signerAddress),
        );
      } : null,
      icon: Icon(Icons.thumb_up, color: isEnabled ? supportColor : Colors.grey),
      label: Text("Support", style: TextStyle(color: isEnabled ? supportColor : Colors.grey)),
      style: buttonStyle.copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) return Colors.grey[800];
            return const Color.fromARGB(255, 141, 255, 244);
          },
        ),
      ),
    );

    Widget rejectButton = ElevatedButton.icon(
       onPressed: isEnabled ? () async {
        if (signerAddress == null) return;
        await _handleAction(
          context,
          () => context.read<BlockchainService>().castVote(org.address, BigInt.parse(proposal.id), 0, signerAddress),
        );
      } : null,
      icon: Icon(Icons.thumb_down, color: isEnabled ? rejectColor : Colors.grey),
      label: Text("Reject", style: TextStyle(color: isEnabled ? rejectColor : Colors.grey)),
      style: buttonStyle.copyWith(
         backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) return Colors.grey[800];
            return const Color.fromARGB(255, 255, 135, 135);
          },
        ),
      ),
    );

    if (!isConnected) {
      supportButton = Tooltip(message: "Connect your wallet", child: supportButton);
      rejectButton = Tooltip(message: "Connect your wallet", child: rejectButton);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        supportButton,
        rejectButton,
      ],
    );
  }

   Widget _buildQueueButton(BuildContext context, ProposalDetailProvider provider, String? signerAddress) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 196, 196, 196),
      minimumSize: const Size(180, 50),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
    
    Widget button = ElevatedButton(
      onPressed: isConnected ? () async {
        if (signerAddress == null) return;
        final proposal = provider.proposal;
        final org = provider.org;
        final packedDescription = "${proposal.title}0|||0${proposal.author}0|||0${proposal.type ?? ''}0|||0${proposal.description}0|||0${proposal.externalResource ?? ''}";
        final valuesAsBigInt = proposal.values.map((v) => BigInt.tryParse(v) ?? BigInt.zero).toList();
        final calldatasAsBytes = proposal.callDatas.map((cd) => hexToBytes(cd)).toList();

        await _handleAction(
          context,
          () => context.read<BlockchainService>().queueProposal(
                org.address,
                signerAddress,
                proposal.targets,
                valuesAsBigInt,
                calldatasAsBytes,
                packedDescription,
              ),
        );
      } : null,
      style: buttonStyle,
      child: const Text("Queue for Execution", style: TextStyle(color: Colors.black),),
    );

    if (!isConnected) {
      return Tooltip(message: "Connect your wallet", child: button);
    }
    return button;
  }

  Widget _buildExecuteButton(BuildContext context, ProposalDetailProvider provider, String? signerAddress) {
     final buttonStyle = ElevatedButton.styleFrom(
      elevation: 4,
      backgroundColor: const Color.fromARGB(255, 121, 240, 248),
      minimumSize: const Size(180, 50),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );

     Widget button = ElevatedButton(
      onPressed: isConnected ? () async {
        if (signerAddress == null) return;
        final proposal = provider.proposal;
        final org = provider.org;
        final packedDescription = "${proposal.title}0|||0${proposal.author}0|||0${proposal.type ?? ''}0|||0${proposal.description}0|||0${proposal.externalResource ?? ''}";
        final valuesAsBigInt = proposal.values.map((v) => BigInt.tryParse(v) ?? BigInt.zero).toList();
        final calldatasAsBytes = proposal.callDatas.map((cd) => hexToBytes(cd)).toList();

        await _handleAction(
          context,
          () => context.read<BlockchainService>().executeProposal(
                org.address,
                signerAddress,
                proposal.targets,
                valuesAsBigInt,
                calldatasAsBytes,
                packedDescription,
              ),
        );
      } : null,
      style: buttonStyle,
      child: const Text("EXECUTE", style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold),),
    );

    if (!isConnected) {
      return Tooltip(message: "Connect your wallet", child: button);
    }
    return button;
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