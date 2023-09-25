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
  
  final colorPalette = List.generate(5, (_) => img.getColor(random.nextInt(256), random.nextInt(256), random.nextInt(256)));
  
  for (var x = 0; x < size ~/ 2; x += pixelSize) {
    for (var y = 0; y < size; y += pixelSize) {
      final color = colorPalette[random.nextInt(colorPalette.length)];
      img.fillRect(image, x, y, x + pixelSize, y + pixelSize, color);
      img.fillRect(image, size - x - pixelSize, y, size - x, y + pixelSize, color);
    }
  }
  
  final pngBytes = img.encodePng(image);
  final byteData = pngBytes != null ? ByteData.view(Uint8List.fromList(pngBytes).buffer) : null;
  
  return byteData != null ? Image.memory(byteData.buffer.asUint8List()) : Container(width: size.toDouble(), height: size.toDouble(), color: Colors.grey);
}



String hashString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
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


String generateContractAddress(){
  final random = Random();
  final characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final prefix = 'KT1';
  final length = 36 - prefix.length;
  final randomString = String.fromCharCodes(Iterable.generate(
      length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  return prefix + randomString;
}



Future<Uint8List> generateAvatarAsync(String hash, {int size = 40, int pixelSize = 5}) async {
  final random = Random(hash.hashCode);
  final image = img.Image(size, size);
  
  final colorPalette = List.generate(5, (_) => img.getColor(random.nextInt(256), random.nextInt(256), random.nextInt(256)));
  
  for (var x = 0; x < size ~/ 2; x += pixelSize) {
    for (var y = 0; y < size; y += pixelSize) {
      final color = colorPalette[random.nextInt(colorPalette.length)];
      img.fillRect(image, x, y, x + pixelSize, y + pixelSize, color);
      img.fillRect(image, size - x - pixelSize, y, size - x, y + pixelSize, color);
    }
  }
  
    final pngBytes = img.encodePng(image);
  return Future.value(pngBytes as FutureOr<Uint8List>?);
}





