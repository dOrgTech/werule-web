// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/dao_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/routing/app_router.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/services/treasury_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<BlockchainService>(create: (_) => BlockchainService()),
        Provider<TreasuryService>(create: (_) => TreasuryService()),

        // Independent Providers
        ChangeNotifierProvider<NetworkProvider>(
          create: (context) => NetworkProvider(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<BlockchainService>()),
        ),

        // Dependent Providers
        ChangeNotifierProxyProvider<NetworkProvider, DaoProvider>(
          create: (context) => DaoProvider(context.read<FirestoreService>(), null),
          update: (context, networkProvider, previousDaoProvider) => DaoProvider(
            context.read<FirestoreService>(),
            networkProvider.selectedNetwork,
          ),
        ),
      ],
      // SWITCH TO MaterialApp.router
      child: MaterialApp.router(
        title: 'WeRule Refactored',
        theme: ThemeData.dark(),
        routerConfig: appRouter, // Use the router configuration
      ),
    );
  }
}
// lib/main.dart