// lib/src/providers/member_provider.dart
import 'package:flutter/material.dart';
import 'package:werule/src/models/member_activity.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/services/members_service.dart';

class MemberProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final FirestoreService _firestoreService;
  final BlockchainService _blockchainService;
  final MembersService _membersService;
  final Org _org;
  final Network _network;

  MemberProvider({
    required AuthProvider authProvider,
    required FirestoreService firestoreService,
    required BlockchainService blockchainService,
    required MembersService membersService,
    required Org org,
    required Network network,
  })  : _authProvider = authProvider,
        _firestoreService = firestoreService,
        _blockchainService = blockchainService,
        _membersService = membersService,
        _org = org,
        _network = network {
    fetchMemberData();
  }

  // --- State ---
  bool _isLoading = true;
  String? _errorMessage;
  // THE FIX: Use the new MemberActivity model.
  MemberActivity _memberActivity = MemberActivity.empty();
  BigInt _personalBalance = BigInt.zero;
  BigInt _votingWeight = BigInt.zero;
  String? _delegateAddress;
  List<Proposal> _createdProposalDetails = [];
  List<Proposal> _votedProposalDetails = [];
  bool _isActionBusy = false;

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isActionBusy => _isActionBusy;
  String? get errorMessage => _errorMessage;
  // THE FIX: Get counts from the new model.
  int get proposalsCreatedCount => _memberActivity.proposalsCreated.length;
  int get votesCastCount => _memberActivity.proposalsVoted.length;
  BigInt get personalBalance => _personalBalance;
  BigInt get votingWeight => _votingWeight;
  String? get delegateAddress => _delegateAddress;
  List<Proposal> get createdProposalDetails => _createdProposalDetails;
  List<Proposal> get votedProposalDetails => _votedProposalDetails;

  Future<void> fetchMemberData() async {
    final userAddress = _authProvider.selectedAccount;
    if (userAddress == null) {
      _errorMessage = "User is not connected.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (!_isLoading) {
      _isActionBusy = true;
      notifyListeners();
    }

    try {
      final membersData = await _membersService.getMembers(_org.govTokenAddress, _network.blockExplorerUrl);
      final items = membersData['items'] as List<dynamic>? ?? [];
      
      String? checksumAddress;
      
      items.firstWhere(
        (item) {
          final hash = item['address']?['hash'] as String?;
          if (hash != null && hash.toLowerCase() == userAddress.toLowerCase()) {
            checksumAddress = hash;
            _personalBalance = BigInt.tryParse(item['value'] ?? '0') ?? BigInt.zero;
            return true;
          }
          return false;
        },
        orElse: () => null,
      );

      if (checksumAddress != null) {
        final results = await Future.wait([
          // THE FIX: Call the new service method.
          _firestoreService.getMemberActivity(_network.daoCollectionName, _org.address, checksumAddress!),
          _blockchainService.getVotes(_org.govTokenAddress, userAddress, _network.rpcUrl),
          _firestoreService.getProposals(_network.daoCollectionName, _org.address),
          _blockchainService.getDelegate(_org.govTokenAddress, userAddress, _network.rpcUrl),
        ]);
        // THE FIX: Assign to the new MemberActivity property.
        _memberActivity = results[0] as MemberActivity;
        _votingWeight = results[1] as BigInt;
        final allProposals = results[2] as List<Proposal>;
        _delegateAddress = results[3] as String?;
        
        // THE FIX: Use the new property to get the proposal IDs.
        final createdIds = _memberActivity.proposalsCreated.toSet();
        final votedIds = _memberActivity.proposalsVoted.toSet();

        _createdProposalDetails = allProposals.where((p) => createdIds.contains(p.id)).toList();
        _votedProposalDetails = allProposals.where((p) => votedIds.contains(p.id)).toList();

      } else {
        _personalBalance = BigInt.zero;
        _votingWeight = BigInt.zero;
        _memberActivity = MemberActivity.empty();
        _delegateAddress = await _blockchainService.getDelegate(_org.govTokenAddress, userAddress, _network.rpcUrl);
      }

    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    _isActionBusy = false;
    notifyListeners();
  }

  Future<String?> handleDelegate(String delegateeAddress) async {
    _isActionBusy = true;
    notifyListeners();
    String? error;
    try {
      await _blockchainService.delegate(_org.govTokenAddress, delegateeAddress);
      await Future.delayed(const Duration(seconds: 3));
      await fetchMemberData();
    } catch (e) {
      error = e.toString();
    }
    _isActionBusy = false;
    notifyListeners();
    return error;
  }
}
// lib/src/providers/member_provider.dart