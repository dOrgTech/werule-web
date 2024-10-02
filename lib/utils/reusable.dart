import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'dart:ui';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OldSchoolLink extends StatelessWidget {
  final String text;
  final String url;
  final TextStyle? textStyle;

  const OldSchoolLink({
    Key? key,
    required this.text,
    required this.url,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Truncate text if longer than 42 characters
    String displayText = text.length > 42 ? '${text.substring(0, 40)}...' : text;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Text(
          displayText,
          style: textStyle ??
              TextStyle(
                fontSize: 12,
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ),
        ),
      ),
    );
  }
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

 String getTimeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'less than a min ago';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inDays < 1) {
      final int hours = diff.inHours;
      final int minutes = diff.inMinutes % 60;
      return '$hours hours ago';
    } else {
      final int days = diff.inDays;
      final int hours = diff.inHours % 24;
      return '$days days ago';
    }
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



// Future<Uint8List> generateAvatarAsync(String hash, {int size = 40, int pixelSize = 5}) async {
//   final random = Random(hash.hashCode);
//   final image = img.Image(size, size);
  
//   final colorPalette = List.generate(5, (_) => img.getColor(random.nextInt(256), random.nextInt(256), random.nextInt(256)));
  
//   for (var x = 0; x < size ~/ 2; x += pixelSize) {
//     for (var y = 0; y < size; y += pixelSize) {
//       final color = colorPalette[random.nextInt(colorPalette.length)];
//       img.fillRect(image, x, y, x + pixelSize, y + pixelSize, color);
//       img.fillRect(image, size - x - pixelSize, y, size - x, y + pixelSize, color);
//     }
//   }
  
//     final pngBytes = img.encodePng(image);
//   return Future.value(pngBytes as FutureOr<Uint8List>?);
// }





String intToTimeLeft(int value) {
  int h, m, s;
  h = value ~/ 3600;
  m = ((value - h * 3600)) ~/ 60;
  s = value - (h * 3600) - (m * 60);
  String result = "${h}h:${m}m:${s}s";
  return result;
}




const _chars = 'AaBbCcDdEeFfGgHh1234567890';
Random _rnd=Random();
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
String getShortAddress(String address) =>
    '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
