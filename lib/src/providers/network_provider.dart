// lib/src/providers/network_provider.dart

import 'package:flutter/material.dart';
import '../models/network.dart';
import '../services/firestore_service.dart';

class NetworkProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  NetworkProvider(this._firestoreService) {
    fetchNetworks();
  }

  List<Network> _networks = [];
  List<Network> get networks => _networks;

  Network? _selectedNetwork;
  Network? get selectedNetwork => _selectedNetwork;

  // A getter for the default network, used by the router for root redirects.
  Network? get defaultNetwork => _networks.isNotEmpty ? _networks.first : null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchNetworks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _networks = await _firestoreService.getNetworks();
      // On initial fetch, if no network is selected, set the default one.
      if (_networks.isNotEmpty && _selectedNetwork == null) {
        _selectedNetwork = _networks.first;
      }
    } catch (e) {
      print("Error in NetworkProvider: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectNetwork(Network? newNetwork) {
    if (newNetwork != null && _selectedNetwork != newNetwork) {
      _selectedNetwork = newNetwork;
      notifyListeners();
    }
  }

  bool isChainSupported(int chainId) {
    return _networks.any((network) => network.chainId == chainId);
  }

  void selectNetworkByChainId(int chainId) {
    if (isChainSupported(chainId)) {
      final newNetwork = _networks.firstWhere((n) => n.chainId == chainId);
      selectNetwork(newNetwork);
    }
  }

  // Selects a network by its name (from the URL).
  void selectNetworkByName(String name) {
    try {
      // Find the network where the name matches.
      final network = _networks.firstWhere((n) => n.name == name);
      selectNetwork(network);
    } catch (e) {
      // If the network name from the URL is invalid, fall back to the default network.
      selectNetwork(defaultNetwork);
    }
  }
}
// lib/src/providers/network_provider.dart