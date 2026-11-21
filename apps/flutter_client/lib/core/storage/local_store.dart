import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento LOCAL del dispositivo. Nada de esto se envía al servidor.
class LocalStore {
  LocalStore(this._p);
  final SharedPreferences _p;

  static const _settingsKey = 'fl.settings.v1';
  static const _historyKey = 'fl.history.v1';
  static const _achKey = 'fl.achievements.v1';
  static const maxHistory = 30;

  Map<String, dynamic> readSettings() => _readMap(_settingsKey);
  Future<void> writeSettings(Map<String, dynamic> v) => _p.setString(_settingsKey, jsonEncode(v));

  List<Map<String, dynamic>> readHistory() {
    final raw = _p.getString(_historyKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } on Object {
      return [];
    }
  }

  Future<void> writeHistory(List<Map<String, dynamic>> v) =>
      _p.setString(_historyKey, jsonEncode(v.take(maxHistory).toList()));

  Map<String, dynamic> readAchievements() => _readMap(_achKey);
  Future<void> writeAchievements(Map<String, dynamic> v) => _p.setString(_achKey, jsonEncode(v));

  Future<void> clearHistory() => _p.remove(_historyKey);

  Map<String, dynamic> _readMap(String k) {
    final raw = _p.getString(k);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on Object {
      return {};
    }
  }
}
