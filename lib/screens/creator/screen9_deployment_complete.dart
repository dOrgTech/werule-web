// lib/screens/creator/screen9_deployment_complete.dart
import 'package:flutter/material.dart';

// Screen 9: Deployment Complete
class Screen9DeploymentComplete extends StatelessWidget {
  final String daoName;
  final VoidCallback onGoToDAO;
  Screen9DeploymentComplete({required this.daoName, required this.onGoToDAO});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Deployment Complete!',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 60),
          ElevatedButton(onPressed: onGoToDAO, child: const Text('Go to DAO')),
        ],
      ),
    );
  }
}
// lib/screens/creator/screen9_deployment_complete.dart
