// lib/src/features/dao_detail/widgets/debate_list_item.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:werule/src/models/debate.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/utils/reusable.dart';

/// Widget for displaying a debate item in the list
class DebateListItemWidget extends StatelessWidget {
  final DebateListItem debate;
  final Org org;
  final String networkName;

  const DebateListItemWidget({
    super.key,
    required this.debate,
    required this.org,
    required this.networkName,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getSentimentColor(double sentiment) {
    if (sentiment > 0) return Colors.green;
    if (sentiment < 0) return Colors.red;
    return Colors.grey;
  }

  void _navigateToDebate(BuildContext context) {
    context.go('/$networkName/${org.address}/debates/${debate.debateAddress}');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        if (isMobile) {
          return _MobileDebateListItem(
            debate: debate,
            org: org,
            formatDate: _formatDate,
            getSentimentColor: _getSentimentColor,
            onTap: () => _navigateToDebate(context),
          );
        }
        return _DesktopDebateListItem(
          debate: debate,
          org: org,
          formatDate: _formatDate,
          getSentimentColor: _getSentimentColor,
          onTap: () => _navigateToDebate(context),
        );
      },
    );
  }
}

class _DesktopDebateListItem extends StatelessWidget {
  final DebateListItem debate;
  final Org org;
  final String Function(DateTime) formatDate;
  final Color Function(double) getSentimentColor;
  final VoidCallback onTap;

  const _DesktopDebateListItem({
    required this.debate,
    required this.org,
    required this.formatDate,
    required this.getSentimentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff2c2c2c),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Title
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    const Icon(Icons.forum, size: 20, color: Color(0xffa1d0d0)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        debate.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Creator
              Expanded(
                flex: 2,
                child: Text(
                  shortenString(debate.creator),
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              // Created date
              SizedBox(
                width: 140,
                child: Text(
                  formatDate(debate.createdAtDateTime),
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              // Arguments count
              SizedBox(
                width: 100,
                child: Row(
                  children: [
                    const Icon(Icons.comment_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${debate.argumentCount}'),
                  ],
                ),
              ),
              // Sentiment
              SizedBox(
                width: 120,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: getSentimentColor(debate.sentimentFormatted).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      debate.sentimentFormatted >= 0
                          ? '+${debate.sentimentFormatted.toStringAsFixed(1)}'
                          : debate.sentimentFormatted.toStringAsFixed(1),
                      style: TextStyle(
                        color: getSentimentColor(debate.sentimentFormatted),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              // Status
              SizedBox(
                width: 80,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: debate.isOpen
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      debate.isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        color: debate.isOpen ? Colors.blue : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileDebateListItem extends StatelessWidget {
  final DebateListItem debate;
  final Org org;
  final String Function(DateTime) formatDate;
  final Color Function(double) getSentimentColor;
  final VoidCallback onTap;

  const _MobileDebateListItem({
    required this.debate,
    required this.org,
    required this.formatDate,
    required this.getSentimentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff2c2c2c),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.forum, size: 20, color: Color(0xffa1d0d0)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      debate.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('By ${shortenString(debate.creator)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  const Spacer(),
                  Text(formatDate(debate.createdAtDateTime),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Arguments
                  Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${debate.argumentCount} args',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  // Sentiment
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: getSentimentColor(debate.sentimentFormatted).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      debate.sentimentFormatted >= 0
                          ? '+${debate.sentimentFormatted.toStringAsFixed(1)}'
                          : debate.sentimentFormatted.toStringAsFixed(1),
                      style: TextStyle(
                        color: getSentimentColor(debate.sentimentFormatted),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: debate.isOpen
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      debate.isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        color: debate.isOpen ? Colors.blue : Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
