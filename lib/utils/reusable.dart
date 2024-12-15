import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'dart:math';
import 'dart:core';

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
    String displayText =
        text.length > 42 ? '${text.substring(0, 40)}...' : text;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Text(
          displayText,
          style: textStyle ??
              TextStyle(
                fontSize: 12,
                decoration: TextDecoration.underline,
                color: Color.fromARGB(255, 168, 216, 255),
              ),
        ),
      ),
    );
  }
}

String parseTransactionHash(input) {
  input = input.substring(2, input.length - 1);

  // Decode the string into bytes
  List<int> byteValues = [];

  for (int i = 0; i < input.length; i++) {
    if (input[i] == '\\' && input[i + 1] == 'x') {
      // Handle hex bytes (e.g., \x9a)
      String hexValue = input.substring(i + 2, i + 4);
      byteValues.add(int.parse(hexValue, radix: 16));
      i += 3; // Skip processed '\xNN'
    } else {
      // Handle literal ASCII characters (e.g., 'K', 'W')
      byteValues.add(input.codeUnitAt(i));
    }
  }

  // Convert bytes to hexadecimal string
  String hexString =
      byteValues.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  return hexString;
}

String formatTotalSupply(String totalSupply, int decimals) {
  BigInt supply = BigInt.parse(totalSupply);
  BigInt nominalValue = supply ~/ BigInt.from(pow(10, decimals));

  double value = nominalValue.toDouble();

  if (value < 1000) {
    return value.toStringAsFixed(0); // Less than 1,000, no abbreviation
  } else if (value < 1000000) {
    double result = value / 1000;
    return result == result.floor()
        ? result.toStringAsFixed(0) + 'K'
        : result.toStringAsFixed(1) + 'K';
  } else if (value < 1000000000) {
    double result = value / 1000000;
    return result == result.floor()
        ? result.toStringAsFixed(0) + 'M'
        : result.toStringAsFixed(1) + 'M';
  } else if (value < 1000000000000) {
    double result = value / 1000000000;
    return result == result.floor()
        ? result.toStringAsFixed(0) + 'B'
        : result.toStringAsFixed(1) + 'B';
  } else {
    double result = value / 1000000000000;
    return result == result.floor()
        ? result.toStringAsFixed(0) + 'T'
        : result.toStringAsFixed(1) + 'T';
  }
}

Future<Uint8List> generateAvatarAsync(String hash,
    {int size = 40, int pixelSize = 5}) async {
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

String generateContractAddress() {
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
Random _rnd = Random();
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
String getShortAddress(String address) =>
    '${address.substring(0, 6)}...${address.substring(address.length - 4)}';

Color randomColor() {
  var g = math.Random.secure().nextInt(255);
  var b = math.Random.secure().nextInt(255);
  var r = math.Random.secure().nextInt(255);
  return Color.fromARGB(255, r, g, b);
}

Matrix4 scaleXYZTransform({
  double scaleX = 1.00,
  double scaleY = 1.00,
  double scaleZ = 1.00,
}) {
  return Matrix4.diagonal3Values(scaleX, scaleY, scaleZ);
}
