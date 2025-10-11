// lib/src/features/dao_detail/tabs/overview_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:werule/src/features/dao_detail/widgets/dao_treasury_widget.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/utils/proposal_status_helper.dart';
import 'package:werule/src/utils/reusable.dart';

class OverviewTab extends StatelessWidget {
  final Org dao;
  final List<Proposal> proposals;

  const OverviewTab({
    super.key,
    required this.dao,
    required this.proposals,
  });

  @override
  Widget build(BuildContext context) {
    int activeProposals = 0;
    int awaitingExecution = 0;

    for (var p in proposals) {
      final status = ProposalStatusHelper.calculateDisplayStatus(p, dao);
      if (status == ProposalStatus.Active) {
        activeProposals++;
      } else if (status == ProposalStatus.Queued ||
          status == ProposalStatus.Executable) {
        awaitingExecution++;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildMetrics(context, activeProposals, awaitingExecution),
          const SizedBox(height: 16),
          DaoTreasuryWidget(dao: dao),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: const Color(0xff2c2c2c),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            if (isWide) {
              return _buildWideHeader(context);
            } else {
              return _buildTallHeader(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:38.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _DaoAvatar(dao: dao),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(dao.name,
                          style: Theme.of(context).textTheme.headlineMedium),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: "DAO Settings",
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => _DaoConfigModal(org: dao),
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _AddressLine(
                  label: 'Treasury',
                  address: dao.registryAddress,
                  isShort: false),
              _AddressLine(
                  label: '${dao.symbol} Token',
                  address: dao.govTokenAddress,
                  isShort: false),
            ],
          ),
        ),
        const SizedBox(width: 24),
        
        Flexible(
          flex: 2,
          child: Text(
            dao.description,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], height: 1.5),
          ),
        ), const SizedBox(width: 44),
      ],
    );
  }

  Widget _buildTallHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _DaoAvatar(dao: dao),
            const SizedBox(width: 16),
            Flexible(
              child: Text(dao.name,
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: "DAO Settings",
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _DaoConfigModal(org: dao),
              ),
              splashRadius: 20,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _AddressLine(
            label: 'Treasury', address: dao.registryAddress, isShort: true),
        _AddressLine(
            label: '${dao.symbol} Token',
            address: dao.govTokenAddress,
            isShort: true),
        const SizedBox(height: 24),
        Text(
          dao.description,
          style: TextStyle(color: Colors.grey[400], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildMetrics(
      BuildContext context, int activeProposals, int awaitingExecution) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _MetricBox(
          value: formatTotalSupply(dao.totalSupply, dao.decimals),
          label: 'Total\nVoting Power',
        ),
        _MetricBox(
          value: dao.holders.toString(),
          label: 'Members',
        ),
        _MetricBox(
          value: activeProposals.toString(),
          label: 'Active\nProposals',
        ),
        _MetricBox(
          value: awaitingExecution.toString(),
          label: 'Proposals Awaiting\nExecution',
        ),
      ],
    );
  }
}

class _DaoAvatar extends StatelessWidget {
  final Org dao;
  const _DaoAvatar({required this.dao});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: FutureBuilder<Uint8List>(
        future: generateAvatarAsync(hashString(dao.address)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8.0),
              ),
            );
          }
          if (snapshot.hasData) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.memory(snapshot.data!),
            );
          }
          return const SizedBox(width: 60, height: 60);
        },
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  final String label;
  final String address;
  final bool isShort;

  const _AddressLine({
    required this.label,
    required this.address,
    required this.isShort,
  });

  @override
  Widget build(BuildContext context) {
    final displayAddress = isShort ? shortenString(address) : address;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$label: ',
            style: const TextStyle(fontSize: 13, color: Colors.white70)),
        Flexible(
          child: Text(
            displayAddress,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy_outlined, size: 16),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: address));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Center(child: Text('Address copied to clipboard')),
                duration: Duration(seconds: 1),
              ),
            );
          },
          splashRadius: 20,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal:8),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String value;
  final String label;

  const _MetricBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xff2c2c2c),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 54.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).indicatorColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Text(
              label,
              style:
                  TextStyle(fontSize: 16, color: Colors.grey[300], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaoConfigModal extends StatelessWidget {
  final Org org;
  const _DaoConfigModal({required this.org});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff2c2c2c),
      title: const Text('DAO Configuration'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Proposal Lifecycle",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildConfigRow('Voting Delay', '${org.votingDelay} minutes'),
            _buildConfigRow('Voting Period', '${org.votingDuration} minutes'),
            _buildConfigRow('Execution Delay', '${org.executionDelay} seconds'),
            const SizedBox(height: 24),
            const Text("Governance Settings",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildConfigRow('Proposal Threshold',
                '${formatTotalSupply(org.proposalThreshold, org.decimals)} ${org.symbol}'),
            _buildConfigRow('Quorum', '${org.quorum}%'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
// lib/src/features/dao_detail/tabs/overview_tab.dart