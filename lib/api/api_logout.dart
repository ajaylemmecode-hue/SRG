// lib/api/api_logout.dart - COMPLETE VERSION

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiLogout {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";
  static const Duration timeout = Duration(seconds: 15);

  static void _log(String msg) {
    if (kDebugMode) print('🚪 Logout API: $msg');
  }

  /// ✅ LOGOUT USER
  static Future<bool> logout(String token) async {
    try {
      _log('Calling logout endpoint...');

      if (token.isEmpty) {
        throw Exception('No token provided');
      }

      final url = Uri.parse('$baseUrl/logout');

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(timeout);

      _log('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _log('✅ Logout successful');
        return data['status'] == true;
      } else {
        _log('❌ Logout failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _log('❌ Error: $e');
      return false;
    }
  }
}