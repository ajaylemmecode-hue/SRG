// lib/api/api_profile.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiProfile {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";

  static Future<Map<String, dynamic>?> getProfile(String token) async {
    try {
      final url = Uri.parse("$baseUrl/profile");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Profile API failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }
}
