// lib/screens/creator/screen7_review.dart
import 'package:Homebase/utils/theme.dart'; // For createMaterialColor
import 'package:flutter/material.dart';
import 'creator_utils.dart'; // For DaoTokenDeploymentMechanism
import 'dao_config.dart';

// Screen 7: Review & Deploy
class Screen7Review extends StatelessWidget {
  final DaoConfig daoConfig;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const Screen7Review({super.key, 
    required this.daoConfig,
    required this.onBack,
    required this.onFinish,
  });

  String formatDuration(Duration? duration) {
    if (duration == null) return 'Not set';
    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    if (days == 0 && hours == 0 && minutes == 0) return '0 minutes (Instant)';
    return '$days days, $hours hours, $minutes minutes';
  }

  // Helper for standard review items
  Widget _buildReviewItem(BuildContext context, String label, String valueText, {TextStyle? customValueStyle, bool isDescription = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Standard vertical padding
      child: Row(
        crossAxisAlignment: isDescription ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180, 
            child: Text(
              '$label:',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(width: 12), 
          Expanded(
            child: Text(
              valueText,
              style: customValueStyle ?? TextStyle(
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

  // Helper for token detail items with increased spacing (1.5x of 4.0 = 6.0)
  Widget _buildTokenDetailItem(BuildContext context, String label, String valueText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Increased vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180, 
            child: Text(
              '$label:',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(width: 12), 
          Expanded(
            child: Text(
              valueText,
              style: TextStyle(
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
    String proposalThresholdTokenSymbol = "tokens";
    if (daoConfig.tokenDeploymentMechanism == DaoTokenDeploymentMechanism.deployNewStandardToken) {
      proposalThresholdTokenSymbol = daoConfig.tokenSymbol?.isNotEmpty == true ? daoConfig.tokenSymbol! : "tokens";
    } else {
      proposalThresholdTokenSymbol = daoConfig.wrappedTokenSymbol?.isNotEmpty == true ? daoConfig.wrappedTokenSymbol! : "tokens";
    }

    const double contentMaxWidth = 650.0; // Define a max width for the content area

    return SingleChildScrollView(
      child: Center( // Ensures the SizedBox itself is centered if screen is wider
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38.0, vertical: 20.0),
          child: SizedBox( // Constrains the width of the content Column
            width: contentMaxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start of the SizedBox
              children: [
                Text(daoConfig.daoName ?? "My DAO",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text('On-Chain Organization', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Icon(Icons.security, size: 18, color: Theme.of(context).indicatorColor),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                _buildReviewItem(
                  context,
                  "Description",
                  daoConfig.daoDescription?.isNotEmpty == true ? daoConfig.daoDescription! : "Not provided",
                  isDescription: true, // To allow potentially multi-line description to align nicely
                ),
                const SizedBox(height: 20), // Group spacing

                // Token Details
                if (daoConfig.tokenDeploymentMechanism ==
                    DaoTokenDeploymentMechanism.deployNewStandardToken) ...[
                  _buildTokenDetailItem(context, "Token Type", "New Standard Token"),
                  _buildTokenDetailItem(context, "Ticker Symbol", daoConfig.tokenSymbol ?? "N/A"),
                  _buildTokenDetailItem(context, "Decimals", daoConfig.numberOfDecimals?.toString() ?? "N/A"),
                  _buildTokenDetailItem(context, "Non-Transferable", daoConfig.nonTransferrable ? 'Yes' : 'No'),
                ] else ...[
                  _buildTokenDetailItem(context, "Token Type", "Wrap Existing Token"),
                  _buildTokenDetailItem(context, "Underlying Token", daoConfig.underlyingTokenAddress ?? "N/A"),
                  _buildTokenDetailItem(context, "Wrapped Symbol", daoConfig.wrappedTokenSymbol ?? "N/A"),
                  _buildTokenDetailItem(context, "Decimals", "(Matches Underlying Token)"),
                ],
                const SizedBox(height: 20), // Group spacing

                // Governance Parameters
                _buildReviewItem(context, "Quorum Threshold", "${daoConfig.quorumThreshold}%"),
                _buildReviewItem(context, "Proposal Threshold", "${daoConfig.proposalThreshold ?? 1} $proposalThresholdTokenSymbol"),
                _buildReviewItem(context, "Voting Duration", formatDuration(daoConfig.votingDuration)),
                _buildReviewItem(context, "Voting Delay", formatDuration(daoConfig.votingDelay)),
                _buildReviewItem(context, "Execution Delay", formatDuration(daoConfig.executionDelay)),
                const SizedBox(height: 25), // Group spacing

                // Members Table
                if (daoConfig.tokenDeploymentMechanism ==
                        DaoTokenDeploymentMechanism.deployNewStandardToken &&
                    daoConfig.members.isNotEmpty) ...[
                  Text('Initial Members (${daoConfig.members.length}):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  // DataTable will naturally be constrained by the parent SizedBox
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
                      final members = daoConfig.members;
                      final rowCount = members.length;
                      final valueStyle = TextStyle(color: Theme.of(context).indicatorColor, fontWeight: FontWeight.w500);
                      if (rowCount <= 10) {
                        return List<DataRow>.generate(rowCount, (index) {
                          final member = members[index];
                          return DataRow(cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(member.address)),
                            DataCell(Text(member.amount.toString(), style: valueStyle)),
                          ]);
                        });
                      } else {
                        final List<DataRow> displayedRows = [];
                        for (int i = 0; i < 3; i++) {
                          final member = members[i];
                          displayedRows.add(DataRow(cells: [
                            DataCell(Text((i + 1).toString())),
                            DataCell(Text(member.address)),
                            DataCell(Text(member.amount.toString(), style: valueStyle)),
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
                            DataCell(Text(member.amount.toString(), style: valueStyle)),
                          ]));
                        }
                        return displayedRows;
                      }
                    })(),
                  ),
                  const SizedBox(height: 25), // Group spacing
                ],
                
                // Registry Entries
                const Text('Registry Entries:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                // DataTable will naturally be constrained by the parent SizedBox
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
                  rows: daoConfig.registry.isEmpty 
                  ? [
                      DataRow(cells: [
                        const DataCell(Text("No registry entries")),
                        DataCell(Text("-", style: TextStyle(color: Theme.of(context).indicatorColor))),
                      ])
                    ]
                  : daoConfig.registry.entries.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry.key)),
                      DataCell(Text(entry.value, style: TextStyle(color: Theme.of(context).indicatorColor, fontWeight: FontWeight.w500))),
                    ]);
                  }).toList(),
                ),
                const SizedBox(height: 30),
                
                // Action Buttons
                // Row will take the width of its parent SizedBox (contentMaxWidth)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: onBack, child: const Text('< Back')),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              createMaterialColor(
                                  Theme.of(context).indicatorColor))),
                      onPressed: onFinish,
                      child: const SizedBox(
                          width: 120,
                          height: 45,
                          child: Center(
                              child: Text('Deploy',
                                  style: TextStyle(fontSize: 19, color: Colors.black )))), 
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
// lib/screens/creator/screen7_review.dart