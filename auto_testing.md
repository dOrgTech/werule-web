
  ---
  Architecture Overview

  ┌─────────────────────────────────────────────────────────┐
  │                    TEST ORCHESTRATION                    │
  │  (Master script that starts everything in correct order) │
  └─────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
  │  Hardhat    │    │  Firestore  │    │   Indexer   │
  │  Node       │───▶│  Emulator   │◀───│  (Python)   │
  │ :8545       │    │  :8080      │    │             │
  └─────────────┘    └─────────────┘    └─────────────┘
                              ▲
                              │
                      ┌───────┴────────┐
                      │   Flutter Web  │
                      │   :3000 (dev)  │
                      └────────────────┘
                              ▲
                              │
                      ┌───────┴────────┐
                      │  Flutter Test  │
                      │  Framework     │
                      └────────────────┘

  ---
  Web App Configuration Checklist

  1. Environment Configuration

  Create a config file in your Flutter app (e.g., lib/config/environment.dart):

  enum Environment { local, staging, production }

  class AppConfig {
    static Environment currentEnv = Environment.local; // Easy toggle!

    static String get rpcUrl {
      switch (currentEnv) {
        case Environment.local:
          return 'http://127.0.0.1:8545';  // Hardhat node
        case Environment.staging:
          return 'https://node.ghostnet.etherlink.com';
        case Environment.production:
          return 'https://node.mainnet.etherlink.com';
      }
    }

    static FirebaseOptions get firebaseOptions {
      switch (currentEnv) {
        case Environment.local:
          return FirebaseOptions(
            apiKey: 'demo-key',  // Emulator doesn't validate
            projectId: 'demo-project',
            messagingSenderId: '',
            appId: 'demo-app',
          );
        case Environment.staging:
          return FirebaseOptions(...); // Your staging config
        case Environment.production:
          return FirebaseOptions(...); // Your prod config
      }
    }

    static bool get useFirebaseEmulator => currentEnv == Environment.local;

    static String get firestoreEmulatorHost => '127.0.0.1';
    static int get firestoreEmulatorPort => 8080;
  }

  2. Firestore Emulator Connection

  In your Firebase initialization (e.g., main.dart):

  import 'package:cloud_firestore/cloud_firestore.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: AppConfig.firebaseOptions,
    );

    // Connect to Firestore emulator in local mode
    if (AppConfig.useFirebaseEmulator) {
      FirebaseFirestore.instance.useFirestoreEmulator(
        AppConfig.firestoreEmulatorHost,
        AppConfig.firestoreEmulatorPort,
      );
      print('🔥 Connected to Firestore emulator at ${AppConfig.firestoreEmulatorHost}:${AppConfig.firestoreEmulatorPort}');
    }

    runApp(MyApp());
  }

  3. Hardcoded Test Wallet

  Create a test wallet provider (e.g., lib/services/test_wallet.dart):

  import 'package:web3dart/web3dart.dart';

  class TestWallet {
    // Hardhat's first test account (PUBLICLY KNOWN - NEVER USE ON MAINNET!)
    static const String testPrivateKey =
        '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

    static const String testAddress =
        '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';

    static EthPrivateKey get credentials =>
        EthPrivateKey.fromHex(testPrivateKey);

    static EthereumAddress get address =>
        EthereumAddress.fromHex(testAddress);

    static bool get isTestMode => AppConfig.currentEnv == Environment.local;
  }

  4. Wallet Connection Abstraction

  Create a wallet service that switches between test and real wallet:

  class WalletService {
    EthereumAddress? _connectedAddress;
    EthPrivateKey? _credentials;

    Future<bool> connect() async {
      if (TestWallet.isTestMode) {
        // Use hardcoded test wallet
        _credentials = TestWallet.credentials;
        _connectedAddress = TestWallet.address;
        print('✅ Connected test wallet: ${_connectedAddress!.hex}');
        return true;
      } else {
        // Use real MetaMask/WalletConnect
        return await _connectRealWallet();
      }
    }

    Future<bool> _connectRealWallet() async {
      // Your existing MetaMask/WalletConnect logic
      // ...
    }

    Future<String> signTransaction(Transaction tx) async {
      if (TestWallet.isTestMode) {
        // Sign with test credentials
        final web3 = Web3Client(AppConfig.rpcUrl, Client());
        return await web3.sendTransaction(
          _credentials!,
          tx,
          chainId: 128123, // Etherlink testnet chain ID
        );
      } else {
        // Use MetaMask/WalletConnect
        return await _signRealTransaction(tx);
      }
    }
  }

  ---
  Flutter Testing Framework Recommendations

  Option 1: integration_test (Official, Recommended)

  Pros:
  - Official Flutter package
  - Works with Flutter web
  - Supports headless Chrome for CI/CD
  - Can drive actual app interactions

  Setup:

  # pubspec.yaml
  dev_dependencies:
    integration_test:
      sdk: flutter
    flutter_test:
      sdk: flutter

  Example Test:

  // integration_test/e2e_test.dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:integration_test/integration_test.dart';
  import 'package:your_app/main.dart' as app;
  import 'package:your_app/config/environment.dart';

  void main() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    group('E2E DAO Creation Flow', () {
      testWidgets('Create DAO and verify in Firestore', (tester) async {
        // Force local environment
        AppConfig.currentEnv = Environment.local;

        // Start app
        app.main();
        await tester.pumpAndSettle();

        // Connect wallet (will use test wallet automatically)
        await tester.tap(find.text('Connect Wallet'));
        await tester.pumpAndSettle();

        // Navigate to DAO creation
        await tester.tap(find.byKey(Key('create_dao_button')));
        await tester.pumpAndSettle();

        // Fill form
        await tester.enterText(find.byKey(Key('dao_name_field')), 'Test DAO');
        await tester.enterText(find.byKey(Key('dao_symbol_field')), 'TDAO');

        // Submit transaction
        await tester.tap(find.text('Deploy DAO'));
        await tester.pumpAndSettle(Duration(seconds: 5)); // Wait for tx

        // Verify success message
        expect(find.text('DAO Created Successfully'), findsOneWidget);

        // Verify in Firestore (need to add helper)
        final daoExists = await verifyDaoInFirestore('Test DAO');
        expect(daoExists, true);
      });
    });
  }

  Run command:
  flutter test integration_test/e2e_test.dart --dart-define=FLUTTER_WEB_USE_SKIA=false

  Option 2: Patrol (Advanced, Better Debugging)

  Pros:
  - Better logging and debugging
  - Native automation support
  - Hot restart during test development
  - Better selector options

  Setup:

  # pubspec.yaml
  dev_dependencies:
    patrol: ^2.0.0

  Example:

  import 'package:patrol/patrol.dart';

  void main() {
    patrolTest('Create DAO flow', ($) async {
      await $.pumpWidgetAndSettle(MyApp());

      // Patrol has better selectors
      await $(#connectWalletButton).tap();
      await $(#createDaoButton).tap();

      await $(#daoNameField).enterText('Test DAO');
      await $(#deployButton).tap();

      // Better waiting
      await $.waitUntilVisible($(#successMessage));
    });
  }

  ---
  Test Orchestration Script

  Create test_framework.sh:

  #!/bin/bash
  # Complete E2E test orchestration

  set -e  # Exit on error

  echo "=================================================="
  echo "  HOMEBASE E2E TEST FRAMEWORK"
  echo "=================================================="

  # Colors for output
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m' # No Color

  # Step 1: Kill any existing processes
  echo -e "\n${YELLOW}[1/7] Cleaning up existing processes...${NC}"
  pkill -f "hardhat node" 2>/dev/null || true
  pkill -f "firebase emulators" 2>/dev/null || true
  pkill -f "python.*app.py" 2>/dev/null || true
  pkill -f "flutter run" 2>/dev/null || true
  sleep 2
  echo -e "${GREEN}✓ Cleanup complete${NC}"

  # Step 2: Start Hardhat node
  echo -e "\n${YELLOW}[2/7] Starting Hardhat node...${NC}"
  cd homebase-evm-contracts
  npx hardhat node > /tmp/hardhat.log 2>&1 &
  HARDHAT_PID=$!
  cd ..
  sleep 3

  # Verify Hardhat is running
  if curl -s http://127.0.0.1:8545 > /dev/null; then
      echo -e "${GREEN}✓ Hardhat node running on :8545${NC}"
  else
      echo -e "${RED}✗ Hardhat node failed to start!${NC}"
      cat /tmp/hardhat.log
      exit 1
  fi

  # Step 3: Deploy contracts
  echo -e "\n${YELLOW}[3/7] Deploying contracts...${NC}"
  cd homebase-evm-contracts
  npx hardhat run scripts/deploy.js --network localhost > /tmp/deploy.log 2>&1
  if [ $? -eq 0 ]; then
      echo -e "${GREEN}✓ Contracts deployed${NC}"
      # Show deployed addresses
      grep "deployed at:" /tmp/deploy.log
  else
      echo -e "${RED}✗ Contract deployment failed!${NC}"
      cat /tmp/deploy.log
      exit 1
  fi
  cd ..

  # Step 4: Start Firestore emulator
  echo -e "\n${YELLOW}[4/7] Starting Firestore emulator...${NC}"
  cd indexer
  firebase emulators:start --only firestore > /tmp/firestore.log 2>&1 &
  FIRESTORE_PID=$!
  cd ..
  sleep 5

  # Verify Firestore is running
  if curl -s http://127.0.0.1:8080 > /dev/null 2>&1; then
      echo -e "${GREEN}✓ Firestore emulator running on :8080${NC}"
  else
      echo -e "${RED}✗ Firestore emulator failed to start!${NC}"
      cat /tmp/firestore.log
      exit 1
  fi

  # Step 5: Initialize Firestore with contract addresses
  echo -e "\n${YELLOW}[5/7] Initializing Firestore...${NC}"
  cd indexer
  python -c "
  import firebase_admin
  from firebase_admin import credentials, firestore
  import json

  # Connect to emulator
  import os
  os.environ['FIRESTORE_EMULATOR_HOST'] = '127.0.0.1:8080'

  # Initialize without credentials for emulator
  firebase_admin.initialize_app()
  db = firestore.client()

  # Read deployed addresses from config.js (you'll need to parse this)
  # For now, hardcode the wrapper address from deploy output
  wrapper_address = '0x04C89607413713Ec9775E14b954286519d836FEf'  # Example

  # Create contracts document
  db.collection('contracts').document('localhost').set({
      'wrapper_jurisdiction': wrapper_address,
      'wrapper_w': '0x0000000000000000000000000000000000000000',  # If you have it
  })

  # Create networks document
  db.collection('networks').document('localhost').set({
      'rpc': 'http://127.0.0.1:8545',
      'fromBlock': 0,
      'lastSyncedBlock': 0,
  })

  print('✓ Firestore initialized')
  "
  cd ..

  # Step 6: Start indexer
  echo -e "\n${YELLOW}[6/7] Starting indexer...${NC}"
  cd indexer
  python -u app.py localhost homebase > /tmp/indexer.log 2>&1 &
  INDEXER_PID=$!
  cd ..
  sleep 5

  # Verify indexer is running
  if ps -p $INDEXER_PID > /dev/null; then
      echo -e "${GREEN}✓ Indexer running (PID: $INDEXER_PID)${NC}"
      # Show first few lines of indexer output
      head -10 /tmp/indexer.log
  else
      echo -e "${RED}✗ Indexer failed to start!${NC}"
      cat /tmp/indexer.log
      exit 1
  fi

  # Step 7: Run Flutter tests
  echo -e "\n${YELLOW}[7/7] Running Flutter integration tests...${NC}"
  cd web-app  # Your Flutter app directory
  flutter test integration_test/e2e_test.dart \
      --dart-define=FLUTTER_WEB_USE_SKIA=false \
      --reporter expanded

  TEST_RESULT=$?

  # Cleanup
  echo -e "\n${YELLOW}Cleaning up processes...${NC}"
  kill $HARDHAT_PID $FIRESTORE_PID $INDEXER_PID 2>/dev/null || true

  if [ $TEST_RESULT -eq 0 ]; then
      echo -e "\n${GREEN}=================================================="
      echo -e "  ✓ ALL TESTS PASSED!"
      echo -e "==================================================${NC}"
      exit 0
  else
      echo -e "\n${RED}=================================================="
      echo -e "  ✗ TESTS FAILED!"
      echo -e "==================================================${NC}"
      echo -e "\nLogs available at:"
      echo -e "  Hardhat:   /tmp/hardhat.log"
      echo -e "  Firestore: /tmp/firestore.log"
      echo -e "  Indexer:   /tmp/indexer.log"
      exit 1
  fi

  ---
  Additional Recommendations

  1. Contract Address Management

  After deploying contracts, automatically update your Flutter config:

  # In deploy script, write addresses to JSON
  echo '{"dao":"0x...","wrapper":"0x..."}' > ../web-app/assets/local_contracts.json

  Then load in Flutter:
  final contractsJson = await rootBundle.loadString('assets/local_contracts.json');
  final contracts = json.decode(contractsJson);

  2. Test Data Fixtures

  Create reusable test data:

  class TestFixtures {
    static const testMember1 = '0x70997970C51812dc3A010C7d01b50e0d17dc79C8';
    static const testMember2 = '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC';

    static Map<String, dynamic> sampleDAO() => {
      'name': 'Test DAO ${DateTime.now().millisecondsSinceEpoch}',
      'symbol': 'TDAO',
      'members': [testMember1, testMember2],
      'amounts': ['1000', '500'],
    };
  }

  3. Firestore Verification Helper

  Future<bool> verifyDaoInFirestore(String daoName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('homebase')
        .collection('localhost')
        .where('name', isEqualTo: daoName)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  4. CI/CD Integration

  For GitHub Actions:

  # .github/workflows/e2e-test.yml
  name: E2E Tests
  on: [push, pull_request]

  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3

        - uses: actions/setup-node@v3
          with:
            node-version: '18'

        - uses: subosito/flutter-action@v2
          with:
            flutter-version: '3.16.0'

        - name: Install dependencies
          run: |
            cd homebase-evm-contracts && npm install
            cd ../indexer && pip install -r requirements.txt
            cd ../web-app && flutter pub get

        - name: Run E2E tests
          run: bash test_framework.sh

  ---
  Gotchas & Tips

  1. CORS Issues: If Flutter web can't connect to Hardhat, start it with:
  npx hardhat node --hostname 0.0.0.0
  2. Firestore Emulator Data Persistence: Use --export-on-exit to save data between runs
  3. Transaction Timing: Add generous pumpAndSettle delays after blockchain transactions
  4. Screenshot on Failure: Capture screenshots when tests fail:
  await binding.takeScreenshot('failure_screenshot');
  5. Test Isolation: Clear Firestore between tests:
  await FirebaseFirestore.instance.clearPersistence();

  ---
  This gives you a complete, automated testing pipeline from contract deployment through indexing to UI verification!