import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fishing_log.dart';

/// Persists fishing logs locally via SharedPreferences.
///
/// A Supabase-backed store with photo upload is planned for a later phase; the
/// JSON shape here intentionally mirrors the planned `fishing_logs` table.
class LogService {
  static const _key = 'fishing_logs';

  Future<List<FishingLog>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    final logs = raw
        .map((s) => FishingLog.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }

  Future<void> addLog(FishingLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.add(jsonEncode(log.toJson()));
    await prefs.setStringList(_key, raw);
  }

  Future<void> deleteLog(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.removeWhere((s) {
      final json = jsonDecode(s) as Map<String, dynamic>;
      return json['id'] == id;
    });
    await prefs.setStringList(_key, raw);
  }
}
