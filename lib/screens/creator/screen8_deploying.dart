// lib/screens/creator/screen8_deploying.dart
import 'package:flutter/material.dart';
import '../../entities/human.dart'; // For Human().chain.name

// Screen 8: Deploying
class Screen8Deploying extends StatelessWidget {
  final String daoName;
  const Screen8Deploying({super.key, required this.daoName});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
              height: 100, width: 100, child: CircularProgressIndicator()),
          const SizedBox(height: 50),
          Text('Deploying $daoName to the ${Human().chain.name} blockchain...'),
        ],
      ),
    );
  }
}
// lib/screens/creator/screen8_deploying.dart
