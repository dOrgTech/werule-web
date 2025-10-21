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

  Network? get defaultNetwork => _networks.isNotEmpty ? _networks.first : null;

  bool _isLoading = true; // Start as true since we fetch on creation
  bool get isLoading => _isLoading;

  String? _pendingNetworkName; // THE FIX: Remember the desired network from a deep link.

  Future<void> fetchNetworks() async {
    // Only set loading to true if we are actually fetching for the first time.
    if (_networks.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      _networks = await _firestoreService.getNetworks();
      _networks= _networks.reversed.toList();
      // THE FIX: After loading, check if a network was requested before the list was ready.
      if (_pendingNetworkName != null) {
        final pendingName = _pendingNetworkName!;
        _pendingNetworkName = null; // Clear the pending request.
        selectNetworkByName(pendingName); // Re-run the select logic now that networks exist.
      } 
      // If no pending request was made and no network is selected yet, set the default one.
      else if (_networks.isNotEmpty && _selectedNetwork == null) {
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

  // This method is now safe to be called at any time.
  void selectNetworkByName(String name) {
    // THE FIX: If networks aren't loaded yet, just store the name and wait for fetchNetworks to complete.
    if (_networks.isEmpty) {
      _pendingNetworkName = name;
      return;
    }

    try {
      // If networks are loaded, find and select the network immediately.
      final network = _networks.firstWhere((n) => n.name == name);
      selectNetwork(network);
    } catch (e) {
      // If the network name from the URL is invalid, fall back to the default network.
      print("Could not find network with name '$name', falling back to default.");
      selectNetwork(defaultNetwork);
    }
  }
}
// lib/src/providers/network_provider.dart