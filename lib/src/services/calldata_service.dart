// lib/src/services/calldata_service.dart
import 'dart:typed_data';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class CalldataService {
  // --- Contract Function Definitions ---

  // THE FIX: The correct function name is "editRegistry" and the second parameter is "Value".
  static const editRegistryDef = ContractFunction(
    "editRegistry", [ 
      FunctionParameter("key", StringType()), 
      FunctionParameter("Value", StringType()),
    ],
  );

  static const transferNativeDef = ContractFunction(
    "transferETH", [ FunctionParameter("to", AddressType()), FunctionParameter("amount", UintType()), ],
  );

  static const changeQuorumDef = ContractFunction(
    "updateQuorumNumerator", [ FunctionParameter("newQuorumNumerator", UintType()), ],
  );

  static const changeVotingDelayDef = ContractFunction(
    "setVotingDelay", [ FunctionParameter("newVotingDelay", UintType(length: 48)), ],
  );

  static const changeVotingPeriodDef = ContractFunction(
    "setVotingPeriod", [ FunctionParameter("newVotingPeriod", UintType(length: 32)), ],
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
  
  // --- Encoding Logic ---

  Uint8List encodeRegistryCall(String key, String value) {
    return editRegistryDef.encodeCall([key, value]);
  }

  // --- Decoding Logic ---
  
  List<dynamic> decodeCalldata(ContractFunction functionAbi, String hexCalldata) {
    if (hexCalldata.startsWith('0x')) {
      hexCalldata = hexCalldata.substring(2);
    }
    
    final dataBytes = hexToBytes(hexCalldata).sublist(4);

    final decoded = <dynamic>[];
    var offset = 0;

    for (final param in functionAbi.parameters) {
      final chunk = dataBytes.sublist(offset, offset + 32);

      if (param.type is AddressType) {
        final address = EthereumAddress(chunk.sublist(12));
        decoded.add(address.hex);
      } else if (param.type is UintType) {
        final value = bytesToInt(chunk);
        decoded.add(value);
      } else {
        throw UnsupportedError("This simple decoder only supports Address and Uint types.");
      }
      
      offset += 32;
    }
    
    return decoded;
  }

  List<String> decodeRegistryCalldata(String hexCalldata) {
    try {
      if (hexCalldata.startsWith('0x')) {
        hexCalldata = hexCalldata.substring(2);
      }
      Uint8List dataBytes = hexToBytes(hexCalldata);
      Uint8List dataWithoutSelector = dataBytes.sublist(4);

      int offset1 = bytesToInt(dataWithoutSelector.sublist(0, 32)).toInt();
      int offset2 = bytesToInt(dataWithoutSelector.sublist(32, 64)).toInt();

      int len1 = bytesToInt(dataWithoutSelector.sublist(offset1, offset1 + 32)).toInt();
      String str1 = String.fromCharCodes(dataWithoutSelector.sublist(offset1 + 32, offset1 + 32 + len1));

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