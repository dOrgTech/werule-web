// lib/src/services/avatar_service.dart
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:werule/src/utils/reusable.dart';

/// A service to generate and cache deterministic avatars from a string (e.g., wallet address).
class AvatarService {
  // Simple in-memory cache for the generated avatars.
  static final Map<String, Uint8List> _cache = {};

  /// Gets an avatar for a given [address].
  /// Returns a cached version if available, otherwise generates a new one.
  static Future<Uint8List> getAvatar(String address) async {
    if (_cache.containsKey(address)) {
      return _cache[address]!;
    } else {
      final hash = hashString(address);
      final avatarBytes = await _generateAvatarAsync(hash, size: 26, pixelSize: 2);
      _cache[address] = avatarBytes;
      return avatarBytes;
    }
  }

  /// Generates a symmetrical, deterministic avatar from a hash.
  static Future<Uint8List> _generateAvatarAsync(String hash, {int size = 100, int pixelSize = 10}) async {
    // This can be a bit slow, so it's good that it's in an async method
    // that won't block the UI thread.
    return await Future(() {
      final random = Random(hash.hashCode);
      final avatar = img.Image(width: size, height: size);

      // Create a palette of 5 random colors based on the hash
      final palette = List<img.Color>.generate(5, (_) {
        return img.ColorRgb8(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );
      });

      // Fill the left half of the avatar with colored blocks
      for (var y = 0; y < size; y += pixelSize) {
        for (var x = 0; x < size / 2; x += pixelSize) {
          final color = palette[random.nextInt(palette.length)];
          img.fillRect(avatar, x1: x, y1: y, x2: x + pixelSize, y2: y + pixelSize, color: color);
          // Mirror to the right half
          img.fillRect(avatar, x1: size - x - pixelSize, y1: y, x2: size - x, y2: y + pixelSize, color: color);
        }
      }

      final pngBytes = img.encodePng(avatar);
      return Uint8List.fromList(pngBytes);
    });
  }
}
// lib/src/services/avatar_service.dart