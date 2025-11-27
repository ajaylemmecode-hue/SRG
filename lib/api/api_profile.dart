// lib/api/api_profile.dart - COMPLETE WORKING VERSION

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiProfile {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";
  static const Duration timeout = Duration(seconds: 15);

  static void _log(String msg) {
    if (kDebugMode) print('👤 Profile API: $msg');
  }

  // ✅ GET PROFILE
  static Future<Map<String, dynamic>?> getProfile(String token) async {
    try {
      _log('Fetching profile...');

      if (token.isEmpty) {
        throw Exception('No token provided');
      }

      final url = Uri.parse('$baseUrl/profile');
      final response = await http
          .get(
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
        _log('✅ Profile fetched successfully');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      _log('❌ Error: $e');
      return null;
    }
  }

  // ✅ UPDATE PROFILE
  static Future<Map<String, dynamic>?> updateProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      _log('Updating profile...');

      if (token.isEmpty) {
        throw Exception('No token provided');
      }

      final url = Uri.parse('$baseUrl/profile');

      final body = jsonEncode({
        if (name != null && name.isNotEmpty) 'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (address != null && address.isNotEmpty) 'address': address,
      });

      _log('Request body: $body');

      final response = await http
          .put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      )
          .timeout(timeout);

      _log('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _log('✅ Profile updated successfully');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Update failed');
      }
    } catch (e) {
      _log('❌ Error: $e');
      return null;
    }
  }

  // ✅ UPDATE PASSWORD
  static Future<Map<String, dynamic>?> updatePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _log('Updating password...');

      if (token.isEmpty) {
        throw Exception('No token provided');
      }

      final url = Uri.parse('$baseUrl/password');

      final body = jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

      final response = await http
          .put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      )
          .timeout(timeout);

      _log('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _log('✅ Password updated successfully');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Password update failed');
      }
    } catch (e) {
      _log('❌ Error: $e');
      return null;
    }
  }
}