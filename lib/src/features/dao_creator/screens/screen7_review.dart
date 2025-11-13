// lib/src/features/dao_creator/screens/screen7_review.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';
import 'package:werule/src/features/dao_creator/utils/creator_utils.dart';
import 'package:werule/src/utils/theme.dart';

class Screen7Review extends StatelessWidget {
  final DaoCreatorProvider provider;

  const Screen7Review({
    super.key,
    required this.provider,
  });

  String formatDuration(Duration? duration) {
    if (duration == null) return 'Not set';
    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    if (days == 0 && hours == 0 && minutes == 0) return '0 minutes (Instant)';
    return '$days days, $hours hours, $minutes minutes';
  }

  Widget _buildReviewItem(BuildContext context, String label, String valueText,
      {TextStyle? customValueStyle, bool isDescription = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment:
            isDescription ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '$label:',
              textAlign: TextAlign.right,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              valueText,
              style: customValueStyle ??
                  TextStyle(
                    color: Theme.of(context).indicatorColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proposalThresholdTokenSymbol = provider.tokenSymbol ?? 'tokens';
    const double contentMaxWidth = 650.0;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 38.0, vertical: 20.0),
          child: SizedBox(
            width: contentMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.daoName ?? "My DAO",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text('${provider.daoType ?? "On-Chain"} Organization',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Icon(Icons.security,
                        size: 18, color: Theme.of(context).indicatorColor),
                  ],
                ),
                const SizedBox(height: 20),

                _buildReviewItem(
                  context,
                  "Description",
                  provider.daoDescription?.isNotEmpty == true
                      ? provider.daoDescription!
                      : "Not provided",
                  isDescription: true,
                ),
                const SizedBox(height: 20),

                // Token information - different for wrapped vs standard tokens
                if (provider.useWrappedToken) ...[
                  _buildReviewItem(
                      context, "Token Type", "Wrapped ERC20 Token"),
                  _buildReviewItem(
                      context, "Wrapped Token Symbol", provider.tokenSymbol ?? "N/A"),
                  _buildReviewItem(
                      context, "Underlying Token", provider.underlyingTokenAddress ?? "N/A"),
                  _buildReviewItem(
                      context, "Decimals", "Inherited from underlying token"),
                  _buildReviewItem(
                      context, "Transferable", provider.isTransferrable ? 'Yes' : 'No'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Users will need to deposit the underlying token to receive wrapped governance tokens.',
                            style: TextStyle(fontSize: 13, color: Colors.grey[300]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  _buildReviewItem(
                      context, "Token Type", "New Standard Token"),
                  _buildReviewItem(
                      context, "Ticker Symbol", provider.tokenSymbol ?? "N/A"),
                  _buildReviewItem(context, "Decimals", "18"),
                  _buildReviewItem(
                      context, "Transferable", provider.isTransferrable ? 'Yes' : 'No'),
                ],

                const SizedBox(height: 20),

                _buildReviewItem(
                    context, "Quorum Threshold", "${provider.quorumThreshold}%"),
                _buildReviewItem(context, "Proposal Threshold",
                    "${provider.proposalThreshold} $proposalThresholdTokenSymbol"),
                _buildReviewItem(context, "Voting Duration",
                    formatDuration(provider.votingDuration)),
                _buildReviewItem(
                    context, "Voting Delay", formatDuration(provider.votingDelay)),
                _buildReviewItem(context, "Execution Delay",
                    formatDuration(provider.executionDelay)),
                const SizedBox(height: 25),

                if (provider.daoType == 'Economy DAO') ...[
                  const Text('Economy Parameters:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  _buildReviewItem(context, "Platform Fee", "${provider.platformFee}%"),
                  _buildReviewItem(context, "Author Fee", "${provider.authorFee}%"),
                  _buildReviewItem(context, "Arbitration Fee", "${provider.arbitrationFee}%"),
                  _buildReviewItem(context, "Backer Voting Quorum", "${provider.backerVotingQuorum}%"),
                  _buildReviewItem(context, "Project Creation Threshold", "${provider.projectCreationThreshold} $proposalThresholdTokenSymbol"),
                  _buildReviewItem(context, "Cooling-Off Period", formatDuration(provider.coolingOffPeriod)),
                  _buildReviewItem(context, "Dispute & Appeal Period", formatDuration(provider.disputeAndAppealPeriod)),
                  const SizedBox(height: 25),
                ],

                // Only show members section for non-wrapped tokens
                if (provider.shouldShowMembers && provider.members.isNotEmpty) ...[
                  Text('Initial Members (${provider.members.length}):',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  DataTable(
                    dataRowMinHeight: 30.0,
                    dataRowMaxHeight: 38.0,
                    headingRowHeight: 40,
                    columnSpacing: 15,
                    horizontalMargin: 10,
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Amount')),
                    ],
                    rows: (() {
                      final members = provider.members;
                      final rowCount = members.length;
                      final valueStyle = TextStyle(
                          color: Theme.of(context).indicatorColor,
                          fontWeight: FontWeight.w500);
                      if (rowCount <= 10) {
                        return List<DataRow>.generate(rowCount, (index) {
                          final member = members[index];
                          return DataRow(cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(member.address)),
                            DataCell(
                                Text(member.amount.toString(), style: valueStyle)),
                          ]);
                        });
                      } else {
                        final List<DataRow> displayedRows = [];
                        for (int i = 0; i < 3; i++) {
                          final member = members[i];
                          displayedRows.add(DataRow(cells: [
                            DataCell(Text((i + 1).toString())),
                            DataCell(Text(member.address)),
                            DataCell(Text(member.amount.toString(),
                                style: valueStyle)),
                          ]));
                        }
                        displayedRows.add(DataRow(cells: [
                          DataCell(Text('...', style: valueStyle)),
                          const DataCell(Text('...')),
                          DataCell(Text('...', style: valueStyle)),
                        ]));
                        for (int i = rowCount - 3; i < rowCount; i++) {
                          final member = members[i];
                          displayedRows.add(DataRow(cells: [
                            DataCell(Text((i + 1).toString())),
                            DataCell(Text(member.address)),
                            DataCell(Text(member.amount.toString(),
                                style: valueStyle)),
                          ]));
                        }
                        return displayedRows;
                      }
                    })(),
                  ),
                  const SizedBox(height: 25),
                ],
                
                const Text('Registry Entries:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                DataTable(
                  dataRowMinHeight: 30.0,
                  dataRowMaxHeight: 38.0,
                  headingRowHeight: 40,
                  columnSpacing: 15,
                  horizontalMargin: 10,
                  columns: const [
                    DataColumn(label: Text('Key')),
                    DataColumn(label: Text('Value')),
                  ],
                  rows: provider.registry.isEmpty
                      ? [
                          DataRow(cells: [
                            const DataCell(Text("No registry entries")),
                            DataCell(Text("-",
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor))),
                          ])
                        ]
                      : provider.registry.entries.map((entry) {
                          return DataRow(cells: [
                            DataCell(Text(entry.key)),
                            DataCell(Text(entry.value,
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor,
                                    fontWeight: FontWeight.w500))),
                          ]);
                        }).toList(),
                ),
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: provider.previousStep,
                        child: const Text('< Back')),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              createMaterialColor(
                                  Theme.of(context).indicatorColor))),
                      onPressed: provider.deployDao,
                      child: const SizedBox(
                          width: 120,
                          height: 45,
                          child: Center(
                              child: Text('Deploy',
                                  style: TextStyle(
                                      fontSize: 19, color: Colors.black)))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// lib/src/features/dao_creator/screens/screen7_review.dart