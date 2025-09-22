// lib/src/services/registry_service.dart

import 'package:werule/src/models/registry_item.dart';

class RegistryService {
  // This is a placeholder. In a real app, this would query a block explorer
  // API for events or storage from the registry contract.
  Future<List<RegistryItem>> getRegistryItems(String registryAddress, String blockExplorerUrl) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data
    if (registryAddress.isEmpty) {
      return [];
    }
    return [
      RegistryItem(key: "dao.name", value: "Example DAO Name"),
      RegistryItem(key: "dao.description", value: "This is a longer description for an example decentralized autonomous organization."),
      RegistryItem(key: "website", value: "https://example.com"),
      RegistryItem(key: "documentation", value: "https://docs.example.com/dao-info-and-rules"),
      RegistryItem(key: "external.api.key", value: "0xabc123def456ghi789jkl012mno345pqr678stu901vwx234yz567abc890def123"),
    ];
  }
}
// lib/src/services/registry_service.dart