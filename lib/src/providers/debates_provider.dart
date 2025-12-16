// lib/src/providers/debates_provider.dart

import 'package:flutter/foundation.dart';
import 'package:werule/src/models/debate.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';

/// Provider for managing debates state
class DebatesProvider extends ChangeNotifier {
  final BlockchainService _blockchainService;
  final AuthProvider _authProvider;
  final Org _org;
  final Network _network;
  final String? _debatesFactoryAddress;

  List<DebateListItem> _debates = [];
  Debate? _currentDebate;
  bool _isLoading = false;
  bool _isActionBusy = false;
  String? _error;
  BigInt _userRemainingVotingPower = BigInt.zero;
  BigInt _userTotalVotingPower = BigInt.zero;

  DebatesProvider({
    required BlockchainService blockchainService,
    required AuthProvider authProvider,
    required Org org,
    required Network network,
    String? debatesFactoryAddress,
  })  : _blockchainService = blockchainService,
        _authProvider = authProvider,
        _org = org,
        _network = network,
        _debatesFactoryAddress = debatesFactoryAddress {
    if (_debatesFactoryAddress != null && _debatesFactoryAddress!.isNotEmpty) {
      fetchDebates();
    }
  }

  // Getters
  List<DebateListItem> get debates => _debates;
  Debate? get currentDebate => _currentDebate;
  bool get isLoading => _isLoading;
  bool get isActionBusy => _isActionBusy;
  String? get error => _error;
  BigInt get userRemainingVotingPower => _userRemainingVotingPower;
  BigInt get userTotalVotingPower => _userTotalVotingPower;
  bool get hasDebatesFactory => _debatesFactoryAddress != null && _debatesFactoryAddress!.isNotEmpty;
  String? get debatesFactoryAddress => _debatesFactoryAddress;

  /// Fetches debates list from the factory contract
  Future<void> fetchDebates() async {
    if (_debatesFactoryAddress == null || _debatesFactoryAddress!.isEmpty) {
      _error = "Debates factory not configured for this network";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _debates = await _blockchainService.getDebateListByToken(
        _debatesFactoryAddress!,
        _org.govTokenAddress,
        _network.rpcUrl,
      );
      // Sort by creation date (newest first)
      _debates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = "Failed to fetch debates: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads full debate details
  Future<void> loadDebate(String debateAddress) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentDebate = await _blockchainService.getFullDebate(
        debateAddress,
        _network.rpcUrl,
      );

      // Also fetch user's remaining voting power
      if (_authProvider.selectedAccount != null) {
        _userRemainingVotingPower = await _blockchainService.getDebateRemainingVotingPower(
          debateAddress,
          _authProvider.selectedAccount!,
          _network.rpcUrl,
        );
      }
    } catch (e) {
      _error = "Failed to load debate: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes the current debate
  Future<void> refreshCurrentDebate() async {
    if (_currentDebate == null) return;
    await loadDebate(_currentDebate!.debateAddress);
  }

  /// Creates a new debate
  Future<String?> createDebate({
    required String title,
    required String rootArgument,
    required BigInt rootWeight,
  }) async {
    if (_debatesFactoryAddress == null || _debatesFactoryAddress!.isEmpty) {
      return "Debates factory not configured";
    }

    if (_authProvider.selectedAccount == null) {
      return "Please connect your wallet";
    }

    _isActionBusy = true;
    _error = null;
    notifyListeners();

    try {
      await _blockchainService.createDebate(
        _debatesFactoryAddress!,
        _org.govTokenAddress,
        title,
        rootArgument,
        rootWeight,
        _authProvider.selectedAccount!,
      );

      // Refresh the debates list
      await fetchDebates();
      return null; // Success
    } catch (e) {
      _error = "Failed to create debate: $e";
      debugPrint(_error);
      return _error;
    } finally {
      _isActionBusy = false;
      notifyListeners();
    }
  }

  /// Adds an argument to the current debate
  Future<String?> addArgument({
    required BigInt parentId,
    required ArgumentType argType,
    required BigInt weight,
    required String content,
  }) async {
    if (_currentDebate == null) {
      return "No debate loaded";
    }

    if (_authProvider.selectedAccount == null) {
      return "Please connect your wallet";
    }

    _isActionBusy = true;
    _error = null;
    notifyListeners();

    try {
      await _blockchainService.addDebateArgument(
        _currentDebate!.debateAddress,
        parentId,
        argType,
        weight,
        content,
        _authProvider.selectedAccount!,
      );

      // Refresh the current debate
      await refreshCurrentDebate();
      return null; // Success
    } catch (e) {
      _error = "Failed to add argument: $e";
      debugPrint(_error);
      return _error;
    } finally {
      _isActionBusy = false;
      notifyListeners();
    }
  }

  /// Adds weight to an existing argument
  Future<String?> addWeight({
    required BigInt argumentId,
    required BigInt additionalWeight,
  }) async {
    if (_currentDebate == null) {
      return "No debate loaded";
    }

    if (_authProvider.selectedAccount == null) {
      return "Please connect your wallet";
    }

    _isActionBusy = true;
    _error = null;
    notifyListeners();

    try {
      await _blockchainService.addDebateWeight(
        _currentDebate!.debateAddress,
        argumentId,
        additionalWeight,
        _authProvider.selectedAccount!,
      );

      // Refresh the current debate
      await refreshCurrentDebate();
      return null; // Success
    } catch (e) {
      _error = "Failed to add weight: $e";
      debugPrint(_error);
      return _error;
    } finally {
      _isActionBusy = false;
      notifyListeners();
    }
  }

  /// Fetches user's total voting power for debate creation
  Future<void> fetchUserVotingPower() async {
    if (_authProvider.selectedAccount == null) {
      _userTotalVotingPower = BigInt.zero;
      return;
    }

    try {
      _userTotalVotingPower = await _blockchainService.getVotes(
        _org.govTokenAddress,
        _authProvider.selectedAccount!,
        _network.rpcUrl,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch voting power: $e");
      _userTotalVotingPower = BigInt.zero;
    }
  }

  /// Clears the current debate
  void clearCurrentDebate() {
    _currentDebate = null;
    _userRemainingVotingPower = BigInt.zero;
    notifyListeners();
  }

  /// Clears error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
