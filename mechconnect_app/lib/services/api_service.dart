import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/mechanic.dart';
import '../models/booking.dart';
import '../models/user_session.dart';

// NEW: a real exception type carrying the backend's actual error message,
// instead of every failure collapsing into a generic "Could not connect to
// server" string. The backend's GlobalExceptionHandler now guarantees every
// error response has the shape {"error": "..."}, so this can rely on that.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static String? _token;

  static void setToken(String? token) => _token = token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static dynamic _handle(http.Response response) {
    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String message = 'Request failed (HTTP ${response.statusCode})';
    if (body is Map && body['error'] != null) {
      message = body['error'].toString();
    }
    throw ApiException(message);
  }

  // ---------------- AUTH ----------------

  static Future<UserSession> register(
      String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    final data = _handle(response);
    final session = UserSession(
      token: data['token'],
      role: data['role'] ?? role,
      name: data['name'] ?? name,
      email: email,
    );
    setToken(session.token);
    await session.persist();
    return session;
  }

  static Future<UserSession> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _handle(response);
    final session = UserSession(
      token: data['token'],
      role: data['role'] ?? 'USER',
      name: data['name'] ?? '',
      email: email,
    );
    setToken(session.token);
    await session.persist();
    return session;
  }

  // FIX: call once at app startup (see splash_screen.dart) so a previously
  // logged-in user doesn't get dumped back on the login screen every time
  // they reopen the app.
  static Future<UserSession?> restoreSession() async {
    final session = await UserSession.load();
    if (session != null) setToken(session.token);
    return session;
  }

  static Future<void> logout() async {
    setToken(null);
    await UserSession.clear();
  }

  // ---------------- MECHANICS (customer search) ----------------

  static Future<List<Mechanic>> getMechanicsByCity(String city) async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.baseUrl}/api/mechanics/search/city?city=${Uri.encodeQueryComponent(city)}'),
      headers: _headers,
    );
    final List data = _handle(response) ?? [];
    return data.map((e) => Mechanic.fromJson(e)).toList();
  }

  // ---------------- "MY SHOP" (mechanic side — NEW) ----------------

  /// Returns null if the logged-in mechanic hasn't created a shop profile yet.
  static Future<Mechanic?> getMyMechanicProfile() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/mechanics/me'),
      headers: _headers,
    );
    if (response.statusCode == 404) return null;
    final data = _handle(response);
    return data == null ? null : Mechanic.fromJson(data);
  }

  static Future<Mechanic> saveMyMechanicProfile({
    required String name,
    required String shopName,
    required String city,
    required String street,
    required double latitude,
    required double longitude,
    required String phone,
    required int experience,
    required String expertise,
    required bool available,
    required String openingTime, // "HH:mm:00"
    required String closingTime,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/mechanics/me'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'shopName': shopName,
        'city': city,
        'street': street,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'experience': experience,
        'expertise': expertise,
        'available': available,
        'openingTime': openingTime,
        'closingTime': closingTime,
      }),
    );
    final data = _handle(response);
    return Mechanic.fromJson(data);
  }

  static Future<List<Booking>> getMyShopBookings() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/bookings/mechanic/me'),
      headers: _headers,
    );
    final List data = _handle(response) ?? [];
    return data.map((e) => Booking.fromJson(e)).toList();
  }

  static Future<Booking> updateBookingStatus(int bookingId, String status) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/api/bookings/$bookingId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    final data = _handle(response);
    return Booking.fromJson(data);
  }

  // ---------------- BOOKINGS (customer side) ----------------

  static Future<Booking> createBooking({
    required int mechanicId,
    required String customerName,
    required String customerPhone,
    required String bikeModel,
    required String bookingTime,
    required String problemDescription,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/bookings'),
      headers: _headers,
      body: jsonEncode({
        'mechanicId': mechanicId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'bikeModel': bikeModel,
        'bookingTime': bookingTime,
        'problemDescription': problemDescription,
      }),
    );
    final data = _handle(response);
    return Booking.fromJson(data);
  }

  static Future<List<String>> getAvailableSlots(int mechanicId, String date) async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.baseUrl}/api/bookings/mechanic/$mechanicId/available-slots?date=$date'),
      headers: _headers,
    );
    final List data = _handle(response) ?? [];
    return data.map((e) => e.toString()).toList();
  }

  static Future<List<Booking>> getMyBookings(String phone) async {
    final response = await http.get(
      Uri.parse(
          '${AppConfig.baseUrl}/api/bookings/customer?phone=${Uri.encodeQueryComponent(phone)}'),
      headers: _headers,
    );
    final List data = _handle(response) ?? [];
    return data.map((e) => Booking.fromJson(e)).toList();
  }
}
