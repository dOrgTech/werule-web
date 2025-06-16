import 'package:flutter/material.dart';

class BridgeScreenPlaceholder extends StatelessWidget {
  const BridgeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 50, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Bridge Functionality - Coming Soon!',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}