import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unfurnised_model.dart';
class ApiUnfurnishedFlat {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1/unfurnished-flats";
  static Future<List<UnfurnishedFlat>> getUnfurnishedFlats() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final products = jsonData['data']['products'] as List;
      return products.map((e) => UnfurnishedFlat.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load unfurnished flats');
    }
  }
}
