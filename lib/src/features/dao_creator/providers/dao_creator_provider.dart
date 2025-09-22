// lib/src/features/dao_creator/providers/dao_creator_provider.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_creator/models/creator_member.dart';
import 'package:werule/src/features/dao_creator/utils/creator_utils.dart';

class DaoCreatorProvider extends ChangeNotifier {
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // THE FIX: Track the furthest step the user has reached.
  int _maxStepReached = 0;
  int get maxStepReached => _maxStepReached;

  // DAO Configuration Properties
  String? daoType;
  String? daoName;
  String? daoDescription;

  DaoTokenDeploymentMechanism tokenDeploymentMechanism =
      DaoTokenDeploymentMechanism.deployNewStandardToken;

  // Fields for "deploy new token"
  String? tokenSymbol;
  int? numberOfDecimals;
  bool nonTransferrable = true;

  // Fields for "wrap existing token"
  String? underlyingTokenAddress;
  String? wrappedTokenName;
  String? wrappedTokenSymbol;

  String? totalSupply;
  Map<String, String> registry = {};
  int proposalThreshold = 1;
  int quorumThreshold = 4;
  double supermajority = 75.0;
  Duration votingDuration = Duration.zero;
  Duration votingDelay = Duration.zero;
  Duration executionDelay = Duration.zero;
  List<Member> members = [];

  void nextStep() {
    if (_currentStep < 8) {
      _currentStep++;
      // THE FIX: Update max step reached when moving forward.
      if (_currentStep > _maxStepReached) {
        _maxStepReached = _currentStep;
      }
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    // THE FIX: Only allow navigation to steps that have been visited.
    if (step >= 0 && step <= _maxStepReached && step <= 8) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void updateBasicInfo({
    required String name,
    required String description,
    required DaoTokenDeploymentMechanism mechanism,
    String? symbol,
    int? decimals,
    bool? isNonTransferrable,
    String? underlyingAddress,
    String? wrappedSymbol,
  }) {
    daoName = name;
    daoDescription = description;
    tokenDeploymentMechanism = mechanism;

    if (mechanism == DaoTokenDeploymentMechanism.deployNewStandardToken) {
      tokenSymbol = symbol;
      numberOfDecimals = decimals;
      nonTransferrable = isNonTransferrable ?? true;
      // Clear wrapped token fields
      underlyingTokenAddress = null;
      wrappedTokenSymbol = null;
      wrappedTokenName = null;
    } else {
      underlyingTokenAddress = underlyingAddress;
      wrappedTokenSymbol = wrappedSymbol;
      wrappedTokenName = "Wrapped ${wrappedSymbol ?? "Token"}";
      // Clear standard token specific fields and reset members
      tokenSymbol = null;
      numberOfDecimals = null; // Decimals will be from the underlying token
      members = [];
      totalSupply = "0";
    }
    notifyListeners();
  }

  void updateQuorums(int quorum, int threshold) {
    quorumThreshold = quorum;
    proposalThreshold = threshold;
    notifyListeners();
  }

  void updateDurations(Duration delay, Duration duration, Duration execution) {
    votingDelay = delay;
    votingDuration = duration;
    executionDelay = execution;
    notifyListeners();
  }

  void updateMembers(List<Member> newMembers) {
    members = newMembers;
    // Recalculate total supply for new standard tokens
    if (tokenDeploymentMechanism ==
        DaoTokenDeploymentMechanism.deployNewStandardToken) {
      int total = 0;
      for (var member in members) {
        total += member.amount;
      }
      totalSupply = total.toString() + "0" * (numberOfDecimals ?? 0);
    }
    notifyListeners();
  }

  void updateRegistry(Map<String, String> newRegistry) {
    registry = newRegistry;
    notifyListeners();
  }

  Future<void> deployDao() async {
    goToStep(7); // Show deploying screen
    await Future.delayed(const Duration(seconds: 3));
    goToStep(8);
  }
}
// lib/src/features/dao_creator/providers/dao_creator_provider.dart