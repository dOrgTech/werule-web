// lib/src/features/dao_creator/providers/dao_creator_provider.dart
import 'dart:async';
import 'dart:js_util';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_creator/models/creator_member.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/create_dao_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/features/dao_creator/utils/creator_utils.dart';


class DaoCreatorProvider extends ChangeNotifier {
  final BlockchainService _blockchainService;
  final AuthProvider _authProvider;
  final NetworkProvider _networkProvider;
  final FirestoreService _firestoreService;

  DaoCreatorProvider({
    required BlockchainService blockchainService,
    required AuthProvider authProvider,
    required NetworkProvider networkProvider,
    required FirestoreService firestoreService,
  })  : _blockchainService = blockchainService,
        _authProvider = authProvider,
        _networkProvider = networkProvider,
        _firestoreService = firestoreService;

  int _currentStep = 0;
  int get currentStep => _currentStep;
  int _maxStepReached = 0;
  int get maxStepReached => _maxStepReached;

  // Common properties
  String? daoType;
  String? daoName;
  String? daoDescription;
  String? tokenSymbol;
  String? totalSupply;
  bool isTransferrable = false; // Default to non-transferable (soulbound)
  bool useWrappedToken = false; // Whether to wrap an existing ERC20
  String? underlyingTokenAddress; // For wrapped tokens
  Map<String, String> registry = {};
  int proposalThreshold = 1;
  int quorumThreshold = 4;
  double supermajority = 75.0;
  Duration votingDuration = const Duration(days: 7);
  Duration votingDelay = Duration.zero;
  Duration executionDelay = const Duration(days: 1);
  List<Member> members = [];
  
  // Economy DAO specific fields
  double platformFee = 1.5;
  double authorFee = 2.0;
  double arbitrationFee = 5.0;
  Duration coolingOffPeriod = const Duration(hours: 24);
  int backerVotingQuorum = 70;
  int projectCreationThreshold = 1000;
  // THE FIX: Default value is calculated from other durations + a 2-day buffer.
  Duration disputeAndAppealPeriod = const Duration(days: 7) + const Duration(days: 1) + const Duration(days: 2);

  bool _isDeploying = false;
  bool get isDeploying => _isDeploying;
  String? _deploymentError;
  String? get deploymentError => _deploymentError;
  String? _newDaoAddress;
  String? get newDaoAddress => _newDaoAddress;
  String _deploymentStatusMessage = '';
  String get deploymentStatusMessage => _deploymentStatusMessage;
  
  bool _isIndexed = false;
  bool get isIndexed => _isIndexed;

  Timer? _pollingTimer;

  // Helper to determine if Members screen should be shown
  bool get shouldShowMembers => !useWrappedToken;

  // Dynamic Stepper Logic
  int get reviewStepIndex {
    int baseIndex = 6; // Standard DAO: Type, Setup, Quorums, Durations, Members, Registry
    if (!shouldShowMembers) baseIndex--; // Skip Members
    if (daoType == 'Economy DAO') baseIndex += 3; // Add Economy screens
    return baseIndex;
  }

  int get deployingStepIndex => reviewStepIndex + 1;
  int get completeStepIndex => reviewStepIndex + 2;
  int get totalSteps => completeStepIndex + 1;


  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
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
    if (step >= 0 && step < totalSteps) {
      if (step > _maxStepReached) _maxStepReached = step;
      _currentStep = step;
      notifyListeners();
    }
  }

  void updateBasicInfo({
    required String name,
    required String description,
    required String? symbol,
    required bool transferrable,
    bool? wrappedToken,
    String? underlyingToken,
  }) {
    daoName = name;
    daoDescription = description;
    tokenSymbol = symbol;
    // Economy DAOs always use non-transferable, non-wrapped tokens
    if (daoType == 'Economy DAO') {
      isTransferrable = false;
      useWrappedToken = false;
      underlyingTokenAddress = null;
    } else {
      isTransferrable = transferrable;
      useWrappedToken = wrappedToken ?? false;
      underlyingTokenAddress = underlyingToken;
    }
    // Reset members if token symbol changes, as supply is dependent on it.
    members = [];
    totalSupply = "0";
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
    int total = 0;
    for (var member in members) {
      total += member.amount;
    }
    // Decimals are hardcoded to 18 for all new tokens.
    totalSupply = total.toString() + "0" * 18;
    notifyListeners();
  }

  void updateRegistry(Map<String, String> newRegistry) {
    registry = newRegistry;
    notifyListeners();
  }
  
  void updateEconomyFees({
    required double platFee,
    required double authFee,
    required double arbFee,
  }) {
    platformFee = platFee;
    authorFee = authFee;
    arbitrationFee = arbFee;
    notifyListeners();
  }
  
  void updateProjectThresholds({
    required int backerQuorum,
    required int creationThreshold,
  }) {
    backerVotingQuorum = backerQuorum;
    projectCreationThreshold = creationThreshold;
    notifyListeners();
  }
  
  void updateProjectDurations({
    required Duration coolingOff,
    required Duration disputePeriod,
  }) {
    coolingOffPeriod = coolingOff;
    disputeAndAppealPeriod = disputePeriod;
    notifyListeners();
  }

  Future<void> deployDao() async {
    // 1. Set state and go to the "Deploying..." screen.
    _isDeploying = true;
    _isIndexed = false;
    _deploymentError = null;
    _deploymentStatusMessage = "Preparing transaction...";
    goToStep(deployingStepIndex);

    // 2. Wait for the UI to redraw.
    await Future.delayed(Duration.zero);

    // 3. Proceed with the blockchain call.
    final network = _networkProvider.selectedNetwork;
    if (network == null) {
      _deploymentError = "Network not selected.";
      _isDeploying = false;
      notifyListeners();
      return;
    }

    try {
      final memberBalances = members.map((m) => m.personalBalance ?? "0").toList();

      _deploymentStatusMessage = "Please confirm the transaction in your wallet...";
      notifyListeners();

      final String deployedAddress;

      // Check if this is an Economy DAO
      if (daoType == 'Economy DAO') {
        // Use the trustless factory for Economy DAOs
        final factoryAddress = network.wrapperTrustless;

        // Debug logging
        final console = getProperty(globalThis, 'console');
        callMethod(console, 'log', ["=== ECONOMY DAO DEBUG ==="]);
        callMethod(console, 'log', ["Network name: ${network.name}"]);
        callMethod(console, 'log', ["Factory address: $factoryAddress"]);
        callMethod(console, 'log', ["Native project impl: ${network.nativeProjectImpl}"]);
        callMethod(console, 'log', ["ERC20 project impl: ${network.erc20ProjectImpl}"]);
        callMethod(console, 'log', ["DAO name: $daoName"]);
        callMethod(console, 'log', ["Token symbol: $tokenSymbol"]);
        callMethod(console, 'log', ["Members: ${members.length}"]);
        callMethod(console, 'log', ["Member addresses: ${members.map((m) => m.address).toList()}"]);
        callMethod(console, 'log', ["Member balances: $memberBalances"]);
        callMethod(console, 'log', ["Execution delay (minutes): ${executionDelay.inMinutes}"]);
        callMethod(console, 'log', ["Voting duration (minutes): ${votingDuration.inMinutes}"]);
        callMethod(console, 'log', ["Proposal threshold: $proposalThreshold"]);
        callMethod(console, 'log', ["Quorum threshold: $quorumThreshold"]);
        callMethod(console, 'log', ["Platform fee: $platformFee"]);
        callMethod(console, 'log', ["Author fee: $authorFee"]);
        callMethod(console, 'log', ["Cooling off (seconds): ${coolingOffPeriod.inSeconds}"]);
        callMethod(console, 'log', ["Backer voting quorum: $backerVotingQuorum"]);
        callMethod(console, 'log', ["Project creation threshold: $projectCreationThreshold"]);
        callMethod(console, 'log', ["Dispute/appeal period (seconds): ${disputeAndAppealPeriod.inSeconds}"]);
        callMethod(console, 'log', ["==========================="]);

        if (factoryAddress.isEmpty) {
          throw Exception("Economy DAO factory not configured for this network.");
        }

        if (network.nativeProjectImpl.isEmpty || network.erc20ProjectImpl.isEmpty) {
          throw Exception("Project implementation addresses not configured for this network.");
        }

        // Convert fee percentages to basis points (multiply by 100)
        final arbitrationFeeBps = (arbitrationFee * 100).round();
        final platformFeeBps = (platformFee * 100).round();
        final authorFeeBps = (authorFee * 100).round();
        // backersQuorumBps is already in percentage, convert to basis points
        final backersQuorumBps = backerVotingQuorum * 100;
        // Convert project creation threshold to wei (18 decimals)
        final projectThresholdWei = projectCreationThreshold;

        // Add description to registry so it can be read by the indexer
        final economyRegistry = Map<String, String>.from(registry);
        if (daoDescription != null && daoDescription!.isNotEmpty) {
          economyRegistry['description'] = daoDescription!;
        }

        callMethod(console, 'log', ["Calling createEconomyDAO..."]);

        deployedAddress = await createEconomyDAO(
          factoryAddress: factoryAddress,
          tokenName: daoName ?? '',
          tokenSymbol: tokenSymbol ?? '',
          initialMembers: members.map((m) => m.address).toList(),
          memberBalances: memberBalances,
          timelockDelayMinutes: executionDelay.inMinutes,
          votingPeriodMinutes: votingDuration.inMinutes,
          proposalThreshold: proposalThreshold,
          quorumFraction: quorumThreshold,
          arbitrationFeeBps: arbitrationFeeBps,
          platformFeeBps: platformFeeBps,
          authorFeeBps: authorFeeBps,
          coolingOffPeriodSeconds: coolingOffPeriod.inSeconds,
          backersQuorumBps: backersQuorumBps,
          projectThresholdWei: projectThresholdWei,
          appealPeriodSeconds: disputeAndAppealPeriod.inSeconds,
          nativeProjectImpl: network.nativeProjectImpl,
          erc20ProjectImpl: network.erc20ProjectImpl,
          registry: economyRegistry,
          onProgress: (message) {
            _deploymentStatusMessage = message;
            notifyListeners();
          },
        );
      } else if (useWrappedToken) {
        // Use wrapped token factory
        final factoryAddress = network.wrapperW;

        deployedAddress = await createDAOWithWrappedToken(
          factoryAddress: factoryAddress,
          name: daoName ?? '',
          symbol: tokenSymbol ?? '',
          description: daoDescription ?? '',
          executionDelay: executionDelay.inSeconds,
          underlyingTokenAddress: underlyingTokenAddress ?? '',
          votingDelay: votingDelay.inMinutes,
          votingDuration: votingDuration.inMinutes,
          proposalThreshold: proposalThreshold,
          quorum: quorumThreshold,
          registry: registry,
          transferrableStr: isTransferrable ? 'true' : 'false',
        );
      } else {
        // Standard DAO: Choose the correct wrapper contract based on transferability
        // wrapper = non-transferable (soulbound), wrapperT = transferable
        final factoryAddress = isTransferrable ? network.wrapperT : network.wrapper;

        deployedAddress = await createDAOFromWizard(
          factoryAddress: factoryAddress,
          name: daoName ?? '',
          symbol: tokenSymbol ?? '',
          description: daoDescription ?? '',
          decimals: 18, // Hardcoded
          executionDelay: executionDelay.inSeconds,
          initialMembers: members.map((m) => m.address).toList(),
          memberBalances: memberBalances,
          votingDelay: votingDelay.inMinutes,
          votingDuration: votingDuration.inMinutes,
          proposalThreshold: proposalThreshold,
          quorum: quorumThreshold,
          registry: registry,
        );
      }

      _newDaoAddress = deployedAddress;

      _deploymentStatusMessage = "Transaction confirmed. Waiting for indexer...";
      notifyListeners();

      await _startPollingForDao(deployedAddress);

    } catch (e) {
      // Log error to browser console for easy copying
      final console = getProperty(globalThis, 'console');
      callMethod(console, 'error', ["=== DAO DEPLOYMENT ERROR (Provider) ==="]);
      callMethod(console, 'error', ["Error caught in deployDao():"]);
      callMethod(console, 'error', [e.toString()]);
      callMethod(console, 'dir', [e]);
      callMethod(console, 'error', ["========================================="]);

      _deploymentError = e.toString();
      _isDeploying = false;
      // Stay on screen to show the error.
      notifyListeners();
    }
  }

  Future<void> _startPollingForDao(String address) async {
    const pollInterval = Duration(seconds: 5);
    const timeout = Duration(minutes: 3);
    int attempts = 0;
    int maxAttempts = timeout.inSeconds ~/ pollInterval.inSeconds;

    _pollingTimer = Timer.periodic(pollInterval, (timer) async {
      if (attempts >= maxAttempts) {
        timer.cancel();
        _deploymentError = "Indexer polling timed out, but the DAO was likely created. You can find it on a block explorer.";
        _isDeploying = false;
        notifyListeners();
        return;
      }

      attempts++;
      final network = _networkProvider.selectedNetwork;
      if (network == null) {
        timer.cancel();
        return;
      }

      final dao = await _firestoreService.getDao(network.daoCollectionName, address);
      if (dao != null) {
        timer.cancel();
        _isDeploying = false;
        _isIndexed = true;
        goToStep(completeStepIndex); 
      }
    });
  }
}
// lib/src/features/dao_creator/providers/dao_creator_provider.dart