// lib/src/providers/dao_provider.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/network.dart';
import '../models/org.dart';
import '../services/firestore_service.dart';

enum DataState { initial, loading, loaded, error }

class DaoProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final Network? _currentNetwork;

  // THE FIX: Add a flag to track the provider's disposal status.
  bool _isDisposed = false;

  DaoProvider(this._firestoreService, this._currentNetwork) {
    fetchDaosForCurrentNetwork();
  }

  // --- State and Getters (Unchanged) ---
  List<Org> _allDaos = [];
  List<Org> _filteredDaos = [];
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 21;
  List<Org> displayedDaos = [];
  DataState _state = DataState.initial;
  DataState get state => _state;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  int get totalDaoCount => _allDaos.length;
  int get currentPage => _currentPage;
  int get totalPages =>
      _filteredDaos.isEmpty ? 1 : (_filteredDaos.length / _itemsPerPage).ceil();

  // --- Methods ---

  Future<void> fetchDaosForCurrentNetwork() async {
    if (_currentNetwork == null) {
      _state = DataState.loaded;
      _allDaos = [];
      _applyFiltersAndPagination();
      return;
    }

    _state = DataState.loading;
    notifyListeners();

    try {
      _allDaos = await _firestoreService.getDaos(_currentNetwork!.daoCollectionName);
      _state = DataState.loaded;
    } catch (e) {
      _state = DataState.error;
      _errorMessage = e.toString();
    }
    
    _searchQuery = '';
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  void search(String query) {
    _searchQuery = query;
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  void changePage(int newPage) {
    if (newPage < 1 || newPage > totalPages) return;
    _currentPage = newPage;
    _applyFiltersAndPagination();
  }

  void _applyFiltersAndPagination() {
    if (_searchQuery.isEmpty) {
      _filteredDaos = List.from(_allDaos);
    } else {
      final lowerCaseQuery = _searchQuery.toLowerCase();
      _filteredDaos = _allDaos.where((dao) {
        return dao.name.toLowerCase().contains(lowerCaseQuery) ||
            dao.address.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }

    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = min(startIndex + _itemsPerPage, _filteredDaos.length);
    
    displayedDaos = (startIndex >= _filteredDaos.length)
        ? []
        : _filteredDaos.sublist(startIndex, endIndex);
    
    notifyListeners();
  }

  // --- Disposal and Notification Logic ---

  // THE FIX: When the ProxyProvider disposes of this instance, we set our flag.
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // THE FIX: We override notifyListeners and only call the original method
  // if this instance has not been disposed.
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}
// lib/src/providers/dao_provider.dart