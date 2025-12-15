// lib/src/features/dao_detail/widgets/claim_reputation_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/economy_provider.dart';
import 'package:werule/src/utils/reusable.dart';

/// Simplified card for claiming reputation from economic activity.
/// Shows total earnings, spendings, and claimable reputation.
class ClaimReputationCard extends StatelessWidget {
  final Org dao;
  final bool compact;
  const ClaimReputationCard({super.key, required this.dao, this.compact = false});

  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(child: Text(message)),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EconomyProvider>();

    if (provider.isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          border: Border.all(width: 0.3, color: const Color.fromARGB(255, 105, 105, 105)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final profile = provider.economyProfile;
    final totalEarnings = profile?.earnedAmounts.fold<BigInt>(BigInt.zero, (sum, e) => sum + e) ?? BigInt.zero;
    final totalSpendings = profile?.spentAmounts.fold<BigInt>(BigInt.zero, (sum, e) => sum + e) ?? BigInt.zero;
    final totalUnclaimed = provider.unclaimedActivities.fold<BigInt>(
      BigInt.zero,
      (sum, a) => sum + a.totalUnclaimed
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border.all(width: 0.3, color: const Color.fromARGB(255, 105, 105, 105)),
      ),
      padding: EdgeInsets.all(compact ? 16.0 : 24.0),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 40),
              const SizedBox(width: 12),
              Text(
                "CLAIM\nREPUTATION",
                style: TextStyle(fontSize: compact ? 16 : 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Your economic activity in this jurisdiction earns you governance tokens.",
              style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Activity Summary
          Row(
            children: [
              Expanded(
                child: _MiniStatBox(
                  label: "Total Earnings",
                  value: formatTotalSupply(totalEarnings.toString(), 18),
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStatBox(
                  label: "Total Spendings",
                  value: formatTotalSupply(totalSpendings.toString(), 18),
                  icon: Icons.arrow_upward,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Claimable Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: provider.hasUnclaimedReputation
                  ? Colors.amber.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: provider.hasUnclaimedReputation
                    ? Colors.amber.withValues(alpha: 0.5)
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Claimable Reputation",
                  style: TextStyle(
                    fontSize: 12,
                    color: provider.hasUnclaimedReputation ? Colors.amber : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatTotalSupply(totalUnclaimed.toString(), 18),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: provider.hasUnclaimedReputation ? Colors.amber : Colors.grey[600],
                  ),
                ),
                Text(
                  dao.symbol,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Claim Button
          if (provider.hasUnclaimedReputation)
            provider.isActionBusy
                ? const SizedBox(height: 40, child: Center(child: CircularProgressIndicator()))
                : ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await provider.claimReputationFromEconomy();
                        if (context.mounted) {
                          _showSnackbar(context, "Reputation claimed successfully!");
                        }
                      } catch (e) {
                        if (context.mounted) {
                          _showSnackbar(context, e.toString(), isError: true);
                        }
                      }
                    },
                    icon: const Icon(Icons.redeem),
                    label: const Text("Claim"),
                  )
          else
            Text(
              "No reputation to claim",
              style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

class _MiniStatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
