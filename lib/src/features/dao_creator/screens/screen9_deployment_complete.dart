// lib/src/features/dao_creator/screens/screen9_deployment_complete.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';

class Screen9DeploymentComplete extends StatelessWidget {
  final DaoCreatorProvider provider;
  final VoidCallback onGoToDAO;
  const Screen9DeploymentComplete(
      {super.key, required this.provider, required this.onGoToDAO});
      
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
          const SizedBox(height: 50),
          Text('DAO Deployed & Indexed!',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: onGoToDAO, 
            child: const Text('Go to DAO')
          ),
        ],
      ),
    );
  }
}