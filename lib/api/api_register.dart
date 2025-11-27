// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class ApiRegister {
//   static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";
//
//   /// POST /register
//   /// Returns decoded JSON map from server.
//   static Future<Map<String, dynamic>> registerUser({
//     required String name,
//     required String email,
//     required String phone,
//     required String password,
//     required String confirmPassword,
//   }) async {
//     try {
//       final url = Uri.parse("$baseUrl/register");
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "name": name,
//           "email": email,
//           "phone": phone,
//           "password": password,
//           "password_confirmation": confirmPassword,
//         }),
//       );
//
//       final decoded = jsonDecode(response.body) as Map<String, dynamic>;
//
//       // Check if registration was successful
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return decoded;
//       } else {
//         // Handle validation errors from backend
//         if (decoded.containsKey('errors')) {
//           // Laravel validation errors format
//           final errors = decoded['errors'] as Map<String, dynamic>;
//           final firstError = errors.values.first;
//           final errorMessage = firstError is List ? firstError.first : firstError;
//           throw Exception(errorMessage.toString());
//         } else if (decoded.containsKey('message')) {
//           throw Exception(decoded['message'].toString());
//         } else {
//           throw Exception('Registration failed');
//         }
//       }
//     } catch (e) {
//       // Network or parsing errors
//       if (e is Exception) {
//         rethrow;
//       }
//       throw Exception('Network error: ${e.toString()}');
//     }
//   }
// }