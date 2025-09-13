// lib/src/providers/treasury_provider.dart
import 'package:flutter/material.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/token.dart';
import 'package:werule/src/models/token_asset.dart';
import 'package:werule/src/providers/dao_provider.dart'; // For DataState
import 'package:werule/src/services/treasury_service.dart';

class TreasuryProvider extends ChangeNotifier {
  final TreasuryService _treasuryService;
  final Org _org;
  final Network _network;

  TreasuryProvider(this._treasuryService, this._org, this._network) {
    fetchTreasury();
  }

  DataState _state = DataState.initial;
  DataState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<TokenAsset> _tokenAssets = [];
  List<TokenAsset> get tokenAssets => _tokenAssets;
  
  Future<void> fetchTreasury() async {
    _state = DataState.loading;
    notifyListeners();

    try {
      final String registryAddress = _org.registryAddress;

      if (registryAddress.isEmpty) {
        _errorMessage = "DAO ${_org.name} has no registry address in Firestore model.";
        print(_errorMessage);
        _tokenAssets = [];
        _state = DataState.error;
        notifyListeners();
        return;
      }
      
      final assets = <TokenAsset>[];
      
      // 1. Fetch Native Balance using the network's RPC URL.
      final nativeBalance = await _treasuryService.getNativeBalance(registryAddress, _network.rpcUrl);
      final nativeToken = Token(
        name: _network.nativeCurrencyName,
        symbol: _network.nativeCurrencySymbol,
        decimals: 18,
        type: 'NATIVE',
        address: 'native',
      );
      assets.add(TokenAsset(token: nativeToken, balance: nativeBalance.toString()));

      // 2. Fetch ERC-20 Balances using the network's Block Explorer URL.
      final tokenBalancesData = await _treasuryService.getTokenBalances(registryAddress, _network.blockExplorerUrl);
      
      for (var item in tokenBalancesData) {
        final tokenData = item['token'];
        if (tokenData != null && tokenData['type'] == 'ERC-20') {
           final token = Token(
              name: tokenData['name'] ?? 'Unknown Token',
              symbol: tokenData['symbol'] ?? '???',
              decimals: int.tryParse(tokenData['decimals']?.toString() ?? '0') ?? 0,
              type: tokenData['type'],
              address: tokenData['address_hash'] 
           );
           final balance = item['value']?.toString() ?? '0';
           assets.add(TokenAsset(token: token, balance: balance));
        }
      }

      _tokenAssets = assets;
      _state = DataState.loaded;

    } catch(e) {
      _errorMessage = e.toString();
      _state = DataState.error;
    }
    notifyListeners();
  }
}
// lib/src/providers/treasury_provider.dart