// lib/src/features/dao_detail/tabs/account_tab.dart
import 'package:flutter/material.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Account View Coming Soon',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
// lib/src/features/dao_detail/tabs/account_tab.dart