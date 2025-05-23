import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiServiceRekomen {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/api';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 1. Get semua data rekomendasi makanan
  static Future<List<dynamic>> fetchMakananData() async {
    final token = await _storage.read(key: 'jwt_token');
    
    if (token == null || token.isEmpty) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/rekomendasimakanan'),
      headers: {
        // 'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Pastikan untuk mengambil array dari properti 'data'
      if (data is Map && data.containsKey('data')) {
        return data['data'] as List; // Explicit cast ke List
      }
      
      throw Exception('Invalid API response structure');
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
