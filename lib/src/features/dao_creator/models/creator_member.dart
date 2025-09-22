// lib/src/features/dao_creator/models/creator_member.dart
class Member {
  final String address;
  final int amount; // Amount without decimals
  final String? personalBalance; // String representation with decimals
  final String votingWeight;

  Member({
    required this.address,
    required this.amount,
    this.personalBalance,
    required this.votingWeight,
  });
}
// lib/src/features/dao_creator/models/creator_member.dart