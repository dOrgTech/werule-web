// lib/src/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart' as web3;
import 'package:werule/src/models/network.dart';
import '../services/blockchain_service.dart';

class AuthProvider extends ChangeNotifier {
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

  Future<void> switchWalletChain(Network network) async {
    try {
      await _blockchainService.switchChain(network.chainId);
    } on web3.EthereumException catch (e) {
      if (e.code == 4902) { 
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

    // THE FIX: Proactively sync the selected account with the wallet's active account.
    // The active account is always the first one in the list returned by the wallet.
    if (newAccounts.isEmpty) {
      _selectedAccount = null;
    } else {
      // If the list isn't empty, always set our app's selected account
      // to the first one, which reflects the active account in the wallet.
      _selectedAccount = _accounts.first;
    }
    
    notifyListeners();
  }

  Future<void> _autoConnect() async {
    await _syncStateWithWallet();
    _isAutoConnecting = false;
  }
}
// lib/src/providers/auth_provider.dart