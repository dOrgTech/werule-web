// lib/src/features/dao_detail/tabs/overview_tab.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_detail/widgets/dao_treasury_widget.dart';
import 'package:werule/src/models/org.dart';

class OverviewTab extends StatelessWidget {
  final Org dao;
  const OverviewTab({super.key, required this.dao});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dao.name, style: Theme.of(context).textTheme.headlineMedium),
          Text("Registry: ${dao.registryAddress}",
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Text(dao.description),
          DaoTreasuryWidget(dao: dao),
        ],
      ),
    );
  }
}
// lib/src/features/dao_detail/tabs/overview_tab.dart