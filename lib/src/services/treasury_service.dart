// lib/src/services/treasury_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_web3/flutter_web3.dart';

class TreasuryService {

  Future<BigInt> getNativeBalance(String address, String rpcUrl) async {
    if (rpcUrl.isEmpty) {
      print("[TreasuryService] RPC URL is empty.");
      return BigInt.zero;
    }

    String fullRpcUrl = rpcUrl;
    if (!rpcUrl.startsWith('http')) {
      fullRpcUrl = 'https://$rpcUrl';
    }

  
    final provider = JsonRpcProvider(fullRpcUrl);
    try {
      final balance = await provider.getBalance(address);
      return balance;
    } catch (e) {
      print("[TreasuryService] Error getting native balance via RPC: $e");
      return BigInt.zero;
    }
  }

  Future<List<dynamic>> getTokenBalances(String address, String blockExplorerUrl) async {
    if (blockExplorerUrl.isEmpty) {
      print("[TreasuryService] Block Explorer URL is empty.");
      return [];
    }

    String fullExplorerUrl = blockExplorerUrl;
    if (!blockExplorerUrl.startsWith('http')) {
      fullExplorerUrl = 'https://$fullExplorerUrl';
    }

    final url = Uri.parse('$fullExplorerUrl/api/v2/addresses/$address/token-balances');
    
   
    
    try {
      final response = await http.get(url, headers: {'accept': 'application/json'});
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        print('[TreasuryService] Blockscout request for tokens failed with status: ${response.statusCode}.');
        return [];
      }
    } catch (e) {
      print('[TreasuryService] Error fetching token balances: $e');
      return [];
    }
  }
}
// lib/src/services/treasury_service.dart