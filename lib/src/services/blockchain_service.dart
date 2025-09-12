// lib/src/services/blockchain_service.dart

import 'package:flutter_web3/flutter_web3.dart' as web3;
import '../models/network.dart';

class BlockchainService {
  // THE FIX: A private helper function to reliably parse chain IDs
  // whether they come from the wallet as an int or a hex string.
  int _parseChainId(dynamic chainId) {
    if (chainId is int) {
      return chainId;
    }
    if (chainId is String) {
      return int.parse(
        // Remove '0x' prefix if it exists, then parse as base-16
        chainId.startsWith('0x') ? chainId.substring(2) : chainId,
        radix: 16,
      );
    }
    // As a fallback for any unexpected type, though this shouldn't happen.
    throw FormatException('Cannot parse chainId: $chainId');
  }

  bool isWalletAvailable() {
    return web3.Ethereum.isSupported;
  }

  Future<List<String>> connect() async {
    try {
      final accounts = await web3.ethereum!.requestAccount();
      return accounts.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getAccounts() async {
    try {
      final accounts = await web3.ethereum!.getAccounts();
      return accounts.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<int?> getChainId() async {
    try {
      final dynamic chainId = await web3.ethereum!.getChainId();
      // Apply the parsing function here as well for consistency.
      return _parseChainId(chainId);
    } catch (e) {
      return null;
    }
  }

  Future<void> switchChain(int chainId) async {
    try {
      await web3.ethereum!.walletSwitchChain(chainId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addChain(Network network) async {
    try {
      await web3.ethereum!.walletAddChain(
        chainId: network.chainId,
        chainName: network.name,
        nativeCurrency: web3.CurrencyParams(
          name: network.nativeCurrencyName,
          symbol: network.nativeCurrencySymbol,
          decimals: 18,
        ),
        rpcUrls: [network.rpcUrl],
      );
    } catch (e) {
      rethrow;
    }
  }

  void onAccountsChanged(Function(List<String>) callback) {
    web3.ethereum!.on('accountsChanged', (accounts) {
      callback((accounts as List<dynamic>).cast<String>());
    });
  }

  void onChainChanged(Function(int) callback) {
    web3.ethereum!.on('chainChanged', (chainId) {
      // Apply the parsing function to the event payload before calling the callback.
      // This is the core fix for the crash.
      callback(_parseChainId(chainId));
    });
  }
}
// lib/src/services/blockchain_service.dart