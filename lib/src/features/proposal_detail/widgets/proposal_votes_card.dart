// lib/src/features/proposal_detail/widgets/proposal_votes_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/proposal_detail_provider.dart';
import 'package:werule/src/utils/reusable.dart';

class ProposalVotesCard extends StatelessWidget {
  final Org org;
  const ProposalVotesCard({super.key, required this.org});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProposalDetailProvider>();

    final forVotes = provider.onChainForVotes;
    final againstVotes = provider.onChainAgainstVotes;
    final totalVotes = forVotes + againstVotes;
    
    final int forPercentInt = totalVotes > BigInt.zero ? ((forVotes * BigInt.from(100)) ~/ totalVotes).toInt() : 0;
    final int againstPercentInt = totalVotes > BigInt.zero ? 100 - forPercentInt : 0;
    
    final totalSupply = BigInt.tryParse(org.totalSupply) ?? BigInt.zero;
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
      child: Container(
        height: 280,
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // THE FIX: Use Row with Spacer to push button to the right
            Row(
              children: [
                Text("${formatVotes(totalVotes)} Votes", style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                 ElevatedButton(
                    onPressed: () { /* TODO: Show votes modal */ },
                    child: const Text("View")),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                _VoteStat(color: const Color(0xff00c489), label: "Support", votes: formatVotes(forVotes), percentage: "$forPercentInt.00%"),
                const Spacer(),
                _VoteStat(color: const Color(0xff86251e), label: "Oppose", votes: formatVotes(againstVotes), percentage: "$againstPercentInt.00%"),
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
              // THE FIX: Use the new fillColor property for the turnout bar
              fillColor: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteStat extends StatelessWidget {
  final Color color;
  final String label;
  final String votes;
  final String percentage;

  const _VoteStat({required this.color, required this.label, required this.votes, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 16)),
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
  final Color? fillColor; // THE FIX: Add optional fillColor

  const _ProgressBar({
    required this.forPercent,
    required this.againstPercent,
    this.height = 8.0,
    this.quorumPercent,
    this.fillColor, // THE FIX: Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        clipBehavior: Clip.none, // Allow quorum marker to draw outside
        children: [
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
          // THE FIX: Conditional rendering based on fillColor
          if (fillColor != null)
            Container(
              width: constraints.maxWidth * (forPercent / 100),
              height: height,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            )
          else
            Row(
              children: [
                Container(
                  width: constraints.maxWidth * (forPercent / 100),
                  height: height,
                  decoration: BoxDecoration(
                    color: const Color(0xff00c489),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
                Container(
                  width: constraints.maxWidth * (againstPercent / 100),
                  height: height,
                  decoration: BoxDecoration(
                    color: const Color(0xff86251e),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ],
            ),
          if (quorumPercent != null)
            Positioned(
              left: (constraints.maxWidth * (quorumPercent! / 100)) - 1, // center the marker
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