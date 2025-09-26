import 'dart:convert';
//home api :- get home page data
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";

  static Future<Map<String, dynamic>> fetchHomeData() async {
    final url = Uri.parse('$baseUrl/home');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load home data');
    }
  }
}
