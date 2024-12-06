import 'dart:async';
import "package:flutter/material.dart";
import 'dart:math';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'dart:ui';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

Widget generateAvatar(String hash, {int size = 100, int pixelSize = 10}) {
  final random = Random(hash.hashCode);
  final image = img.Image(size, size);

  final colorPalette = List.generate(
      5,
      (_) => img.getColor(
          random.nextInt(256), random.nextInt(256), random.nextInt(256)));

  for (var x = 0; x < size ~/ 2; x += pixelSize) {
    for (var y = 0; y < size; y += pixelSize) {
      final color = colorPalette[random.nextInt(colorPalette.length)];
      img.fillRect(image, x, y, x + pixelSize, y + pixelSize, color);
      img.fillRect(
          image, size - x - pixelSize, y, size - x, y + pixelSize, color);
    }
  }

  final pngBytes = img.encodePng(image);
  final byteData = pngBytes != null
      ? ByteData.view(Uint8List.fromList(pngBytes).buffer)
      : null;

  return byteData != null
      ? Image.memory(byteData.buffer.asUint8List())
      : Container(
          width: size.toDouble(), height: size.toDouble(), color: Colors.grey);
}

String parseNumber(String numberString, int decimalPlaces) {
  // Convert the input string to a BigInt
  BigInt number = BigInt.parse(numberString);

  // Compute the divisor = 10^decimalPlaces
  BigInt divisor = BigInt.from(10).pow(decimalPlaces);

  // Get the integer (quotient) and remainder parts
  BigInt quotient = number ~/ divisor;
  BigInt remainder = number % divisor;

  // If there's no remainder, just return the integer part
  if (remainder == BigInt.zero) {
    return quotient.toString();
  }

  // Convert remainder to a string with leading zeros to ensure it has 'decimalPlaces' length
  String fractionStr = remainder.toString().padLeft(decimalPlaces, '0');

  // Remove trailing zeros in the fractional part
  fractionStr = fractionStr.replaceAll(RegExp(r'0+$'), '');

  // If after removing trailing zeros there's nothing left, return just the integer part
  if (fractionStr.isEmpty) {
    return quotient.toString();
  }

  // If fraction part is longer than 2 digits, truncate to 2 digits
  if (fractionStr.length > 2) {
    fractionStr = fractionStr.substring(0, 2);
  }

  // Return the combined result
  return quotient.toString() + "." + fractionStr;
}

String shortenString(String input) {
  if (input.length <= 8) {
    return input;
  } else {
    return input.substring(0, 5) + "..." + input.substring(input.length - 5);
  }
}

String generateWalletAddress() {
  final random = Random();
  final characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final prefix = 'tz1';
  final length = 36 - prefix.length;
  final randomString = String.fromCharCodes(Iterable.generate(
      length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  return prefix + randomString;
}

String generateContractAddress() {
  final random = Random();
  final characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final prefix = 'KT1';
  final length = 36 - prefix.length;
  final randomString = String.fromCharCodes(Iterable.generate(
      length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  return prefix + randomString;
}
