// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiService {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app';

  // 1. Get semua data deteksi
  static Future<List<dynamic>> fetchMakananData() async {
    final response = await http.get(Uri.parse('https://sehatiapp-production.up.railway.app/rekomendasimakanan'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data[''];
    } else {
      throw Exception('Failed to fetch deteksi data');
    }
  }
}