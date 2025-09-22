// lib/src/features/dao_creator/screens/screen8_deploying.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';
import 'package:werule/src/providers/network_provider.dart';

class Screen8Deploying extends StatelessWidget {
  final DaoCreatorProvider provider;
  const Screen8Deploying({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final networkName =
        context.watch<NetworkProvider>().selectedNetwork?.name ?? 'blockchain';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
              height: 100, width: 100, child: CircularProgressIndicator()),
          const SizedBox(height: 50),
          Text('Deploying ${provider.daoName} to the $networkName...'),
        ],
      ),
    );
  }
}
// lib/src/features/dao_creator/screens/screen8_deploying.dart