// lib/src/services/members_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MembersService {
  Future<Map<String, dynamic>> getMembers(String tokenAddress, String blockExplorerUrl) async {
    if (blockExplorerUrl.isEmpty) {
      throw Exception('Block Explorer URL is not configured.');
    }
    if (tokenAddress.isEmpty) {
      throw Exception('Governance token address is not configured for this DAO.');
    }

    String fullExplorerUrl = blockExplorerUrl;
    if (!blockExplorerUrl.startsWith('http')) {
      fullExplorerUrl = 'https://$blockExplorerUrl';
    }

    final url = Uri.parse('$fullExplorerUrl/api/v2/tokens/$tokenAddress/holders');
    
    try {
      final response = await http.get(url, headers: {'accept': 'application/json'});
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load members with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('[MembersService] Error fetching members: $e');
      rethrow;
    }
  }
}
// lib/src/services/members_service.dart