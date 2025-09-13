// lib/src/providers/proposal_detail_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/services/blockchain_service.dart';

class ProposalDetailProvider extends ChangeNotifier {
  final BlockchainService _blockchainService;
  final Proposal _proposal;
  final Org _org;
  final Network _network;
  Timer? _countdownTimer;

  ProposalDetailProvider({
    required BlockchainService blockchainService,
    required Proposal proposal,
    required Org org,
    required Network network,
  })  : _blockchainService = blockchainService,
        _proposal = proposal,
        _org = org,
        _network = network {
    _initialize();
  }

  // --- State ---
  bool _isLoading = true;
  bool _isActionBusy = false;
  String? _errorMessage;
  ProposalStatus _status = ProposalStatus.Unknown;
  BigInt _onChainForVotes = BigInt.zero;
  BigInt _onChainAgainstVotes = BigInt.zero;
  int _remainingSeconds = 0;
  Map<ProposalStatus, DateTime> _fullTimeline = {};

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isActionBusy => _isActionBusy;
  String? get errorMessage => _errorMessage;
  ProposalStatus get status => _status;
  BigInt get onChainForVotes => _onChainForVotes;
  BigInt get onChainAgainstVotes => _onChainAgainstVotes;
  int get remainingSeconds => _remainingSeconds;
  bool get showCountdown => _status == ProposalStatus.Pending || _status == ProposalStatus.Active || _status == ProposalStatus.Queued;
  Map<ProposalStatus, DateTime> get fullTimeline => _fullTimeline;

  Future<void> _initialize() async {
    await determineProposalStatus();
    await _fetchOnChainVotes();
    _startCountdown();
    _isLoading = false;
    notifyListeners();
  }
  
  // --- Logic ---
  Future<void> determineProposalStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final proposalId = BigInt.tryParse(_proposal.id);
      if (proposalId == null) throw Exception("Invalid Proposal ID: ${_proposal.id}");

      final onChainStateIndex = await _blockchainService.getProposalState(_org.address, proposalId, _network.rpcUrl);
      ProposalStatus onChainStatus = ProposalStatus.values[onChainStateIndex];
      
      final now = DateTime.now();
      // THE FIX: Use `minutes` for votingDelay and votingDuration.
      final voteStart = _proposal.createdAt.add(Duration(minutes: _org.votingDelay));
      final voteEnd = voteStart.add(Duration(minutes: _org.votingDuration));

      if (onChainStatus == ProposalStatus.Defeated) {
        final totalVotes = _proposal.inFavor + _proposal.against;
        final quorumVotes = (BigInt.parse(_org.totalSupply) * BigInt.from(_org.quorum)) ~/ BigInt.from(100);
        _status = (totalVotes < quorumVotes) ? ProposalStatus.NoQuorum : ProposalStatus.Rejected;
      } else if (onChainStatus == ProposalStatus.Succeeded) {
        _status = ProposalStatus.Succeeded;
      } else if (onChainStatus == ProposalStatus.Queued) {
        final queuedTime = _proposal.statusHistory['queued'] ?? voteEnd;
        // THE FIX: Use `seconds` for executionDelay.
        final executionETA = queuedTime.add(Duration(seconds: _org.executionDelay));
        _status = now.isAfter(executionETA) ? ProposalStatus.Executable : ProposalStatus.Queued;
      } else {
        _status = onChainStatus;
      }

      _calculateFullTimeline(onChainStatus);

    } catch (e) {
      _errorMessage = "Failed to determine proposal status. ${e.toString()}";
      _status = ProposalStatus.Unknown;
    }

    _isLoading = false;
    notifyListeners();
  }

  void _calculateFullTimeline(ProposalStatus onChainStatus) {
    final timeline = <ProposalStatus, DateTime>{};

    // THE FIX: Use the correct time units (minutes) for voting calculations.
    final createdAt = _proposal.createdAt;
    final voteStart = createdAt.add(Duration(minutes: _org.votingDelay));
    final voteEnd = voteStart.add(Duration(minutes: _org.votingDuration));

    timeline[ProposalStatus.Pending] = createdAt;

    if (onChainStatus.index >= ProposalStatus.Active.index) {
        timeline[ProposalStatus.Active] = voteStart;
    }

    if (onChainStatus.index >= ProposalStatus.Canceled.index) {
        switch (onChainStatus) {
            case ProposalStatus.Succeeded:
            case ProposalStatus.Queued:
            case ProposalStatus.Executed:
                timeline[ProposalStatus.Succeeded] = voteEnd;
                break;
            case ProposalStatus.Defeated:
                timeline[_status] = voteEnd;
                break;
            case ProposalStatus.Canceled:
                 timeline[ProposalStatus.Canceled] = _proposal.statusHistory['canceled'] ?? voteEnd;
                 break;
            default:
                break;
        }
    }
    
    if (onChainStatus.index >= ProposalStatus.Queued.index) {
        timeline[ProposalStatus.Queued] = _proposal.statusHistory['queued'] ?? voteEnd;
    }
    if (onChainStatus.index >= ProposalStatus.Executed.index) {
       timeline[ProposalStatus.Executed] = _proposal.statusHistory['executed'] ?? DateTime.now();
    }

    _fullTimeline = timeline;
  }

  Future<void> _fetchOnChainVotes() async {
    try {
      final proposalId = BigInt.parse(_proposal.id);
      final votes = await _blockchainService.getProposalVotes(_org.address, proposalId, _network.rpcUrl);
      _onChainAgainstVotes = votes[0];
      _onChainForVotes = votes[1];
    } catch (e) {
      _errorMessage = "Failed to fetch on-chain votes. ${e.toString()}";
    }
    notifyListeners();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    DateTime? targetTime;

    // THE FIX: Use `minutes` for voting calculations here as well for consistency.
    final voteStart = _proposal.createdAt.add(Duration(minutes: _org.votingDelay));
    final voteEnd = voteStart.add(Duration(minutes: _org.votingDuration));

    if (_status == ProposalStatus.Pending) {
      targetTime = voteStart;
    } else if (_status == ProposalStatus.Active) {
      targetTime = voteEnd;
    } else if (_status == ProposalStatus.Queued) {
      final queuedTime = _proposal.statusHistory['queued'] ?? voteEnd;
      // THE FIX: Use `seconds` for execution delay.
      targetTime = queuedTime.add(Duration(seconds: _org.executionDelay));
    }

    if (targetTime != null) {
      final remaining = targetTime.difference(now).inSeconds;
      _remainingSeconds = remaining > 0 ? remaining : 0;
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
// lib/src/providers/proposal_detail_provider.dart```