// lib/src/services/registry_service.dart

import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:werule/src/services/treasury_abi.dart';

class RegistryService {
  /// Fetches registry items directly from the treasury/registry contract
  /// using the getAllKeys() and getAllValues() functions.
  ///
  /// [treasuryAddress] - The address of the treasury/registry contract
  /// [rpcUrl] - The RPC endpoint URL for the network
  Future<Map<String, String>> getRegistryItems(String treasuryAddress, String rpcUrl) async {
    if (treasuryAddress.isEmpty) {
      return {};
    }

    final client = Web3Client(rpcUrl, http.Client());
    try {
      final contract = DeployedContract(
        TreasuryAbi.abi,
        EthereumAddress.fromHex(treasuryAddress),
      );

      // Call getAllKeys()
      final keysFunction = contract.function('getAllKeys');
      final keysResult = await client.call(
        contract: contract,
        function: keysFunction,
        params: [],
      );
      final List<String> keys = (keysResult[0] as List).cast<String>();

      // Call getAllValues()
      final valuesFunction = contract.function('getAllValues');
      final valuesResult = await client.call(
        contract: contract,
        function: valuesFunction,
        params: [],
      );
      final List<String> values = (valuesResult[0] as List).cast<String>();

      // Build the map
      final Map<String, String> registry = {};
      for (int i = 0; i < keys.length; i++) {
        registry[keys[i]] = values[i];
      }

      return registry;
    } finally {
      await client.dispose();
    }
  }
}
// lib/src/services/registry_service.dart