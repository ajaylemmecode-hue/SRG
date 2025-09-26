// lib/api/api_contact.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact_model.dart';

class ApiContact {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";

  // Submit enquiry
  static Future<Map<String, dynamic>> submitContact(Contact contact) async {
    final url = Uri.parse("$baseUrl/contact");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(contact.toJson()),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        if (response.body.isNotEmpty) return jsonDecode(response.body);
        return {"status": true, "message": "Submitted successfully"};
      } else {
        return {"status": false, "message": "Server Error"};
      }
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }
  }

  // Get enquiry history
  static Future<Map<String, dynamic>> getHistory(String email) async {
    final url = Uri.parse("$baseUrl/contact/history?email=$email");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        if (data != null && data["status"] == true) {
          final list = (data["data"] as List?) ?? [];
          final parsedList = list.map((e) => ContactHistory.fromJson(e)).toList();
          return {"status": true, "message": data["message"] ?? "", "data": parsedList};
        } else {
          return {"status": false, "message": data?["message"] ?? "No history", "data": []};
        }
      } else {
        return {"status": false, "message": "Server Error", "data": []};
      }
    } catch (e) {
      return {"status": false, "message": e.toString(), "data": []};
    }
  }
}
