import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// NEW: holds who's currently logged in, and persists it so the app
// remembers the session across restarts (previously the token lived only
// in an in-memory static variable in ApiService and vanished on restart).
class UserSession {
  final String token;
  final String role;
  final String name;
  final String email;

  UserSession({
    required this.token,
    required this.role,
    required this.name,
    required this.email,
  });

  bool get isMechanic => role.toUpperCase() == 'MECHANIC';
  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  static const _prefsKey = 'mechconnect_session_v1';

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({'token': token, 'role': role, 'name': name, 'email': email}),
    );
  }

  static Future<UserSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final token = map['token'] as String?;
      if (token == null || token.isEmpty) return null;
      return UserSession(
        token: token,
        role: map['role'] ?? 'USER',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
