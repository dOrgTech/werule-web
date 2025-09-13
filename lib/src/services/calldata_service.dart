// lib/src/services/calldata_service.dart
import 'dart:typed_data';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class CalldataService {
  // --- Contract Function Definitions ---

  static const transferNativeDef = ContractFunction(
    "transferETH", [ FunctionParameter("to", AddressType()), FunctionParameter("amount", UintType()), ],
  );

  static const changeQuorumDef = ContractFunction(
    "updateQuorumNumerator", [ FunctionParameter("newQuorumNumerator", UintType()), ],
  );

  static const changeVotingDelayDef = ContractFunction(
    "setVotingDelay", [ FunctionParameter("newVotingDelay", UintType()), ],
  );

  static const changeVotingPeriodDef = ContractFunction(
    "setVotingPeriod", [ FunctionParameter("newVotingPeriod", UintType()), ],
  );
  
  static const changeProposalThresholdDef = ContractFunction(
    "setProposalThreshold", [ FunctionParameter("newProposalThreshold", UintType()), ],
  );

  static const mintGovTokensDef = ContractFunction(
    "mint", [ FunctionParameter("to", AddressType()), FunctionParameter("amount", UintType()), ],
  );

  static const burnGovTokensDef = ContractFunction(
    "burn", [ FunctionParameter("from", AddressType()), FunctionParameter("amount", UintType()), ],
  );

  // --- Decoding Logic ---
  
  // THE FIX: This is a robust decoder for simple, static-sized types like address and uint.
  // It avoids the internal `DecodingResult` API and manually processes the calldata buffer.
  List<dynamic> decodeCalldata(ContractFunction functionAbi, String hexCalldata) {
    if (hexCalldata.startsWith('0x')) {
      hexCalldata = hexCalldata.substring(2);
    }
    
    // Remove the 4-byte function selector
    final dataBytes = hexToBytes(hexCalldata).sublist(4);

    final decoded = <dynamic>[];
    var offset = 0;

    for (final param in functionAbi.parameters) {
      // Each static parameter occupies a 32-byte (64 hex characters) slot.
      final chunk = dataBytes.sublist(offset, offset + 32);

      if (param.type is AddressType) {
        // An address is the last 20 bytes of the 32-byte word.
        final address = EthereumAddress(chunk.sublist(12));
        decoded.add(address.hex);
      } else if (param.type is UintType) {
        final value = bytesToInt(chunk);
        decoded.add(value); // The result is a BigInt
      } else {
        throw UnsupportedError("This simple decoder only supports Address and Uint types.");
      }
      
      offset += 32; // Move to the next 32-byte slot.
    }
    
    return decoded;
  }

  /// A special decoder for registry proposals with two dynamic string parameters,
  /// matching the manual parsing logic from your old code.
  List<String> decodeRegistryCalldata(String hexCalldata) {
    try {
      if (hexCalldata.startsWith('0x')) {
        hexCalldata = hexCalldata.substring(2);
      }
      Uint8List dataBytes = hexToBytes(hexCalldata);
      Uint8List dataWithoutSelector = dataBytes.sublist(4);

      // Read the offsets for the two dynamic string parameters
      int offset1 = bytesToInt(dataWithoutSelector.sublist(0, 32)).toInt();
      int offset2 = bytesToInt(dataWithoutSelector.sublist(32, 64)).toInt();

      // Decode the first string
      int len1 = bytesToInt(dataWithoutSelector.sublist(offset1, offset1 + 32)).toInt();
      String str1 = String.fromCharCodes(dataWithoutSelector.sublist(offset1 + 32, offset1 + 32 + len1));

      // Decode the second string
      int len2 = bytesToInt(dataWithoutSelector.sublist(offset2, offset2 + 32)).toInt();
      String str2 = String.fromCharCodes(dataWithoutSelector.sublist(offset2 + 32, offset2 + 32 + len2));

      return [str1, str2];
    } catch (e) {
      print("Error decoding registry calldata: $e");
      return ["<decoding error>", "<decoding error>"];
    }
  }
}
// lib/src/services/calldata_service.dart