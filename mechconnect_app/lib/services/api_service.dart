import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mechanic.dart';
import '../models/booking.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── AUTH ──

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // ── MECHANICS ──

  static Future<List<Mechanic>> getMechanicsByCity(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mechanics/search/city?city=$city'),
      headers: _headers,
    );
    final List data = jsonDecode(response.body);
    return data.map((e) => Mechanic.fromJson(e)).toList();
  }

  // ── BOOKINGS ──

  static Future<bool> createBooking({
    required int mechanicId,
    required String customerName,
    required String customerPhone,
    required String bikeModel,
    required String bookingTime,
    required String problemDescription,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/bookings'),
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
    return response.statusCode == 200;
  }

  static Future<List<String>> getAvailableSlots(
      int mechanicId, String date) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/api/bookings/mechanic/$mechanicId/available-slots?date=$date'),
      headers: _headers,
    );
    final List data = jsonDecode(response.body);
    return data.map((e) => e.toString()).toList();
  }

  static Future<List<Booking>> getMyBookings(String phone) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bookings/customer?phone=$phone'),
      headers: _headers,
    );
    final List data = jsonDecode(response.body);
    return data.map((e) => Booking.fromJson(e)).toList();
  }
}