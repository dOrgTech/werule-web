// lib/src/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart' as web3;
import 'package:werule/src/models/network.dart';
import '../services/blockchain_service.dart';

class AuthProvider extends ChangeNotifier {
  // REMOVED: The NetworkProvider dependency is gone.
  final BlockchainService _blockchainService;

  // State
  bool _isLoading = false;
  bool _isAutoConnecting = true;
  List<String> _accounts = [];
  String? _selectedAccount;
  int? _chainId;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAutoConnecting => _isAutoConnecting;
  bool get isConnected => _accounts.isNotEmpty;
  List<String> get accounts => _accounts;
  String? get selectedAccount => _selectedAccount;
  int? get chainId => _chainId;
  bool get isWalletAvailable => _blockchainService.isWalletAvailable();

  // Constructor is simplified
  AuthProvider(this._blockchainService) {
    if (_blockchainService.isWalletAvailable()) {
      _autoConnect();
      _blockchainService.onAccountsChanged((_) => _syncStateWithWallet());
      _blockchainService.onChainChanged((_) => _syncStateWithWallet());
    } else {
      _isAutoConnecting = false;
    }
  }

  // --- Public Methods ---

  Future<void> connectWallet() async {
    if (!_blockchainService.isWalletAvailable()) return;
    _isLoading = true;
    notifyListeners();
    await _blockchainService.connect();
    await _syncStateWithWallet();
    _isLoading = false;
    notifyListeners();
  }

  void selectAccount(String? account) {
    if (account != null && _accounts.contains(account)) {
      _selectedAccount = account;
      notifyListeners();
    }
  }

  // This method is now only responsible for interacting with the wallet
  Future<void> switchWalletChain(Network network) async {
    try {
      await _blockchainService.switchChain(network.chainId);
    } on web3.EthereumException catch (e) {
      if (e.code == 4902) { // Unrecognized Chain ID
        try {
          await _blockchainService.addChain(network);
        } catch (addError) {
          // User rejected adding the network.
        }
      }
    }
  }

  // --- State Synchronization ---

  Future<void> _syncStateWithWallet() async {
    final newAccounts = await _blockchainService.getAccounts();
    final newChainId = await _blockchainService.getChainId();

    _accounts = newAccounts;
    _chainId = newChainId;

    if (newAccounts.isEmpty) {
      _selectedAccount = null;
    } else {
      if (!_accounts.contains(_selectedAccount)) {
        _selectedAccount = _accounts.first;
      }
    }
    
    // REMOVED: The direct call to networkProvider is gone.
    notifyListeners();
  }

  Future<void> _autoConnect() async {
    await _syncStateWithWallet();
    _isAutoConnecting = false;
  }
}
// lib/src/providers/auth_provider.dart