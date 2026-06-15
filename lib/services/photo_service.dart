import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores log photos locally on the device.
///
/// Images are kept as base64 in SharedPreferences (one key per photo) so the
/// same code path works on iOS, Android and web. Photos are downscaled by the
/// picker before they reach this service to keep storage small.
class PhotoService {
  static const _prefix = 'log_photo_';
  static final _random = Random();

  final Map<String, Uint8List> _cache = {};

  /// Persists the given image bytes and returns their generated ids.
  Future<List<String>> savePhotos(List<Uint8List> images) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = <String>[];
    for (final bytes in images) {
      final id =
          'p_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(0x40000000)}';
      await prefs.setString('$_prefix$id', base64Encode(bytes));
      _cache[id] = bytes;
      ids.add(id);
    }
    return ids;
  }

  Future<Uint8List?> loadPhoto(String id) async {
    final cached = _cache[id];
    if (cached != null) return cached;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$id');
    if (raw == null) return null;
    final bytes = base64Decode(raw);
    _cache[id] = bytes;
    return bytes;
  }

  Future<void> deletePhotos(List<String> ids) async {
    if (ids.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    for (final id in ids) {
      await prefs.remove('$_prefix$id');
      _cache.remove(id);
    }
  }
}
