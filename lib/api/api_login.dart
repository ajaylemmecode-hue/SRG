// // lib/api/api_login.dart
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class ApiLogin {
//   static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";
//
//   static Future<Map<String, dynamic>> loginUser({
//     required String email,
//     required String password,
//   }) async {
//     final url = Uri.parse("$baseUrl/login");
//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"email": email, "password": password}),
//     );
//     return jsonDecode(response.body) as Map<String, dynamic>;
//   }
// }