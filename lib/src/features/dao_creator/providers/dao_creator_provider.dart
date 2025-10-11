// lib/src/features/dao_creator/providers/dao_creator_provider.dart

import 'dart:async';
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

  String? daoType;
  String? daoName;
  String? daoDescription;
  DaoTokenDeploymentMechanism tokenDeploymentMechanism =
      DaoTokenDeploymentMechanism.deployNewStandardToken;
  String? tokenSymbol;
  int? numberOfDecimals;
  bool nonTransferrable = true;
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

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void nextStep() {
    // The highest index is 8 (for Screen9DeploymentComplete)
    if (_currentStep < 8) {
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
    if (step >= 0 && step <= 8) {
      if (step > _maxStepReached) _maxStepReached = step;
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
    } else {
      underlyingTokenAddress = underlyingAddress;
      wrappedTokenSymbol = wrappedSymbol;
      wrappedTokenName = "Wrapped ${wrappedTokenSymbol ?? "Token"}";
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
    // 1. Set state and go to the "Deploying..." screen (index 7).
    _isDeploying = true;
    _isIndexed = false;
    _deploymentError = null;
    _deploymentStatusMessage = "Preparing transaction...";
    goToStep(7); // THE FIX: Use the correct index for the "Deploying" screen.
    
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

      final deployedAddress = await createDAOFromWizard(
        factoryAddress: network.wrapper, 
        name: daoName ?? '',
        symbol: tokenSymbol ?? '',
        description: daoDescription ?? '',
        decimals: numberOfDecimals ?? 18,
        executionDelay: executionDelay.inSeconds,
        initialMembers: members.map((m) => m.address).toList(),
        memberBalances: memberBalances,
        votingDelay: votingDelay.inMinutes,
        votingDuration: votingDuration.inMinutes,
        proposalThreshold: proposalThreshold,
        quorum: quorumThreshold,
        registry: registry,
        isTransferrable: !nonTransferrable,
      );
      
      _newDaoAddress = deployedAddress;
      
      _deploymentStatusMessage = "Transaction confirmed. Waiting for indexer...";
      notifyListeners();

      await _startPollingForDao(deployedAddress);

    } catch (e) {
      _deploymentError = e.toString();
      _isDeploying = false;
      // Stay on screen 7 to show the error.
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
        // THE FIX: Go to the "Complete" screen (index 8) upon success.
        goToStep(8); 
      }
    });
  }
}