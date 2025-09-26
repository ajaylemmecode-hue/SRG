import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiLogout {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";

  /// POST /logout
  static Future<bool> logout(String token) async {
    try {
      final url = Uri.parse("$baseUrl/logout");
      print("Calling logout API: $url");
      print("Using token: $token");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Logout response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body["status"] == true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Logout API error: $e");
      return false;
    }
  }
}
