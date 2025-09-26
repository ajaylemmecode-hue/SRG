// lib/api/api_furnished_flat.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/furnished_model.dart';

class ApiFurnishedFlat {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";

  /// Fetch furnished flats
  static Future<List<FurnishedFlat>> getFurnishedFlats() async {
    try {
      final url = Uri.parse("$baseUrl/furnished-flats");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['products'] != null) {
          final products = data['data']['products'] as List;
          return products.map((e) => FurnishedFlat.fromJson(e)).toList();
        }
        return [];
      } else {
        throw Exception("Failed to fetch furnished flats: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching furnished flats: $e");
    }
  }
}
