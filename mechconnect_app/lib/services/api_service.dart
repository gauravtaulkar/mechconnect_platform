import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/mechanic.dart';
import '../models/booking.dart';
import '../models/user_session.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ============================================================
  // DEBUG / REQUEST HANDLING
  // ============================================================

  static void _logRequest(String method, String url) {
    print('');
    print('============================================================');
    print('MECHCONNECT API REQUEST');
    print('METHOD: $method');
    print('URL: $url');
    print('BASE URL: ${AppConfig.baseUrl}');
    print('============================================================');
  }

  static void _logResponse(http.Response response) {
    print('');
    print('------------------------------------------------------------');
    print('MECHCONNECT API RESPONSE');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    print('------------------------------------------------------------');
    print('');
  }

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

  // ============================================================
  // AUTH - REGISTER
  // ============================================================

  static Future<UserSession> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final url = '${AppConfig.baseUrl}/api/auth/register';

    _logRequest('POST', url);

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 60));

      _logResponse(response);

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
    } catch (e, stackTrace) {
      print('');
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('REGISTER ERROR');
      print('ERROR: $e');
      print('TYPE: ${e.runtimeType}');
      print('STACK TRACE:');
      print(stackTrace);
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('');

      rethrow;
    }
  }

  // ============================================================
  // AUTH - LOGIN
  // ============================================================

  static Future<UserSession> login(
    String email,
    String password,
  ) async {
    final url = '${AppConfig.baseUrl}/api/auth/login';

    _logRequest('POST', url);

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 60));

      _logResponse(response);

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
    } catch (e, stackTrace) {
      print('');
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('LOGIN ERROR');
      print('ERROR: $e');
      print('TYPE: ${e.runtimeType}');
      print('STACK TRACE:');
      print(stackTrace);
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('');

      rethrow;
    }
  }

  // ============================================================
  // SESSION
  // ============================================================

  static Future<UserSession?> restoreSession() async {
    final session = await UserSession.load();

    if (session != null) {
      setToken(session.token);
    }

    return session;
  }

  static Future<void> logout() async {
    setToken(null);
    await UserSession.clear();
  }

  // ============================================================
  // MECHANICS - CUSTOMER SEARCH
  // ============================================================

  static Future<List<Mechanic>> getMechanicsByCity(
    String city,
  ) async {
    final url =
        '${AppConfig.baseUrl}/api/mechanics/search/city'
        '?city=${Uri.encodeQueryComponent(city)}';

    _logRequest('GET', url);

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 60));

      _logResponse(response);

      final List data = _handle(response) ?? [];

      return data
          .map((e) => Mechanic.fromJson(e))
          .toList();
    } catch (e, stackTrace) {
      print('GET MECHANICS ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // MY SHOP - MECHANIC
  // ============================================================

  static Future<Mechanic?> getMyMechanicProfile() async {
    final url = '${AppConfig.baseUrl}/api/mechanics/me';

    _logRequest('GET', url);

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 60));

      _logResponse(response);

      if (response.statusCode == 404) {
        return null;
      }

      final data = _handle(response);

      return data == null ? null : Mechanic.fromJson(data);
    } catch (e, stackTrace) {
      print('GET MY MECHANIC PROFILE ERROR: $e');
      print(stackTrace);
      rethrow;
    }
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
    required String openingTime,
    required String closingTime,
  }) async {
    final url = '${AppConfig.baseUrl}/api/mechanics/me';

    _logRequest('POST', url);

    try {
      final response = await http
          .post(
            Uri.parse(url),
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
          )
          .timeout(const Duration(seconds: 60));

      _logResponse(response);

      final data = _handle(response);

      return Mechanic.fromJson(data);
    } catch (e, stackTrace) {
      print('SAVE MECHANIC PROFILE ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // BOOKINGS - MECHANIC
  // ============================================================

  static Future<List<Booking>> getMyShopBookings() async {
    final url = '${AppConfig.baseUrl}/api/bookings/mechanic/me';

    _logRequest('GET', url);

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 60));

      _logResponse(response);

      final List data = _handle(response) ?? [];

      return data
          .map((e) => Booking.fromJson(e))
          .toList();
    } catch (e, stackTrace) {
      print('GET SHOP BOOKINGS ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  static Future<Booking> updateBookingStatus(
    int bookingId,
    String status,
  ) async {
    final url =
        '${AppConfig.baseUrl}/api/bookings/$bookingId/status';

    _logRequest('PUT', url);

    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode({
              'status': status,
            }),
          )
          .timeout(const Duration(seconds: 60));

      _logResponse(response);

      final data = _handle(response);

      return Booking.fromJson(data);
    } catch (e, stackTrace) {
      print('UPDATE BOOKING STATUS ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // BOOKINGS - CUSTOMER
  // ============================================================

  static Future<Booking> createBooking({
    required int mechanicId,
    required String customerName,
    required String customerPhone,
    required String bikeModel,
    required String bookingTime,
    required String problemDescription,
  }) async {
    final url = '${AppConfig.baseUrl}/api/bookings';

    _logRequest('POST', url);

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode({
              'mechanicId': mechanicId,
              'customerName': customerName,
              'customerPhone': customerPhone,
              'bikeModel': bikeModel,
              'bookingTime': bookingTime,
              'problemDescription': problemDescription,
            }),
          )
          .timeout(const Duration(seconds: 60));

      _logResponse(response);

      final data = _handle(response);

      return Booking.fromJson(data);
    } catch (e, stackTrace) {
      print('CREATE BOOKING ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  static Future<List<String>> getAvailableSlots(
    int mechanicId,
    String date,
  ) async {
    final url =
        '${AppConfig.baseUrl}/api/bookings/mechanic/'
        '$mechanicId/available-slots?date=$date';

    _logRequest('GET', url);

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 60));

      _logResponse(response);

      final List data = _handle(response) ?? [];

      return data
          .map((e) => e.toString())
          .toList();
    } catch (e, stackTrace) {
      print('GET AVAILABLE SLOTS ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  static Future<List<Booking>> getMyBookings() async {
  final url = '${AppConfig.baseUrl}/api/bookings/customer/me';

  _logRequest('GET', url);

  try {
    final response = await http
        .get(
          Uri.parse(url),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 60));

    _logResponse(response);

    final List data = _handle(response) ?? [];

    return data
        .map((e) => Booking.fromJson(e))
        .toList();
  } catch (e, stackTrace) {
    print('GET MY BOOKINGS ERROR: $e');
    print(stackTrace);
    rethrow;
  }
}
}