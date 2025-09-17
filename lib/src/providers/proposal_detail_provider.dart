// lib/src/providers/proposal_detail_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/utils/proposal_status_helper.dart';

class ProposalDetailProvider extends ChangeNotifier {
  final BlockchainService _blockchainService;
  final FirestoreService _firestoreService;
  final AuthProvider _authProvider;
  late Proposal _proposal; 
  late Org _org;
  final Network _network;
  Timer? _countdownTimer;
  bool _isRecalculating = false;

  ProposalDetailProvider({
    required BlockchainService blockchainService,
    required FirestoreService firestoreService,
    required AuthProvider authProvider,
    required Proposal proposal,
    required Org org,
    required Network network,
  })  : _blockchainService = blockchainService,
        _firestoreService = firestoreService,
        _authProvider = authProvider,
        _network = network {
    _proposal = proposal;
    _org = org;
    _initialize();
  }

  // --- State ---
  bool _isLoading = true;
  bool _isActionBusy = false;
  String? _errorMessage;
  ProposalStatus _status = ProposalStatus.Unknown;
  int _remainingSeconds = 0;
  Map<ProposalStatus, DateTime> _fullTimeline = {};
  BigInt? _pastVotingWeight;
  bool _hasUserVoted = false;

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isActionBusy => _isActionBusy;
  String? get errorMessage => _errorMessage;
  ProposalStatus get status => _status;
  Proposal get proposal => _proposal;
  int get remainingSeconds => _remainingSeconds;
  bool get showCountdown => _status == ProposalStatus.Pending || _status == ProposalStatus.Active || _status == ProposalStatus.Queued;
  Map<ProposalStatus, DateTime> get fullTimeline => _fullTimeline;
  BigInt? get pastVotingWeight => _pastVotingWeight;
  bool get hasUserVoted => _hasUserVoted;
  Org get org => _org;
  Network get network => _network;
  
  void update(Proposal newProposal, Org newOrg) {
    if (newProposal == _proposal && newOrg == _org) {
      return;
    }
    _proposal = newProposal;
    _org = newOrg;
    
    _recalculateStateAndRestartTimer();
  }

  Future<void> _initialize() async {
    _status = ProposalStatusHelper.calculateDisplayStatus(_proposal, _org);
    
    await Future.wait([
      _syncWithOnChainState(),
      _fetchPastVotingWeight(), 
      _checkIfUserVoted(),
    ]);

    _calculateFullTimeline(_status);
    _startCountdown();
    _isLoading = false;
    notifyListeners();
  }
  
  void _recalculateStateAndRestartTimer() {
    final oldStatus = _status;
    _status = ProposalStatusHelper.calculateDisplayStatus(_proposal, _org);
    _calculateFullTimeline(_status);
    _startCountdown();

    if (_status == ProposalStatus.Active && oldStatus == ProposalStatus.Pending) {
      if (kDebugMode) print("[ProposalDetailProvider] State changed to Active, fetching past vote weight and vote status...");
      _fetchPastVotingWeight();
      _checkIfUserVoted();
    } else {
      notifyListeners();
    }
  }

  Future<void> _syncWithOnChainState() async {
    try {
      final proposalId = BigInt.tryParse(_proposal.id);
      if (proposalId == null) throw Exception("Invalid Proposal ID");
      await _blockchainService.getProposalState(_org.address, proposalId, _network.rpcUrl);
    } catch (e) {
      _errorMessage = "Failed to sync on-chain status: ${e.toString()}";
    }
  }

  // THE FIX: Add a new method to check the user's vote status from Firestore.
  Future<void> _checkIfUserVoted() async {
    final userAddress = _authProvider.selectedAccount;
    if (userAddress == null || _status != ProposalStatus.Active) {
      _hasUserVoted = false;
      return;
    }
    _hasUserVoted = await _firestoreService.hasUserVoted(
      _network.daoCollectionName,
      _org.address,
      _proposal.id,
      userAddress,
    );
  }

  // THE FIX: Add a small delay before the first attempt to fetch the snapshot.
  Future<void> _fetchPastVotingWeight() async {
    final userAddress = _authProvider.selectedAccount;
    final proposalId = BigInt.tryParse(_proposal.id);

    if (userAddress == null || proposalId == null || _status != ProposalStatus.Active) {
      return;
    }

    // Add a small delay to give the RPC node a moment to sync with the snapshot timestamp.
    await Future.delayed(const Duration(seconds: 1));
    
    int retries = 5;
    bool success = false;

    while (retries > 0 && !success) {
      try {
        final timestamp = await _blockchainService.getProposalSnapshotTimestamp(_org.address, proposalId, _network.rpcUrl);
        
        if (timestamp > BigInt.zero) {
          _pastVotingWeight = await _blockchainService.getPastVotes(_org.govTokenAddress, userAddress, timestamp, _network.rpcUrl);
          success = true;
        } else {
          throw Exception("Snapshot timestamp is 0");
        }
      } catch (e) {
        retries--;
        if (kDebugMode) print("[ProposalDetailProvider] Failed to fetch past votes, retrying... ($retries left). Error: $e");
        
        if (retries > 0) {
          await Future.delayed(const Duration(seconds: 2));
        } else {
          if (kDebugMode) print("[ProposalDetailProvider] All retries failed to fetch past votes.");
          _pastVotingWeight = BigInt.zero;
        }
      }
    }
    notifyListeners();
  }

  void _calculateFullTimeline(ProposalStatus currentStatus) {
    final timeline = <ProposalStatus, DateTime>{};
    final now = DateTime.now();
    final createdAt = _proposal.createdAt;
    final voteStart = createdAt.add(Duration(minutes: _org.votingDelay));
    final voteEnd = voteStart.add(Duration(minutes: _org.votingDuration));

    timeline[ProposalStatus.Pending] = createdAt;

    if (now.isAfter(voteStart) || currentStatus != ProposalStatus.Pending) {
        timeline[ProposalStatus.Active] = voteStart;
    }
    if (now.isAfter(voteEnd) || currentStatus.index > ProposalStatus.Active.index) {
        switch (currentStatus) {
            case ProposalStatus.Succeeded:
            case ProposalStatus.Queued:
            case ProposalStatus.Executed:
                timeline[ProposalStatus.Succeeded] = voteEnd;
                break;
            case ProposalStatus.Defeated:
            case ProposalStatus.NoQuorum:
            case ProposalStatus.Rejected:
                timeline[currentStatus] = voteEnd;
                break;
            default:
                 break;
        }
    }
    if (_proposal.statusHistory.containsKey('queued')) {
        timeline[ProposalStatus.Queued] = _proposal.statusHistory['queued']!;
    }
    if (_proposal.statusHistory.containsKey('executed')) {
       timeline[ProposalStatus.Executed] = _proposal.statusHistory['executed']!;
    }
    _fullTimeline = timeline;
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());
  }

  void _updateRemainingTime() {
    if (_isRecalculating) return;

    final now = DateTime.now();
    DateTime? targetTime;

    final voteStart = _proposal.createdAt.add(Duration(minutes: _org.votingDelay));
    final voteEnd = voteStart.add(Duration(minutes: _org.votingDuration));

    if (_status == ProposalStatus.Pending) targetTime = voteStart;
    else if (_status == ProposalStatus.Active) targetTime = voteEnd;
    else if (_status == ProposalStatus.Queued) {
      final queuedTime = _proposal.statusHistory['queued'] ?? voteEnd;
      targetTime = queuedTime.add(Duration(seconds: _org.executionDelay));
    }

    int oldRemaining = _remainingSeconds;
    
    if (targetTime != null) {
      final remaining = targetTime.difference(now).inSeconds;
      _remainingSeconds = remaining > 0 ? remaining : 0;
    } else {
      _remainingSeconds = 0;
    }
    
    if (oldRemaining > 0 && _remainingSeconds <= 0 && !_isRecalculating) {
      _isRecalculating = true;
      Future.delayed(const Duration(seconds: 2), () {
        _recalculateStateAndRestartTimer();
        _isRecalculating = false;
      });
    } else {
      if (oldRemaining != _remainingSeconds) {
        notifyListeners();
      }
    }
  }

  Future<String?> handleAction(Function action) async {
    _isActionBusy = true;
    notifyListeners();
    String? error;
    try {
      await action();
      // THE FIX: After a successful vote, update the `hasUserVoted` flag.
      _hasUserVoted = true;
    } catch (e) {
      error = e.toString();
    }
    _isActionBusy = false;
    notifyListeners();
    return error;
  }
  
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
// lib/src/providers/proposal_detail_provider.dart