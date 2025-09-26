import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiRegister {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";

  /// POST /register
  /// Returns decoded JSON map from server.
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    final url = Uri.parse("$baseUrl/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "password_confirmation": confirmPassword,
      }),
    );

    // Expecting 200 or 201 (backend dependent)
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded;
  }
}
