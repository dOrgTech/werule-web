// lib/src/providers/economy_provider.dart
import 'package:flutter/material.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';

/// Model for claimable epoch information
class ClaimableEpoch {
  final BigInt epochId;
  final RewardEpoch epoch;
  final bool hasClaimed;
  final BigInt estimatedReward;

  ClaimableEpoch({
    required this.epochId,
    required this.epoch,
    required this.hasClaimed,
    required this.estimatedReward,
  });

  bool get canClaim => !hasClaimed && epoch.isValid && estimatedReward > BigInt.zero;
}

/// Model for unclaimed activity per token
class UnclaimedActivity {
  final String tokenAddress;
  final BigInt totalEarnings;
  final BigInt claimedEarnings;
  final BigInt totalSpendings;
  final BigInt claimedSpendings;

  UnclaimedActivity({
    required this.tokenAddress,
    required this.totalEarnings,
    required this.claimedEarnings,
    required this.totalSpendings,
    required this.claimedSpendings,
  });

  BigInt get unclaimedEarnings => totalEarnings - claimedEarnings;
  BigInt get unclaimedSpendings => totalSpendings - claimedSpendings;
  BigInt get totalUnclaimed => unclaimedEarnings + unclaimedSpendings;
  bool get hasUnclaimed => totalUnclaimed > BigInt.zero;
}

/// Provider for managing economy-related data and actions
class EconomyProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final BlockchainService _blockchainService;
  final Org _org;
  final Network _network;

  EconomyProvider({
    required AuthProvider authProvider,
    required BlockchainService blockchainService,
    required Org org,
    required Network network,
  })  : _authProvider = authProvider,
        _blockchainService = blockchainService,
        _org = org,
        _network = network {
    if (_org.isEconomyDao) {
      fetchEconomyData();
    }
  }

  // --- State ---
  bool _isLoading = true;
  String? _errorMessage;
  bool _isActionBusy = false;

  // Economy profile
  EconomyUserProfile? _economyProfile;
  List<UnclaimedActivity> _unclaimedActivities = [];
  bool _hasUnclaimedReputation = false;

  // Passive income epochs
  BigInt _currentPassiveIncomeEpoch = BigInt.zero;
  List<ClaimableEpoch> _passiveIncomeEpochs = [];

  // Delegate reward epochs
  BigInt _currentDelegateRewardEpoch = BigInt.zero;
  List<ClaimableEpoch> _delegateRewardEpochs = [];

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isActionBusy => _isActionBusy;
  String? get errorMessage => _errorMessage;
  EconomyUserProfile? get economyProfile => _economyProfile;
  List<UnclaimedActivity> get unclaimedActivities => _unclaimedActivities;
  bool get hasUnclaimedReputation => _hasUnclaimedReputation;
  List<ClaimableEpoch> get passiveIncomeEpochs => _passiveIncomeEpochs;
  List<ClaimableEpoch> get delegateRewardEpochs => _delegateRewardEpochs;
  BigInt get currentPassiveIncomeEpoch => _currentPassiveIncomeEpoch;
  BigInt get currentDelegateRewardEpoch => _currentDelegateRewardEpoch;

  bool get hasClaimablePassiveIncome => _passiveIncomeEpochs.any((e) => e.canClaim);
  bool get hasClaimableDelegateReward => _delegateRewardEpochs.any((e) => e.canClaim);

  Future<void> fetchEconomyData() async {
    final userAddress = _authProvider.selectedAccount;
    if (userAddress == null || !_org.isEconomyDao || _org.economy == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (!_isLoading) {
      _isActionBusy = true;
      notifyListeners();
    }

    try {
      // Fetch economy profile
      _economyProfile = await _blockchainService.getEconomyUserProfile(
        _org.economy!,
        userAddress,
        _network.rpcUrl,
      );

      // Calculate unclaimed activities
      await _calculateUnclaimedActivities(userAddress);

      // Fetch epoch data
      await _fetchEpochData(userAddress);

    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    _isActionBusy = false;
    notifyListeners();
  }

  Future<void> _calculateUnclaimedActivities(String userAddress) async {
    if (_economyProfile == null) return;

    final List<UnclaimedActivity> activities = [];
    final allTokens = <String>{
      ..._economyProfile!.earnedTokens,
      ..._economyProfile!.spentTokens,
    };

    for (final token in allTokens) {
      final earnedIndex = _economyProfile!.earnedTokens.indexOf(token);
      final spentIndex = _economyProfile!.spentTokens.indexOf(token);

      final totalEarnings = earnedIndex >= 0 ? _economyProfile!.earnedAmounts[earnedIndex] : BigInt.zero;
      final totalSpendings = spentIndex >= 0 ? _economyProfile!.spentAmounts[spentIndex] : BigInt.zero;

      // Get claimed amounts from RepToken
      final claimedEarnings = await _blockchainService.getClaimedEarnings(
        _org.govTokenAddress,
        userAddress,
        token,
        _network.rpcUrl,
      );
      final claimedSpendings = await _blockchainService.getClaimedSpendings(
        _org.govTokenAddress,
        userAddress,
        token,
        _network.rpcUrl,
      );

      final activity = UnclaimedActivity(
        tokenAddress: token,
        totalEarnings: totalEarnings,
        claimedEarnings: claimedEarnings,
        totalSpendings: totalSpendings,
        claimedSpendings: claimedSpendings,
      );

      if (activity.hasUnclaimed) {
        activities.add(activity);
      }
    }

    _unclaimedActivities = activities;
    _hasUnclaimedReputation = activities.isNotEmpty;
  }

  Future<void> _fetchEpochData(String userAddress) async {
    // Get current epoch IDs
    _currentPassiveIncomeEpoch = await _blockchainService.getCurrentPassiveIncomeEpoch(
      _org.govTokenAddress,
      _network.rpcUrl,
    );
    _currentDelegateRewardEpoch = await _blockchainService.getCurrentDelegateRewardEpoch(
      _org.govTokenAddress,
      _network.rpcUrl,
    );

    // Fetch passive income epochs (get last few epochs)
    _passiveIncomeEpochs = await _fetchClaimableEpochs(
      userAddress,
      _currentPassiveIncomeEpoch,
      isPassiveIncome: true,
    );

    // Fetch delegate reward epochs
    _delegateRewardEpochs = await _fetchClaimableEpochs(
      userAddress,
      _currentDelegateRewardEpoch,
      isPassiveIncome: false,
    );
  }

  Future<List<ClaimableEpoch>> _fetchClaimableEpochs(
    String userAddress,
    BigInt currentEpoch, {
    required bool isPassiveIncome,
  }) async {
    final List<ClaimableEpoch> epochs = [];

    // Fetch up to 5 most recent epochs
    final startEpoch = currentEpoch > BigInt.from(5) ? currentEpoch - BigInt.from(4) : BigInt.one;

    for (var epochId = startEpoch; epochId <= currentEpoch; epochId += BigInt.one) {
      try {
        final RewardEpoch epoch;
        final bool hasClaimed;

        if (isPassiveIncome) {
          epoch = await _blockchainService.getPassiveIncomeEpoch(
            _org.govTokenAddress,
            epochId,
            _network.rpcUrl,
          );
          hasClaimed = await _blockchainService.hasClaimedPassiveIncome(
            _org.govTokenAddress,
            epochId,
            userAddress,
            _network.rpcUrl,
          );
        } else {
          epoch = await _blockchainService.getDelegateRewardEpoch(
            _org.govTokenAddress,
            epochId,
            _network.rpcUrl,
          );
          hasClaimed = await _blockchainService.hasClaimedDelegateReward(
            _org.govTokenAddress,
            epochId,
            userAddress,
            _network.rpcUrl,
          );
        }

        if (!epoch.isValid) continue;

        // Estimate reward based on current balance (simplified)
        // In reality, this would use getPastVotes at epoch.startTimestamp - 1
        final estimatedReward = await _estimateReward(
          userAddress,
          epoch,
          isPassiveIncome,
        );

        epochs.add(ClaimableEpoch(
          epochId: epochId,
          epoch: epoch,
          hasClaimed: hasClaimed,
          estimatedReward: estimatedReward,
        ));
      } catch (e) {
        // Skip invalid epochs
      }
    }

    return epochs.reversed.toList(); // Most recent first
  }

  Future<BigInt> _estimateReward(
    String userAddress,
    RewardEpoch epoch,
    bool isPassiveIncome,
  ) async {
    if (epoch.budget == BigInt.zero) return BigInt.zero;

    try {
      final snapshotTime = epoch.startTimestamp - BigInt.one;
      final userBalance = await _blockchainService.getPastVotes(
        _org.govTokenAddress,
        userAddress,
        snapshotTime,
        _network.rpcUrl,
      );

      if (userBalance == BigInt.zero) return BigInt.zero;

      final totalSupply = await _blockchainService.getPastTotalSupply(
        _org.govTokenAddress,
        snapshotTime,
        _network.rpcUrl,
      );

      if (totalSupply == BigInt.zero) return BigInt.zero;

      if (isPassiveIncome) {
        // Passive income is based on reputation balance
        return (userBalance * epoch.budget) ~/ totalSupply;
      } else {
        // Delegate reward is based on delegated votes (voting power - own balance)
        // This is a simplification - would need separate balance tracking
        return (userBalance * epoch.budget) ~/ totalSupply;
      }
    } catch (e) {
      return BigInt.zero;
    }
  }

  // --- Actions ---

  Future<void> claimReputationFromEconomy() async {
    final userAddress = _authProvider.selectedAccount;
    if (userAddress == null) {
      throw Exception("No account selected.");
    }

    _isActionBusy = true;
    notifyListeners();

    try {
      await _blockchainService.claimReputationFromEconomy(
        _org.govTokenAddress,
        userAddress,
      );
      // Wait for transaction to be indexed
      await Future.delayed(const Duration(seconds: 3));
      await fetchEconomyData();
    } finally {
      _isActionBusy = false;
      notifyListeners();
    }
  }

  Future<void> claimPassiveIncome(BigInt epochId) async {
    final userAddress = _authProvider.selectedAccount;
    if (userAddress == null) {
      throw Exception("No account selected.");
    }

    _isActionBusy = true;
    notifyListeners();

    try {
      await _blockchainService.claimPassiveIncome(
        _org.govTokenAddress,
        epochId,
        userAddress,
      );
      await Future.delayed(const Duration(seconds: 3));
      await fetchEconomyData();
    } finally {
      _isActionBusy = false;
      notifyListeners();
    }
  }

  Future<void> claimDelegateReward(BigInt epochId) async {
    final userAddress = _authProvider.selectedAccount;
    if (userAddress == null) {
      throw Exception("No account selected.");
    }

    _isActionBusy = true;
    notifyListeners();

    try {
      await _blockchainService.claimRepresentationReward(
        _org.govTokenAddress,
        epochId,
        userAddress,
      );
      await Future.delayed(const Duration(seconds: 3));
      await fetchEconomyData();
    } finally {
      _isActionBusy = false;
      notifyListeners();
    }
  }
}
