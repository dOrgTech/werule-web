// ignore_for_file: avoid_print

import 'package:Homebase/entities/human.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

getBalances(address) async {
  var url = Uri.parse(Human().chain.blockExplorer +
      '/api/v2/addresses/$address/token-balances');
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
