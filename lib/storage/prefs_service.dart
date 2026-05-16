import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefsKeys {
  static const loggedIn = 'logged_in';
  static const username = 'username';

  static const usersJson = 'users_json';
  static const sessionsJson = 'sessions_json';

  static String itemsJsonForUser(String username) => 'items_json_${username.toLowerCase()}';
}

class PrefsService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(PrefsKeys.loggedIn) ?? false;
  }

  Future<String?> getUsername() async {
    final prefs = await _prefs;
    final value = prefs.getString(PrefsKeys.username);
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }

  Future<List<Map<String, dynamic>>> loadUsers() async {
    final prefs = await _prefs;
    final raw = prefs.getString(PrefsKeys.usersJson);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Map<String, dynamic>>[];

    return decoded
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await _prefs;
    await prefs.setString(PrefsKeys.usersJson, jsonEncode(users));
  }

  Future<bool> registerUser({required String username, required String password}) async {
    final normalized = username.trim();
    final key = normalized.toLowerCase();

    final users = await loadUsers();
    final exists = users.any((u) => (u['username'] ?? '').toString().toLowerCase() == key);
    if (exists) return false;

    final next = [
      ...users,
      {
        'username': normalized,
        // Nota: para el taller guardamos en texto plano. No usar así en producción.
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    await _saveUsers(next);
    return true;
  }

  Future<bool> login({required String username, required String password}) async {
    final normalized = username.trim();
    final key = normalized.toLowerCase();

    final users = await loadUsers();
    final match = users.where((u) {
      final uName = (u['username'] ?? '').toString().toLowerCase();
      final uPass = (u['password'] ?? '').toString();
      return uName == key && uPass == password;
    }).isNotEmpty;

    if (!match) return false;

    final prefs = await _prefs;
    await prefs.setBool(PrefsKeys.loggedIn, true);
    await prefs.setString(PrefsKeys.username, normalized);

    await addSessionEvent(username: normalized, type: 'login');
    return true;
  }

  Future<List<Map<String, dynamic>>> loadSessions({String? username}) async {
    final prefs = await _prefs;
    final raw = prefs.getString(PrefsKeys.sessionsJson);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Map<String, dynamic>>[];

    final list = decoded
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);

    if (username == null) return list;
    final key = username.trim().toLowerCase();
    return list
        .where((e) => (e['username'] ?? '').toString().toLowerCase() == key)
        .toList(growable: false);
  }

  Future<void> addSessionEvent({required String username, required String type}) async {
    final prefs = await _prefs;
    final current = await loadSessions();
    final next = [
      {
        'username': username.trim(),
        'type': type,
        'at': DateTime.now().toIso8601String(),
      },
      ...current,
    ];
    await prefs.setString(PrefsKeys.sessionsJson, jsonEncode(next));
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    final username = prefs.getString(PrefsKeys.username);
    await prefs.setBool(PrefsKeys.loggedIn, false);
    await prefs.remove(PrefsKeys.username);

    if (username != null && username.trim().isNotEmpty) {
      await addSessionEvent(username: username, type: 'logout');
    }
  }

  Future<List<Map<String, dynamic>>> loadItemsForUser(String username) async {
    final prefs = await _prefs;
    final raw = prefs.getString(PrefsKeys.itemsJsonForUser(username));
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Map<String, dynamic>>[];

    return decoded
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  Future<void> saveItemsForUser(String username, List<Map<String, dynamic>> items) async {
    final prefs = await _prefs;
    await prefs.setString(PrefsKeys.itemsJsonForUser(username), jsonEncode(items));
  }

  Future<void> clearItemsForUser(String username) async {
    final prefs = await _prefs;
    await prefs.remove(PrefsKeys.itemsJsonForUser(username));
  }
}
