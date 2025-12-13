// Local test configuration for development with Hardhat node
// Mirrors trustless_new's local_test_config.dart

class LocalTestConfig {
  // Singleton pattern
  static final LocalTestConfig _instance = LocalTestConfig._internal();
  factory LocalTestConfig() => _instance;
  LocalTestConfig._internal();

  // ============================================================
  // TOGGLE THIS FOR LOCAL DEVELOPMENT
  // Set to true to use local Hardhat node + Firestore emulator
  // Set to false for production (Etherlink networks)
  // ============================================================
  static const bool enabled = true;  // <-- CHANGE THIS TO ENABLE/DISABLE LOCAL MODE

  // Hardhat local node
  static const String rpcUrl = 'http://127.0.0.1:8545';
  static const int chainId = 31337;
  static const String networkName = 'Localhost';
}
