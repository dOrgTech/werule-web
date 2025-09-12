class Token {
  Token(
      {required this.name,
      required this.symbol,
      required this.decimals,
      required this.type,
      this.address});

  String? address;
  String? underlyingAddress;
  int? tokenId;
  String iconUrl = '';
  late String name;
  late String symbol;
  int? decimals;
  String? type;

  Token.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    symbol = json['symbol'];
    type = json['type'];
    decimals = json['decimals'] != null ? json['decimals'] as int : null;
    address = json['address'];
  }

  @override
  String toString() {
    return 'Token(name: $name, address: $address, symbol: $symbol, type: $type, decimals: $decimals)';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'type': type,
      'decimals': decimals,
      'address': address,
    };
  }
}
