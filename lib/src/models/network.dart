// lib/src/models/network.dart

// Fallback map in case `chainId` is missing from your Firestore documents.
const Map<String, int> knownChainIds = {
  'Etherlink-Testnet': 128123,
  'Etherlink': 42793,
  'Localhost': 31337,
};


class Network {
  final String name;
  final String rpcUrl;
  final String daoFactory;
  final String wrapper; // Non-transferable token wrapper contract address
  final String wrapperT; // Transferable token wrapper contract address
  final String wrapperW; // Wrapped ERC20 token wrapper contract address
  final String wrapperTrustless; // Economy DAO (Trustless Business) factory address
  final String nativeProjectImpl; // NativeProject implementation for Economy DAOs
  final String erc20ProjectImpl; // ERC20Project implementation for Economy DAOs
  final int chainId;
  final String nativeCurrencyName;
  final String nativeCurrencySymbol;
  final String blockExplorerUrl;

  Network({
    required this.name,
    required this.rpcUrl,
    required this.daoFactory,
    required this.wrapper,
    required this.wrapperT,
    required this.wrapperW,
    required this.wrapperTrustless,
    required this.nativeProjectImpl,
    required this.erc20ProjectImpl,
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
      wrapper: data['wrapper'] ?? '',
      wrapperT: data['wrapper_t'] ?? '',
      wrapperW: data['wrapper_w'] ?? '',
      wrapperTrustless: data['wrapper_trustless'] ?? '',
      nativeProjectImpl: data['nativeProjectImpl'] ?? '',
      erc20ProjectImpl: data['erc20ProjectImpl'] ?? '',
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