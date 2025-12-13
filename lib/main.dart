// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/config/local_test_config.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/dao_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/routing/app_router.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/calldata_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/services/members_service.dart';
import 'package:werule/src/services/registry_service.dart';
import 'package:werule/src/services/treasury_service.dart';
import 'package:werule/src/utils/theme.dart'; // THE FIX: Import your custom theme.
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Connect to Firestore emulator in local test mode
  if (LocalTestConfig.enabled) {
    debugPrint('[main] Local test mode enabled - connecting to Firestore emulator');
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  }

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
        Provider<MembersService>(create: (_) => MembersService()),
        Provider<CalldataService>(create: (_) => CalldataService()),
        Provider<RegistryService>(create: (_) => RegistryService()),

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
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'WeRule DAO',
        // THE FIX: Use your custom dark theme instead of the default one.
        theme: dark,
        routerConfig: appRouter,
      ),
    );
  }
}
// lib/main.dart