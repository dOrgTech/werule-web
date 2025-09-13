// lib/src/models/member.dart

class Member {
  final String address;
  final String balance;

  Member({required this.address, required this.balance});

  factory Member.fromBlockscout(Map<String, dynamic> json) {
    return Member(
      address: json['address']?['hash'] ?? 'Unknown Address',
      balance: json['value'] ?? '0',
    );
  }
}
// lib/src/models/member.dart