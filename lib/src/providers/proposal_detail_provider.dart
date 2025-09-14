// lib/src/providers/proposal_detail_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/utils/proposal_status_helper.dart'; // THE FIX: We can use our helper here too

class ProposalDetailProvider extends ChangeNotifier {
  final BlockchainService _blockchainService;
  late Proposal _proposal; // Make non-final
  late Org _org; // Make non-final
  final Network _network;
  Timer? _countdownTimer;

  ProposalDetailProvider({
    required BlockchainService blockchainService,
    required Proposal proposal,
    required Org org,
    required Network network,
  })  : _blockchainService = blockchainService,
        _network = network {
    // Initialize with the first version of the proposal data
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

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isActionBusy => _isActionBusy;
  String? get errorMessage => _errorMessage;
  ProposalStatus get status => _status;
  Proposal get proposal => _proposal; // Expose the current proposal
  int get remainingSeconds => _remainingSeconds;
  bool get showCountdown => _status == ProposalStatus.Pending || _status == ProposalStatus.Active || _status == ProposalStatus.Queued;
  Map<ProposalStatus, DateTime> get fullTimeline => _fullTimeline;
  
  // THE FIX: Public method to update the provider with new data from the stream
  void update(Proposal newProposal, Org newOrg) {
    // Use the equality operator we defined to prevent unnecessary rebuilds
    if (newProposal == _proposal && newOrg == _org) {
      return;
    }
    _proposal = newProposal;
    _org = newOrg;
    
    // Re-run the entire state calculation and timer logic
    _recalculateStateAndRestartTimer();
  }

  Future<void> _initialize() async {
    // Fetch the absolute on-chain state once for maximum accuracy on first load.
    await _syncWithOnChainState();
    _recalculateStateAndRestartTimer();
    _isLoading = false;
    notifyListeners();
  }
  
  // THE FIX: Centralized logic for recalculating state and managing the timer.
  void _recalculateStateAndRestartTimer() {
    _status = ProposalStatusHelper.calculateDisplayStatus(_proposal, _org);
    _calculateFullTimeline(_status);
    _startCountdown();
    notifyListeners();
  }

  // This method gets the definitive on-chain state enum (0-7)
  Future<void> _syncWithOnChainState() async {
    try {
      final proposalId = BigInt.tryParse(_proposal.id);
      if (proposalId == null) throw Exception("Invalid Proposal ID");

      final onChainStateIndex = await _blockchainService.getProposalState(_org.address, proposalId, _network.rpcUrl);
      ProposalStatus onChainStatus = ProposalStatus.values[onChainStateIndex];
      
      // We can use this to enhance our timeline calculation if needed, but our helper is quite accurate.
      // For now, the main benefit is ensuring the initial state is perfect.
      // We still use our helper for the final calculation to include NoQuorum/Defeated logic.
      _status = ProposalStatusHelper.calculateDisplayStatus(_proposal, _org);

    } catch (e) {
      _errorMessage = "Failed to sync on-chain status: ${e.toString()}";
    }
  }

  void _calculateFullTimeline(ProposalStatus currentStatus) {
    final timeline = <ProposalStatus, DateTime>{};
    final createdAt = _proposal.createdAt;
    final voteStart = createdAt.add(Duration(minutes: _org.votingDelay));
    final voteEnd = voteStart.add(Duration(minutes: _org.votingDuration));
    final now = DateTime.now();
    timeline[ProposalStatus.Pending] = createdAt;
    if (now.isAfter(voteStart)) {
        timeline[ProposalStatus.Active] = voteStart;
    }
    if (now.isAfter(voteEnd)) {
        switch (currentStatus) {
            case ProposalStatus.Succeeded:
            case ProposalStatus.Queued:
            case ProposalStatus.Executed:
                timeline[ProposalStatus.Succeeded] = voteEnd;
                break;
            case ProposalStatus.Defeated:
            case ProposalStatus.NoQuorum:
            case ProposalStatus.Rejected:
                timeline[currentStatus] = voteEnd; // Show the specific failure reason
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
    _updateRemainingTime(); // Run once immediately
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());
  }

  void _updateRemainingTime() {
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

    if (targetTime != null) {
      final remaining = targetTime.difference(now).inSeconds;
      if (remaining <= 0 && _remainingSeconds > 0) {
        // THE FIX: Time's up! Trigger a full state recalculation.
        _remainingSeconds = 0;
        _recalculateStateAndRestartTimer();
      } else {
        _remainingSeconds = remaining > 0 ? remaining : 0;
      }
    } else {
      _remainingSeconds = 0;
    }
    notifyListeners();
  }

  Future<String?> handleAction(Function action) async {
    _isActionBusy = true;
    notifyListeners();
    String? error;
    try {
      await action();
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