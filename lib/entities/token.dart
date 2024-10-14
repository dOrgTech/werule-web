class Token {
  Token({
    required this.name,
    required this.symbol,
    required this.decimals,
  });

  String? address;
  late String name;
  late String symbol;
  int? decimals;

  Token.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    symbol = json['symbol'];
    decimals = json['decimals'] != null ? json['decimals'] as int : null;
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'decimals': decimals,
      'address': address,
    };
  }
}
