// lib/src/features/dao_detail/widgets/economy_benefits_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/economy_provider.dart';
import 'package:werule/src/services/economy_abi.dart';
import 'package:werule/src/utils/reusable.dart';

/// Card for claiming DAO benefits: passive income and delegation rewards.
/// These are payment tokens (not governance tokens) distributed based on epochs.
class EconomyBenefitsCard extends StatelessWidget {
  final Org dao;
  final bool compact;
  const EconomyBenefitsCard({super.key, required this.dao, this.compact = false});

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

    final hasAnyEpochs = provider.passiveIncomeEpochs.isNotEmpty || provider.delegateRewardEpochs.isNotEmpty;

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
              const Icon(Icons.card_giftcard, size: 40),
              const SizedBox(width: 12),
              Text(
                "CLAIM\nBENEFITS",
                style: TextStyle(fontSize: compact ? 16 : 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Claim payment tokens based on your rep balance and voting power.",
              style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          if (!hasAnyEpochs)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.hourglass_empty, size: 36, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    "No benefit epochs created yet",
                    style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            // Passive Income Section
            _BenefitTypeSection(
              icon: Icons.savings_outlined,
              label: "Passive Income",
              description: "Based on rep balance",
              epochs: provider.passiveIncomeEpochs,
              isActionBusy: provider.isActionBusy,
              onClaim: (epochId) async {
                try {
                  await provider.claimPassiveIncome(epochId);
                  if (context.mounted) {
                    _showSnackbar(context, "Passive income claimed!");
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showSnackbar(context, e.toString(), isError: true);
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            // Delegation Rewards Section
            _BenefitTypeSection(
              icon: Icons.group_outlined,
              label: "Delegation Rewards",
              description: "Based on voting power",
              epochs: provider.delegateRewardEpochs,
              isActionBusy: provider.isActionBusy,
              onClaim: (epochId) async {
                try {
                  await provider.claimDelegateReward(epochId);
                  if (context.mounted) {
                    _showSnackbar(context, "Delegation reward claimed!");
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showSnackbar(context, e.toString(), isError: true);
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _BenefitTypeSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final List<ClaimableEpoch> epochs;
  final bool isActionBusy;
  final Future<void> Function(BigInt epochId) onClaim;

  const _BenefitTypeSection({
    required this.icon,
    required this.label,
    required this.description,
    required this.epochs,
    required this.isActionBusy,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final claimableCount = epochs.where((e) => e.canClaim).length;
    final hasClaimable = claimableCount > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasClaimable
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasClaimable
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: hasClaimable ? Colors.green : Colors.grey[500]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: hasClaimable ? Colors.white : Colors.grey[400],
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              if (hasClaimable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$claimableCount available",
                    style: const TextStyle(fontSize: 11, color: Colors.green),
                  ),
                )
              else if (epochs.isEmpty)
                Text(
                  "No epochs",
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                )
              else
                Text(
                  "None available",
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
            ],
          ),
          // Show claimable epochs
          if (hasClaimable) ...[
            const SizedBox(height: 12),
            ...epochs.where((e) => e.canClaim).map((epoch) => _ClaimableEpochItem(
              epoch: epoch,
              isActionBusy: isActionBusy,
              onClaim: () => onClaim(epoch.epochId),
            )),
          ],
        ],
      ),
    );
  }
}

class _ClaimableEpochItem extends StatelessWidget {
  final ClaimableEpoch epoch;
  final bool isActionBusy;
  final VoidCallback onClaim;

  const _ClaimableEpochItem({
    required this.epoch,
    required this.isActionBusy,
    required this.onClaim,
  });

  String _getTokenSymbol(String tokenAddress) {
    if (tokenAddress.toLowerCase() == EconomyAbi.nativeCurrencyAddress.toLowerCase()) {
      return 'XTZ';
    }
    return shortenString(tokenAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${formatTotalSupply(epoch.estimatedReward.toString(), 18)} ${_getTokenSymbol(epoch.epoch.paymentToken)}",
                  style: const TextStyle(fontSize: 13, color: Colors.green),
                ),
              ],
            ),
          ),
          if (isActionBusy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TextButton(
              onPressed: onClaim,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
              ),
              child: const Text("Claim"),
            ),
        ],
      ),
    );
  }
}
