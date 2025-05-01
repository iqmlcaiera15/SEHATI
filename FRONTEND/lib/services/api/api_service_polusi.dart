import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Sehati/models/air_quality_model.dart';

class ApiServicePolusi {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/kualitasudara';
  
  static Future<AirQualityModel> getAirQualityData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
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