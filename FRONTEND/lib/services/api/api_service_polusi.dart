import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:Sehati/models/air_quality_model.dart';

class ApiServicePolusi {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/api/kualitasudara';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<AirQualityModel> getAirQualityData() async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. User might not be logged in.');
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Debugging output
      print('URL API: $baseUrl');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return AirQualityModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load air quality data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching air quality data: $e');
      throw Exception('Failed to fetch air quality data: $e');
    }
  }
}
