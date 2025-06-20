// ignore_for_file: avoid_print

import 'package:Homebase/entities/human.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

getBalances(address) async {
  var url = Uri.parse('${Human().chain.blockExplorer}/api/v2/addresses/$address/token-balances');
  // var url = 'https://testnet.explorer.etherlink.com/api/v2/addresses/$address/token-balances' ;
  var headers = {
    'accept': 'application/json',
  };
  var response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data;
  } else {
    print('Blockscout request failed with status: ${response.statusCode}.');
    return "null";
  }
}


Future<Map<String, String>> getHolders(String tokenAddress) async {
  var url =
  Human().chain.blockExplorer +
      '/api/v2/tokens/$tokenAddress/holders';
  var headers = {
    'accept': 'application/json',
  };
  var response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    if (data is Map && data.containsKey('items')) {
      final items = data['items'];
      if (items is List) {
        return {
          for (final h in items)
            if (h is Map &&
                h.containsKey('address') &&
                h['address'] is Map &&
                h['address'].containsKey('hash') &&
                h.containsKey('value'))
              h['address']['hash'] as String: h['value'].toString()
        };
      }
    }
    return {};
  } else {
    print('Blockscout request failed with status: ${response.statusCode}.');
    return {};
  }
}