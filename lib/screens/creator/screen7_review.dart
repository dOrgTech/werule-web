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

  Screen7Review({
    required this.daoConfig,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    String formatDuration(Duration? duration) {
      if (duration == null) return 'Not set';
      int days = duration.inDays;
      int hours = duration.inHours % 24;
      int minutes = duration.inMinutes % 60;
      return '$days days, $hours hours, $minutes minutes';
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${daoConfig.daoName}',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text('On-Chain Organization'),
              const SizedBox(height: 20),
              Container(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Text('${daoConfig.daoDescription}')),
              const SizedBox(height: 10),
              if (daoConfig.tokenDeploymentMechanism ==
                  DaoTokenDeploymentMechanism.deployNewStandardToken) ...[
                Text('Ticker Symbol: ${daoConfig.tokenSymbol ?? "N/A"}'),
                Text(
                    'Number of Decimals: ${daoConfig.numberOfDecimals?.toString() ?? "N/A"}'),
                Text(
                    'Non-Transferable: ${daoConfig.nonTransferrable ? 'Yes' : 'No'}'),
              ] else ...[
                Text('Deployment Type: Wrap Existing Token'),
                Text(
                    'Underlying Token Address: ${daoConfig.underlyingTokenAddress ?? "N/A"}'),
                Text(
                    'Wrapped Token Name: ${daoConfig.wrappedTokenName ?? "N/A"}'),
                Text(
                    'Wrapped Token Symbol: ${daoConfig.wrappedTokenSymbol ?? "N/A"}'),
                Text('(Decimals will match underlying token)'),
              ],
              const SizedBox(height: 30),
              Text('Quorum Threshold: ${daoConfig.quorumThreshold}%'),
              const SizedBox(height: 30),
              Text(
                  'Voting Duration: ${formatDuration(daoConfig.votingDuration)}'),
              const SizedBox(height: 10),
              Text('Voting Delay: ${formatDuration(daoConfig.votingDelay)}'),
              const SizedBox(height: 10),
              Text(
                  'Execution Delay: ${formatDuration(daoConfig.executionDelay)}'),
              const SizedBox(height: 30),
              if (daoConfig.tokenDeploymentMechanism ==
                      DaoTokenDeploymentMechanism.deployNewStandardToken &&
                  daoConfig.members.isNotEmpty) ...[
                Text('${daoConfig.members.length} Members',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: (() {
                    final members = daoConfig.members;
                    final rowCount = members.length;
                    if (rowCount <= 10) {
                      return List<DataRow>.generate(rowCount, (index) {
                        final member = members[index];
                        return DataRow(cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(member.address)),
                          DataCell(Text(member.amount.toString())),
                        ]);
                      });
                    } else {
                      final List<DataRow> displayedRows = [];
                      for (int i = 0; i < 3; i++) {
                        final member = members[i];
                        displayedRows.add(DataRow(cells: [
                          DataCell(Text((i + 1).toString())),
                          DataCell(Text(member.address)),
                          DataCell(Text(member.amount.toString())),
                        ]));
                      }
                      displayedRows.add(DataRow(cells: [
                        const DataCell(Text('...')),
                        const DataCell(Text('...')),
                        const DataCell(Text('...')),
                      ]));
                      for (int i = rowCount - 3; i < rowCount; i++) {
                        final member = members[i];
                        displayedRows.add(DataRow(cells: [
                          DataCell(Text((i + 1).toString())),
                          DataCell(Text(member.address)),
                          DataCell(Text(member.amount.toString())),
                        ]));
                      }
                      return displayedRows;
                    }
                  })(),
                ),
                const SizedBox(height: 30),
              ],
              Text('Registry Entries:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Key')),
                  DataColumn(label: Text('Value')),
                ],
                rows: daoConfig.registry.entries.map((entry) {
                  return DataRow(cells: [
                    DataCell(Text(entry.key)),
                    DataCell(Text(entry.value)),
                  ]);
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: onBack, child: const Text('< Back')),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              createMaterialColor(
                                  Theme.of(context).indicatorColor))),
                      onPressed: onFinish,
                      child: const SizedBox(
                          width: 120,
                          height: 45,
                          child: Center(
                              child: Text('Deploy',
                                  style: TextStyle(fontSize: 19)))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/screens/creator/screen7_review.dart
