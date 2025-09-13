// lib/src/models/network.dart

// Fallback map in case `chainId` is missing from your Firestore documents.
const Map<String, int> knownChainIds = {
  'Etherlink-Testnet': 128123,
  'Etherlink': 42793,
};

class Network {
  final String name;
  final String rpcUrl;
  final String daoFactory;
  final int chainId;
  final String nativeCurrencyName;
  final String nativeCurrencySymbol;
  final String blockExplorerUrl;

  Network({
    required this.name,
    required this.rpcUrl,
    required this.daoFactory,
    required this.chainId,
    required this.nativeCurrencyName,
    required this.nativeCurrencySymbol,
    required this.blockExplorerUrl,
  });

  factory Network.fromFirestore(Map<String, dynamic> data, String docId) {
    return Network(
      name: docId,
      rpcUrl: data['rpc'] ?? '',
      daoFactory: data['daoFactory'] ?? '',
      chainId: data['chainId'] ?? knownChainIds[docId] ?? 0,
      nativeCurrencyName: data['nativeCurrency'] ?? 'ETH', // Fallback
      nativeCurrencySymbol: data['symbol'] ?? 'ETH', // Fallback
      blockExplorerUrl: data['blockExplorer'] ?? '',
    );
  }

  String get daoCollectionName => 'idaos$name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Network && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
// lib/src/models/network.dart