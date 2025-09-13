// lib/src/features/dao_detail/tabs/registry_tab.dart
import 'package:flutter/material.dart';

class RegistryTab extends StatelessWidget {
  const RegistryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Registry Coming Soon',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
// lib/src/features/dao_detail/tabs/registry_tab.dart