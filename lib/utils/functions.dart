import 'dart:async';
import "package:flutter/material.dart";
import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

Future<Uint8List> generateAvatarAsync(String hash,
    {int size = 100, int pixelSize = 10}) async {
  final random = Random(hash.hashCode);
  final avatar = img.Image(width: size, height: size);

  final palette = List<int>.generate(5, (_) {
    final r = random.nextInt(256);
    final g = random.nextInt(256);
    final b = random.nextInt(256);
    return (255 << 24) | (r << 16) | (g << 8) | b;
  });

  for (var x = 0; x < size ~/ 2; x += pixelSize) {
    for (var y = 0; y < size; y += pixelSize) {
      final colorInt = palette[random.nextInt(palette.length)];
      final r = (colorInt >> 16) & 0xFF;
      final g = (colorInt >> 8) & 0xFF;
      final b = colorInt & 0xFF;

      for (var dx = 0; dx < pixelSize; dx++) {
        for (var dy = 0; dy < pixelSize; dy++) {
          avatar.getPixel(x + dx, y + dy).setRgb(r, g, b);
          avatar.getPixel(size - x - pixelSize + dx, y + dy).setRgb(r, g, b);
        }
      }
    }
  }

  final pngBytes = img.encodePng(avatar);
  return Uint8List.fromList(pngBytes);
}



String convertEthToWei(double ethValue) {
  BigInt weiValue = BigInt.from(ethValue * pow(10, 18));
  return weiValue.toString();
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
  return "$quotient.$fractionStr";
}

String shortenString(String input) {
  if (input.length <= 8) {
    return input;
  } else {
    return "${input.substring(0, 5)}...${input.substring(input.length - 5)}";
  }
}

String generateWalletAddress() {
  final random = Random();
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  const prefix = 'tz1';
  final length = 36 - prefix.length;
  final randomString = String.fromCharCodes(Iterable.generate(
      length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  return prefix + randomString;
}

String generateContractAddress() {
  final random = Random();
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  const prefix = 'KT1';
  final length = 36 - prefix.length;
  final randomString = String.fromCharCodes(Iterable.generate(
      length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  return prefix + randomString;
}
