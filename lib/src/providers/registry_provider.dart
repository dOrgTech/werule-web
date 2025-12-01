// lib/src/providers/registry_provider.dart

import 'package:flutter/material.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/registry_item.dart';
import 'package:werule/src/services/registry_service.dart';
import 'package:werule/src/providers/dao_provider.dart'; // For DataState

class RegistryProvider extends ChangeNotifier {
  final RegistryService _registryService;
  final Org _org;
  final Network _network;

  RegistryProvider(this._registryService, this._org, this._network) {
    fetchRegistry();
  }

  DataState _state = DataState.initial;
  DataState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<RegistryItem> _items = [];
  List<RegistryItem> get items => _items;

  Future<void> fetchRegistry() async {
    _state = DataState.loading;
    notifyListeners();

    try {
      final registryAddress = _org.registryAddress;
      if (registryAddress.isEmpty) {
        _items = [];
        _state = DataState.loaded;
        notifyListeners();
        return;
      }

      // Fetch registry from contract (returns Map<String, String>)
      final fetchedRegistry = await _registryService.getRegistryItems(registryAddress, _network.rpcUrl);

      // Convert to List<RegistryItem>
      _items = fetchedRegistry.entries
          .map((entry) => RegistryItem(key: entry.key, value: entry.value))
          .toList();

      _state = DataState.loaded;

    } catch(e) {
      _errorMessage = e.toString();
      _state = DataState.error;
    }
    notifyListeners();
  }
}
// lib/src/providers/registry_provider.dart