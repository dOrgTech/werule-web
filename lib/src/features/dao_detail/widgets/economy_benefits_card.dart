// lib/src/features/dao_detail/widgets/economy_benefits_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/economy_provider.dart';
import 'package:werule/src/services/economy_abi.dart';
import 'package:werule/src/utils/reusable.dart';

class EconomyBenefitsCard extends StatelessWidget {
  final Org dao;
  const EconomyBenefitsCard({super.key, required this.dao});

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
      return const Card(
        color: Color(0xff2c2c2c),
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final hasPassiveIncomeEpochs = provider.passiveIncomeEpochs.isNotEmpty;
    final hasDelegateRewardEpochs = provider.delegateRewardEpochs.isNotEmpty;

    if (!hasPassiveIncomeEpochs && !hasDelegateRewardEpochs) {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xff2c2c2c),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("DAO Benefits", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              "Claim your share of rewards distributed by the DAO based on your participation.",
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 850;

              final passiveIncomeSection = _BenefitsSection(
                icon: Icons.savings_outlined,
                title: "PASSIVE\nINCOME",
                description: "Rewards distributed to all reputation holders based on their share of the total supply. Hold reputation to earn.",
                epochs: provider.passiveIncomeEpochs,
                isPassiveIncome: true,
                isActionBusy: provider.isActionBusy,
                onClaim: (epochId) async {
                  try {
                    await provider.claimPassiveIncome(epochId);
                    if (context.mounted) {
                      _showSnackbar(context, "Passive income claimed successfully!");
                    }
                  } catch (e) {
                    if (context.mounted) {
                      _showSnackbar(context, e.toString(), isError: true);
                    }
                  }
                },
              );

              final delegateRewardSection = _BenefitsSection(
                icon: Icons.group_outlined,
                title: "REPRESENTATION\nREWARDS",
                description: "Rewards for delegates who represent other members. Earn by having voting power delegated to you.",
                epochs: provider.delegateRewardEpochs,
                isPassiveIncome: false,
                isActionBusy: provider.isActionBusy,
                onClaim: (epochId) async {
                  try {
                    await provider.claimDelegateReward(epochId);
                    if (context.mounted) {
                      _showSnackbar(context, "Representation reward claimed successfully!");
                    }
                  } catch (e) {
                    if (context.mounted) {
                      _showSnackbar(context, e.toString(), isError: true);
                    }
                  }
                },
              );

              if (isMobile) {
                return Column(
                  children: [
                    if (hasPassiveIncomeEpochs) passiveIncomeSection,
                    if (hasPassiveIncomeEpochs && hasDelegateRewardEpochs) const SizedBox(height: 24),
                    if (hasDelegateRewardEpochs) delegateRewardSection,
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasPassiveIncomeEpochs) Flexible(child: passiveIncomeSection),
                    if (hasPassiveIncomeEpochs && hasDelegateRewardEpochs) const SizedBox(width: 40),
                    if (hasDelegateRewardEpochs) Flexible(child: delegateRewardSection),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<ClaimableEpoch> epochs;
  final bool isPassiveIncome;
  final bool isActionBusy;
  final Future<void> Function(BigInt epochId) onClaim;

  const _BenefitsSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.epochs,
    required this.isPassiveIncome,
    required this.isActionBusy,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final claimableEpochs = epochs.where((e) => e.canClaim).toList();
    final hasClaimable = claimableEpochs.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border.all(width: 0.3, color: const Color.fromARGB(255, 105, 105, 105)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(description, style: TextStyle(color: Colors.grey[300], fontSize: 15, height: 1.4), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          if (epochs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No reward epochs have been created yet.",
                style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
              ),
            )
          else
            ...epochs.map((epoch) => _EpochListItem(
                  epoch: epoch,
                  isActionBusy: isActionBusy,
                  onClaim: () => onClaim(epoch.epochId),
                )),
          const SizedBox(height: 16),
          if (hasClaimable && !isActionBusy)
            ElevatedButton(
              onPressed: () async {
                // Claim all available
                for (final epoch in claimableEpochs) {
                  await onClaim(epoch.epochId);
                }
              },
              child: const Text("Claim All Available"),
            )
          else if (isActionBusy)
            const CircularProgressIndicator()
          else if (!hasClaimable && epochs.isNotEmpty)
            Text(
              "No rewards available to claim",
              style: TextStyle(color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}

class _EpochListItem extends StatelessWidget {
  final ClaimableEpoch epoch;
  final bool isActionBusy;
  final VoidCallback onClaim;

  const _EpochListItem({
    required this.epoch,
    required this.isActionBusy,
    required this.onClaim,
  });

  String _formatTimestamp(BigInt timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getTokenSymbol(String tokenAddress) {
    if (tokenAddress.toLowerCase() == EconomyAbi.nativeCurrencyAddress.toLowerCase()) {
      return 'Native';
    }
    return shortenString(tokenAddress);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = epoch.hasClaimed
        ? Colors.green
        : epoch.canClaim
            ? Colors.amber
            : Colors.grey;
    final statusText = epoch.hasClaimed
        ? "Claimed"
        : epoch.canClaim
            ? "Available"
            : "Not eligible";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                  "Epoch #${epoch.epochId}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Started: ${_formatTimestamp(epoch.epoch.startTimestamp)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                if (epoch.canClaim) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Est. reward: ${formatTotalSupply(epoch.estimatedReward.toString(), 18)} ${_getTokenSymbol(epoch.epoch.paymentToken)}",
                    style: const TextStyle(fontSize: 12, color: Colors.amber),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 12, color: statusColor),
                ),
              ),
              if (epoch.canClaim && !isActionBusy) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onClaim,
                  child: const Text("Claim"),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
