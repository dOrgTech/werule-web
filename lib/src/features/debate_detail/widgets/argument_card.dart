// lib/src/features/debate_detail/widgets/argument_card.dart

import 'package:flutter/material.dart';
import 'package:werule/src/models/debate.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/utils/reusable.dart';

/// Detailed card for the currently selected argument
class ArgumentDetailCard extends StatelessWidget {
  final DebateArgument argument;
  final Org org;
  final bool isRoot;

  const ArgumentDetailCard({
    super.key,
    required this.argument,
    required this.org,
    this.isRoot = false,
  });

  Color _getScoreColor() {
    if (argument.netScore > BigInt.zero) return Colors.green;
    if (argument.netScore < BigInt.zero) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff2c2c2c),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRoot
              ? const Color(0xffa1d0d0).withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
          width: isRoot ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with author and type
          Row(
            children: [
              if (isRoot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xffa1d0d0).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ROOT THESIS',
                    style: TextStyle(
                      color: Color(0xffa1d0d0),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: argument.argType == ArgumentType.pro
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    argument.argType == ArgumentType.pro ? 'PRO' : 'CON',
                    style: TextStyle(
                      color: argument.argType == ArgumentType.pro ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                shortenString(argument.author),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Text(
            argument.content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _buildStat(
                icon: Icons.fitness_center,
                label: 'Direct Weight',
                value: formatTotalSupply(argument.directWeight.toString(), 18),
              ),
              const SizedBox(width: 24),
              _buildStat(
                icon: Icons.trending_up,
                label: 'Net Score',
                value: argument.netScoreFormatted >= 0
                    ? '+${argument.netScoreFormatted.toStringAsFixed(2)}'
                    : argument.netScoreFormatted.toStringAsFixed(2),
                color: _getScoreColor(),
              ),
              const SizedBox(width: 24),
              _buildStat(
                icon: Icons.check_circle_outline,
                label: 'Status',
                value: argument.isValid ? 'Valid' : 'Invalid',
                color: argument.isValid ? Colors.green : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMiniStat(
                icon: Icons.thumb_up_outlined,
                value: '${argument.proChildren.length}',
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                icon: Icons.thumb_down_outlined,
                value: '${argument.conChildren.length}',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[500]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

/// Compact list item for child arguments
class ArgumentListItem extends StatelessWidget {
  final DebateArgument argument;
  final Org org;
  final VoidCallback onTap;

  const ArgumentListItem({
    super.key,
    required this.argument,
    required this.org,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = argument.netScore > BigInt.zero
        ? Colors.green
        : argument.netScore < BigInt.zero
            ? Colors.red
            : Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content preview
            Text(
              argument.content.length > 150
                  ? '${argument.content.substring(0, 150)}...'
                  : argument.content,
              style: TextStyle(
                color: argument.isValid ? Colors.white : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            // Stats row
            Row(
              children: [
                Text(
                  'by ${shortenString(argument.author)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const Spacer(),
                // Weight
                Row(
                  children: [
                    Icon(Icons.fitness_center, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 2),
                    Text(
                      formatTotalSupply(argument.directWeight.toString(), 18),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    argument.netScoreFormatted >= 0
                        ? '+${argument.netScoreFormatted.toStringAsFixed(1)}'
                        : argument.netScoreFormatted.toStringAsFixed(1),
                    style: TextStyle(fontSize: 11, color: scoreColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                // Children counts
                if (argument.proChildren.isNotEmpty || argument.conChildren.isNotEmpty) ...[
                  Icon(Icons.thumb_up_outlined, size: 12, color: Colors.green[300]),
                  const SizedBox(width: 2),
                  Text('${argument.proChildren.length}',
                      style: TextStyle(fontSize: 11, color: Colors.green[300])),
                  const SizedBox(width: 8),
                  Icon(Icons.thumb_down_outlined, size: 12, color: Colors.red[300]),
                  const SizedBox(width: 2),
                  Text('${argument.conChildren.length}',
                      style: TextStyle(fontSize: 11, color: Colors.red[300])),
                ],
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey[500]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
