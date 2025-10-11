// lib/src/services/calldata_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';


import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class CalldataService {
  // --- Contract Function Definitions ---

  static const editRegistryDef = ContractFunction(
    "editRegistry", [ 
      FunctionParameter("key", StringType()), 
      FunctionParameter("Value", StringType()),
    ],
  );

  static const transferNativeDef = ContractFunction(
    "transferETH", [ 
      FunctionParameter("to", AddressType()), 
      FunctionParameter("amount", UintType()), 
    ],
  );

  static const erc20TreasuryTransferDef = ContractFunction(
    "transferERC20", [
      FunctionParameter("token", AddressType()),
      FunctionParameter("to", AddressType()),
      FunctionParameter("amount", UintType()),
    ],
  );

  static Uint8List get transferNativeSelector => transferNativeDef.selector;
  static Uint8List get erc20TreasuryTransferSelector => erc20TreasuryTransferDef.selector;

  static const changeQuorumDef = ContractFunction(
    "updateQuorumNumerator", [ 
      FunctionParameter("newQuorumNumerator", UintType()), 
    ],
  );

  static const changeVotingDelayDef = ContractFunction(
    "setVotingDelay", [ 
      FunctionParameter("newVotingDelay", UintType(length: 48)), 
    ],
  );

  static const changeVotingPeriodDef = ContractFunction(
    "setVotingPeriod", [ 
      FunctionParameter("newVotingPeriod", UintType(length: 32)), 
    ],
  );
  
  static const changeProposalThresholdDef = ContractFunction(
    "setProposalThreshold", [ 
      FunctionParameter("newProposalThreshold", UintType()), 
    ],
  );

  static const mintGovTokensDef = ContractFunction(
    "mint", [ 
      FunctionParameter("to", AddressType()), 
      FunctionParameter("amount", UintType()), 
    ],
  );

  static const burnGovTokensDef = ContractFunction(
    "burn", [ 
      FunctionParameter("from", AddressType()), 
      FunctionParameter("amount", UintType()), 
    ],
  );
  
  // --- Encoding Logic ---

  Uint8List encodeRegistryCall(String key, String value) {
    return editRegistryDef.encodeCall([key, value]);
  }

  Uint8List encodeTransferCall(EthereumAddress to, BigInt amount) {
    return transferNativeDef.encodeCall([to, amount]);
  }

  Uint8List encodeErc20TreasuryTransferCall(EthereumAddress token, EthereumAddress to, BigInt amount) {
    return erc20TreasuryTransferDef.encodeCall([token, to, amount]);
  }

  Uint8List encodeMintCall(EthereumAddress to, BigInt amount) {
    return mintGovTokensDef.encodeCall([to, amount]);
  }
  
  Uint8List encodeBurnCall(EthereumAddress from, BigInt amount) {
    return burnGovTokensDef.encodeCall([from, amount]);
  }

  Uint8List encodeQuorumCall(BigInt newQuorum) {
    return changeQuorumDef.encodeCall([newQuorum]);
  }

  Uint8List encodeVotingDelayCall(BigInt newDelay) {
    return changeVotingDelayDef.encodeCall([newDelay]);
  }

  Uint8List encodeVotingPeriodCall(BigInt newPeriod) {
    return changeVotingPeriodDef.encodeCall([newPeriod]);
  }

  Uint8List encodeThresholdCall(BigInt newThreshold) {
    return changeProposalThresholdDef.encodeCall([newThreshold]);
  }
  
  // --- NEW: Arbitrary Contract Call Logic (CORRECTED) ---

  /// THE FIX: This function is now public so the UI can use it to build the form.
  /// It dynamically creates a `ContractFunction` object from a signature string.
  ContractFunction _parseDynamicFunction(String signature) {
    final funcNameMatch = RegExp(r'\s*(\w+)\s*\(').firstMatch(signature);
    if (funcNameMatch == null) throw const FormatException('Invalid signature: cannot find function name');
    final funcName = funcNameMatch.group(1)!;

    final paramsMatch = RegExp(r'\((.*)\)').firstMatch(signature);
    if (paramsMatch == null) throw const FormatException('Invalid signature: missing parentheses');
    
    final paramsString = paramsMatch.group(1)!.trim();
    final paramParts = paramsString.isEmpty ? <String>[] : paramsString.split(',').map((p) => p.trim()).toList();

    final inputs = [];
    for (int i = 0; i < paramParts.length; i++) {
        final type = paramParts[i].split(' ').last;
        inputs.add({
            "name": "param$i",
            "type": type,
            "internalType": type,
        });
    }

    final abiJson = [{
        "type": "function",
        "name": funcName,
        "inputs": inputs,
        "outputs": [],
        "stateMutability": "nonpayable"
    }];

    final abi = ContractAbi.fromJson(json.encode(abiJson), 'DynamicFunction');
    return abi.functions.first;
  }
  
  /// Public method for the UI to get the parameter types from a signature.
  List<FunctionParameter> getParametersFromSignature(String signature) {
    if (signature.trim().isEmpty) return [];
    final function = _parseDynamicFunction(signature);
    return function.parameters;
  }

  /// Encodes the arbitrary function call using the dynamic parser.
  Uint8List encodeArbitraryFunctionCall(String signature, List<String> paramValues) {
    final function = _parseDynamicFunction(signature);
    
    if (function.parameters.length != paramValues.length) {
      throw ArgumentError('Mismatched number of parameters and values.');
    }

    final convertedValues = [];
    for (int i = 0; i < paramValues.length; i++) {
        final paramType = function.parameters[i].type;
        final stringValue = paramValues[i];
        final typeName = paramType.name;

        if (typeName == 'address') {
            convertedValues.add(EthereumAddress.fromHex(stringValue));
        } else if (typeName.startsWith('uint') || typeName.startsWith('int')) {
            convertedValues.add(BigInt.parse(stringValue));
        } else if (typeName == 'bool') {
            convertedValues.add(stringValue.toLowerCase() == 'true');
        } else if (typeName == 'string') {
            convertedValues.add(stringValue);
        } else if (typeName.startsWith('bytes')) {
            final hex = stringValue.startsWith('0x') ? stringValue.substring(2) : stringValue;
            convertedValues.add(hexToBytes(hex));
        } else {
            throw ArgumentError('Unsupported ABI type for conversion: $typeName');
        }
    }

    return function.encodeCall(convertedValues);
  }


  // --- Decoding Logic ---

  List<dynamic> decodeQuorumCall(String hex) => decodeCalldata(changeQuorumDef, hex);
  List<dynamic> decodeVotingDelayCall(String hex) => decodeCalldata(changeVotingDelayDef, hex);
  List<dynamic> decodeVotingPeriodCall(String hex) => decodeCalldata(changeVotingPeriodDef, hex);
  List<dynamic> decodeThresholdCall(String hex) => decodeCalldata(changeProposalThresholdDef, hex);
  
  List<dynamic> decodeCalldata(ContractFunction functionAbi, String hexCalldata) {
    if (hexCalldata.startsWith('0x')) {
      hexCalldata = hexCalldata.substring(2);
    }
    
    final functionSelector = functionAbi.selector;
    final calldataBytes = hexToBytes(hexCalldata);
    
    if (!listEquals(calldataBytes.sublist(0, 4), functionSelector)) {
      throw const FormatException('Calldata does not match function selector.');
    }

    final dataBytes = calldataBytes.sublist(4);
    final decoded = <dynamic>[];
    var offset = 0;

    for (final param in functionAbi.parameters) {
      if (offset + 32 > dataBytes.length) {
        throw FormatException('Calldata is too short for parameter ${param.name}');
      }
      final chunk = dataBytes.sublist(offset, offset + 32);

      if (param.type is AddressType) {
        final address = EthereumAddress(chunk.sublist(12));
        decoded.add(address);
      } else if (param.type is UintType) {
        final value = bytesToInt(chunk);
        decoded.add(value);
      } else {
        throw UnsupportedError("Decoding for type ${param.type.name} is not supported.");
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
      if (kDebugMode) {
        print("Error decoding registry calldata: $e");
      }
      return ["<decoding error>", "<decoding error>"];
    }
  }
}
// lib/src/services/calldata_service.dart