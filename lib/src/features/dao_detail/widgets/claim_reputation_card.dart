// lib/src/features/dao_detail/widgets/claim_reputation_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/economy_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/economy_abi.dart';
import 'package:werule/src/utils/reusable.dart';

class ClaimReputationCard extends StatelessWidget {
  final Org dao;
  const ClaimReputationCard({super.key, required this.dao});

  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(child: Text(message)),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  String _getTokenDisplay(String tokenAddress) {
    if (tokenAddress.toLowerCase() == EconomyAbi.nativeCurrencyAddress.toLowerCase()) {
      return 'Native Currency';
    }
    return shortenString(tokenAddress);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EconomyProvider>();

    if (provider.isLoading) {
      return const Card(
        color: Color(0xff2c2c2c),
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final profile = provider.economyProfile;

    return Card(
      color: const Color(0xff2c2c2c),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text("Economic Activity & Reputation", style: TextStyle(fontSize: 20)),
                ),
                if (provider.hasUnclaimedReputation)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Claimable",
                      style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Your economic activity in this jurisdiction earns you reputation (governance tokens). "
              "Claim your reputation to participate in governance.",
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Economic Activity Summary
            if (profile != null) ...[
              _buildActivitySummary(context, profile, provider),
              const SizedBox(height: 24),
            ],

            // Unclaimed Reputation Section
            _buildUnclaimedSection(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySummary(BuildContext context, EconomyUserProfile profile, EconomyProvider provider) {
    final totalEarnings = profile.earnedAmounts.fold<BigInt>(BigInt.zero, (sum, e) => sum + e);
    final totalSpendings = profile.spentAmounts.fold<BigInt>(BigInt.zero, (sum, e) => sum + e);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Activity Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[300])),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 550;

          final stats = [
            _StatBox(
              label: "Total Earnings",
              value: formatTotalSupply(totalEarnings.toString(), 18),
              icon: Icons.arrow_downward,
              color: Colors.green,
            ),
            _StatBox(
              label: "Total Spendings",
              value: formatTotalSupply(totalSpendings.toString(), 18),
              icon: Icons.arrow_upward,
              color: Colors.orange,
            ),
            _StatBox(
              label: "Projects as Author",
              value: profile.projectsAsAuthor.length.toString(),
              icon: Icons.edit_document,
              color: Colors.blue,
            ),
            _StatBox(
              label: "Projects as Contractor",
              value: profile.projectsAsContractor.length.toString(),
              icon: Icons.engineering,
              color: Colors.purple,
            ),
          ];

          if (isNarrow) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: stats[0]),
                    const SizedBox(width: 12),
                    Expanded(child: stats[1]),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: stats[2]),
                    const SizedBox(width: 12),
                    Expanded(child: stats[3]),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: stats.map((s) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: s))).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildUnclaimedSection(BuildContext context, EconomyProvider provider) {
    final unclaimedActivities = provider.unclaimedActivities;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border.all(
          width: 1,
          color: provider.hasUnclaimedReputation ? Colors.amber.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: provider.hasUnclaimedReputation ? Colors.amber : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                "Claimable Reputation",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: provider.hasUnclaimedReputation ? Colors.amber : Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!provider.hasUnclaimedReputation)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[600]),
                    const SizedBox(height: 12),
                    Text(
                      "All reputation has been claimed",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Participate in projects to earn more reputation",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // List unclaimed activities by token
            ...unclaimedActivities.map((activity) => _UnclaimedActivityItem(
                  activity: activity,
                  tokenDisplay: _getTokenDisplay(activity.tokenAddress),
                )),
            const SizedBox(height: 20),
            // Claim button
            Center(
              child: provider.isActionBusy
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await provider.claimReputationFromEconomy();
                          if (context.mounted) {
                            _showSnackbar(context, "Reputation claimed successfully! Your voting power has increased.");
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showSnackbar(context, e.toString(), isError: true);
                          }
                        }
                      },
                      icon: const Icon(Icons.redeem),
                      label: const Text("Claim Reputation"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _UnclaimedActivityItem extends StatelessWidget {
  final UnclaimedActivity activity;
  final String tokenDisplay;

  const _UnclaimedActivityItem({
    required this.activity,
    required this.tokenDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tokenDisplay,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (activity.unclaimedEarnings > BigInt.zero)
                  Text(
                    "Unclaimed earnings: ${formatTotalSupply(activity.unclaimedEarnings.toString(), 18)}",
                    style: TextStyle(fontSize: 12, color: Colors.green[300]),
                  ),
                if (activity.unclaimedSpendings > BigInt.zero)
                  Text(
                    "Unclaimed spendings: ${formatTotalSupply(activity.unclaimedSpendings.toString(), 18)}",
                    style: TextStyle(fontSize: 12, color: Colors.orange[300]),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Total Unclaimed", style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                formatTotalSupply(activity.totalUnclaimed.toString(), 18),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
