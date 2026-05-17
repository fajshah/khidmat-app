import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_request.dart';
import '../models/booking.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  Future<RequestResponse> processRequest(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      return RequestResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to process request');
    }
  }

  Future<Booking> createBooking({
    required String providerId,
    required String providerName,
    required String service,
    required String slot,
    required String userName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/book'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provider_id': providerId,
        'provider_name': providerName,
        'service': service,
        'slot': slot,
        'user_name': userName,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return Booking.fromJson(json['booking']);
      } else {
        throw Exception(json['message'] ?? 'Booking failed');
      }
    } else {
      throw Exception('Failed to create booking');
    }
  }
}
