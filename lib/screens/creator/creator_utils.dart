// lib/screens/creator/creator_utils.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pointycastle/digests/keccak.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

String toChecksumAddress(String address) {
  address = address.replaceFirst('0x', '').toLowerCase();
  var hashedAddress = keccak256(utf8.encode(address));
  var hashString = bytesToHex(hashedAddress);
  String checksummedAddress = '0x';
  for (int i = 0; i < address.length; i++) {
    if (int.parse(hashString[i], radix: 16) >= 8) {
      checksummedAddress += address[i].toUpperCase();
    } else {
      checksummedAddress += address[i];
    }
  }
  return checksummedAddress;
}

List<int> keccak256(List<int> input) {
  final keccak = KeccakDigest(256);
  return keccak.process(Uint8List.fromList(input));
}

String bytesToHex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
}

enum DaoTokenDeploymentMechanism {
  deployNewStandardToken,
  wrapExistingToken,
}
// lib/screens/creator/creator_utils.dart
