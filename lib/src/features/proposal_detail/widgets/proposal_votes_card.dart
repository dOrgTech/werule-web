// lib/src/features/proposal_detail/widgets/proposal_votes_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/proposal_detail/widgets/votes_modal.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/proposal_detail_provider.dart';
import 'package:werule/src/utils/reusable.dart';

class ProposalVotesCard extends StatelessWidget {
  final Org org;
  const ProposalVotesCard({super.key, required this.org});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProposalDetailProvider>();
    final proposal = provider.proposal;

    final forVotes = proposal.inFavor;
    final againstVotes = proposal.against;
    final totalVotes = forVotes + againstVotes;
    final totalVoters = proposal.votesFor + proposal.votesAgainst;
    
    final int forPercentInt = totalVotes > BigInt.zero ? ((forVotes * BigInt.from(100)) ~/ totalVotes).toInt() : 0;
    final int againstPercentInt = totalVotes > BigInt.zero ? 100 - forPercentInt : 0;
    
    final totalSupply = BigInt.tryParse(proposal.totalSupply) ?? BigInt.zero;
    final double turnoutPercentDouble;
    if (totalSupply > BigInt.zero) {
      final turnoutBigInt = (totalVotes * BigInt.from(10000)) ~/ totalSupply;
      turnoutPercentDouble = turnoutBigInt.toInt() / 100.0;
    } else {
      turnoutPercentDouble = 0.0;
    }
    final bool quorumMet = turnoutPercentDouble >= org.quorum;

    String formatVotes(BigInt amount) {
      return formatTotalSupply(amount.toString(), org.decimals);
    }

    return Card(
      color: const Color(0xff2c2c2c),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        height: 280,
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 450;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("$totalVoters Voters", style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final isDialogMobile = screenWidth < 700;
                        final dialogWidth = isDialogMobile ? screenWidth * 0.9 : 800.0;

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xff222222),
                            title: const Text("Vote Details"),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                            content: SizedBox(
                              width: dialogWidth,
                              child: VotesModal(
                                proposalId: proposal.id,
                                org: provider.org,
                                network: provider.network,
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Close"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("View")),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _VoteStat(isMobile: isMobile, isSupport: true, votes: formatVotes(forVotes), percentage: "$forPercentInt.00%"),
                    _VoteStat(isMobile: isMobile, isSupport: false, votes: formatVotes(againstVotes), percentage: "$againstPercentInt.00%"),
                  ],
                ),
                const SizedBox(height: 12),
                _ProgressBar(
                  forPercent: forPercentInt.toDouble(),
                  againstPercent: againstPercentInt.toDouble(),
                  height: 12,
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    const Text("Turnout: ", style: TextStyle(fontSize: 16)),
                    Text("${formatVotes(totalVotes)} (${turnoutPercentDouble.toStringAsFixed(2)}%)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Text(quorumMet ? "Quorum Met" : "Quorum Not Met", style: TextStyle(fontWeight: FontWeight.bold, color: quorumMet ? Colors.green : Colors.grey, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                _ProgressBar(
                  forPercent: turnoutPercentDouble,
                  againstPercent: 0,
                  height: 12,
                  quorumPercent: org.quorum.toDouble(),
                  fillColor: Colors.grey.shade400,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VoteStat extends StatelessWidget {
  final bool isMobile;
  final bool isSupport;
  final String votes;
  final String percentage;

  const _VoteStat({required this.isMobile, required this.isSupport, required this.votes, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final supportColor = const Color(0xff00c489);
    final opposeColor = const Color(0xff86251e);
    final color = isSupport ? supportColor : opposeColor;

    if (isMobile) {
      return Row(
        children: [
          Icon(isSupport ? Icons.thumb_up : Icons.thumb_down, color: color, size: 20),
          const SizedBox(width: 8),
          Text(votes, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Text(percentage, style: TextStyle(color: Colors.grey[400])),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 8),
        Text(isSupport ? "Support" : "Oppose", style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 16),
        Text(votes, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 8),
        Text(percentage, style: TextStyle(color: Colors.grey[400])),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double forPercent;
  final double againstPercent;
  final double height;
  final double? quorumPercent;
  final Color? fillColor;

  const _ProgressBar({
    required this.forPercent,
    required this.againstPercent,
    this.height = 8.0,
    this.quorumPercent,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(color: Colors.grey.shade800),
          ),
          if (fillColor != null)
            Container(
              width: constraints.maxWidth * (forPercent / 100),
              height: height,
              color: fillColor,
            )
          else
            Row(
              children: [
                Container(
                  width: constraints.maxWidth * (forPercent / 100),
                  height: height,
                  color: const Color(0xff00c489),
                ),
                Container(
                  width: constraints.maxWidth * (againstPercent / 100),
                  height: height,
                  color: const Color(0xff86251e),
                ),
              ],
            ),
          if (quorumPercent != null)
            Positioned(
              left: (constraints.maxWidth * (quorumPercent! / 100)) - 1,
              top: -4,
              bottom: -4,
              child: Container(width: 2, color: Colors.black),
            ),
        ],
      );
    });
  }
}
// lib/src/features/proposal_detail/widgets/proposal_votes_card.dart