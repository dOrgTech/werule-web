// lib/src/utils/proposal_status_helper.dart
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';

class ProposalStatusHelper {
  /// Calculates the current display status of a proposal synchronously.
  /// It uses the last known event-based status from Firestore as a baseline
  /// and applies time-based logic for transitions like Pending -> Active,
  /// and vote-based logic for final states like Succeeded or Defeated.
  static ProposalStatus calculateDisplayStatus(Proposal proposal, Org org) {
    ProposalStatus lastKnownStatus = _getLatestStatusFromHistory(proposal);

    final now = DateTime.now();
    final voteStart = proposal.createdAt.add(Duration(minutes: org.votingDelay));
    final voteEnd = voteStart.add(Duration(minutes: org.votingDuration));
    
    // If the last known status is a final one, no more calculation is needed.
    if (_isFinalStatus(lastKnownStatus)) {
      return lastKnownStatus;
    }

    // If the proposal was queued, check if it's become executable.
    if (lastKnownStatus == ProposalStatus.Queued) {
      final queuedTime = proposal.statusHistory['queued'] ?? voteEnd;
      final executionETA = queuedTime.add(Duration(seconds: org.executionDelay));
      if (now.isAfter(executionETA)) {
        return ProposalStatus.Executable;
      }
      return ProposalStatus.Queued;
    }

    // If the voting period is over...
    if (now.isAfter(voteEnd)) {
      // First, check if the indexer has already given us a more definitive final status.
      if (lastKnownStatus == ProposalStatus.Succeeded || lastKnownStatus == ProposalStatus.Defeated) {
          return lastKnownStatus;
      }

      final totalSupplyAtVoteStart = BigInt.tryParse(proposal.totalSupply) ?? BigInt.zero;
      
      // If for some reason we don't have this data, we can't determine the outcome.
      if (totalSupplyAtVoteStart == BigInt.zero) {
        return ProposalStatus.Expired;
      }

      // 1. Check for Quorum
      final quorumVotes = (totalSupplyAtVoteStart * BigInt.from(org.quorum)) ~/ BigInt.from(100);
      final totalVotes = proposal.inFavor + proposal.against;

      if (totalVotes < quorumVotes) {
        return ProposalStatus.NoQuorum;
      }

      // 2. Check Vote Outcome
      if (proposal.inFavor > proposal.against) {
        return ProposalStatus.Succeeded;
      } else {
        // A tie or loss is a defeat in the OpenZeppelin Governor model.
        return ProposalStatus.Defeated;
      }
    }

    // If voting is currently active...
    if (now.isAfter(voteStart)) {
      return ProposalStatus.Active;
    }

    // Otherwise, it must still be pending.
    return ProposalStatus.Pending;
  }

  /// Finds the latest status from the proposal's history map.
  static ProposalStatus _getLatestStatusFromHistory(Proposal proposal) {
    if (proposal.statusHistory.isEmpty) {
      return ProposalStatus.Pending;
    }
    var latestEntry = proposal.statusHistory.entries.reduce((a, b) => a.value.isAfter(b.value) ? a : b);
    
    switch (latestEntry.key.toLowerCase()) {
      case 'active': return ProposalStatus.Active;
      case 'succeeded': return ProposalStatus.Succeeded;
      case 'passed': return ProposalStatus.Succeeded;
      case 'queued': return ProposalStatus.Queued;
      case 'executable': return ProposalStatus.Executable;
      case 'executed': return ProposalStatus.Executed;
      case 'expired': return ProposalStatus.Expired;
      case 'no quorum': return ProposalStatus.NoQuorum;
      case 'pending': return ProposalStatus.Pending;
      case 'rejected': return ProposalStatus.Rejected;
      case 'defeated': return ProposalStatus.Defeated;
      default: return ProposalStatus.Pending;
    }
  }

  /// Checks if a status is terminal (i.e., it cannot change further).
  static bool _isFinalStatus(ProposalStatus status) {
    return status == ProposalStatus.Executed ||
           status == ProposalStatus.Rejected ||
           status == ProposalStatus.NoQuorum ||
           status == ProposalStatus.Defeated ||
           status == ProposalStatus.Canceled;
  }
}
// lib/src/utils/proposal_status_helper.dart