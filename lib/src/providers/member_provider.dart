// lib/src/providers/member_provider.dart
import 'package:flutter/material.dart';
import 'package:werule/src/models/account_details.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
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
  AccountDetails _accountDetails = AccountDetails.empty();
  BigInt _personalBalance = BigInt.zero;
  BigInt _votingWeight = BigInt.zero;

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get proposalsCreatedCount => _accountDetails.proposalsCreated.length;
  int get votesCastCount => _accountDetails.proposalsVoted.length;
  BigInt get personalBalance => _personalBalance;
  BigInt get votingWeight => _votingWeight;

  Future<void> fetchMemberData() async {
    final userAddress = _authProvider.selectedAccount;
    if (userAddress == null) {
      _errorMessage = "User is not connected.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // THE FIX: Change the order of operations.
      // 1. Fetch all members first to get the correctly-cased address.
      final membersData = await _membersService.getMembers(_org.govTokenAddress, _network.blockExplorerUrl);
      final items = membersData['items'] as List<dynamic>? ?? [];
      
      String? checksumAddress;
      
      // 2. Find the user in the list via a case-insensitive search.
      final currentUserData = items.firstWhere(
        (item) {
          final hash = item['address']?['hash'] as String?;
          if (hash != null && hash.toLowerCase() == userAddress.toLowerCase()) {
            // 3. If found, store the correctly-cased address and their balance.
            checksumAddress = hash;
            _personalBalance = BigInt.tryParse(item['value'] ?? '0') ?? BigInt.zero;
            return true;
          }
          return false;
        },
        orElse: () => null,
      );

      // 4. If the user is a member (found in the list)...
      if (checksumAddress != null) {
        // ...then fetch their on-chain votes and Firestore details concurrently.
        final results = await Future.wait([
          _firestoreService.getMemberDetails(_network.daoCollectionName, _org.address, checksumAddress!),
          _blockchainService.getVotes(_org.govTokenAddress, userAddress, _network.rpcUrl),
        ]);
        _accountDetails = results[0] as AccountDetails;
        _votingWeight = results[1] as BigInt;
      } else {
        // User is not a token holder, so they have no activity.
        _personalBalance = BigInt.zero;
        _votingWeight = BigInt.zero;
        _accountDetails = AccountDetails.empty();
      }

    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
// lib/src/providers/member_provider.dart