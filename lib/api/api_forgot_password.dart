import 'dart:convert';
import 'package:http/http.dart' as http;
class ForgotPasswordApi {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";

  static Future<Map<String, dynamic>> sendResetLink(String email) async {
    final url = Uri.parse("$baseUrl/forgot-password");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return {"status": true, "message": "Reset link sent successfully"};
      } else {
        final data = jsonDecode(response.body);
        return {"status": false, "message": data["message"] ?? "Failed"};
      }
    } catch (e) {
      return {"status": false, "message": "Something went wrong"};
    }
  }
}
