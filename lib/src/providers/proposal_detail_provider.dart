// lib/src/providers/proposal_detail_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/utils/proposal_status_helper.dart';

class ProposalDetailProvider extends ChangeNotifier {
  final BlockchainService _blockchainService;
  late Proposal _proposal; 
  late Org _org;
  final Network _network;
  Timer? _countdownTimer;
  bool _isRecalculating = false;

  ProposalDetailProvider({
    required BlockchainService blockchainService,
    required Proposal proposal,
    required Org org,
    required Network network,
  })  : _blockchainService = blockchainService,
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

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isActionBusy => _isActionBusy;
  String? get errorMessage => _errorMessage;
  ProposalStatus get status => _status;
  Proposal get proposal => _proposal;
  int get remainingSeconds => _remainingSeconds;
  bool get showCountdown => _status == ProposalStatus.Pending || _status == ProposalStatus.Active || _status == ProposalStatus.Queued;
  Map<ProposalStatus, DateTime> get fullTimeline => _fullTimeline;
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
    await _syncWithOnChainState();
    _recalculateStateAndRestartTimer();
    _isLoading = false;
  }
  
  void _recalculateStateAndRestartTimer() {
    _status = ProposalStatusHelper.calculateDisplayStatus(_proposal, _org);
    _calculateFullTimeline(_status);
    _startCountdown();
    notifyListeners();
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