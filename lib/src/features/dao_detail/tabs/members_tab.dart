// lib/src/features/dao_detail/tabs/members_tab.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_detail/widgets/dao_members_widget.dart';
import 'package:werule/src/models/org.dart';

class MembersTab extends StatelessWidget {
  final Org dao;
  const MembersTab({super.key, required this.dao});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: DaoMembersWidget(dao: dao),
    );
  }
}
// lib/src/features/dao_detail/tabs/members_tab.dart