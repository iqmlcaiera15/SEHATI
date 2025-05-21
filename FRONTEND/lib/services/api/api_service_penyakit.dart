// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app';

  // 1. Get semua data deteksi
 static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<List<dynamic>> fetchDeteksiData() async {
    // Ambil token dari FlutterSecureStorage
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }

    final response = await http.get(
      Uri.parse('https://sehatiapp-production.up.railway.app/api/deteksi/history'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['DeteksiPenyakit'];
    } else {
      throw Exception(
        'Failed to fetch deteksi data\n'
        'Status Code: ${response.statusCode}\n'
        'Body: ${response.body}',
      );
    }
  }

    

    static Future<Map<String, dynamic>> fetchDeteksiDataLatest() async {
    
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }
    
    final response = await http.get(
      Uri.parse('https://sehatiapp-production.up.railway.app/api/deteksi/latest'),
       headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Map<String, dynamic>.from(data['DeteksiPenyakit']);
    } else {
      throw Exception('Failed to fetch deteksi data');
    }
  }


 static Future<Map<String, dynamic>> submitDeteksiData(Map<String, dynamic> formData) async {
    // Ambil token dari secure storage
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }

    final response = await http.post(
      Uri.parse('https://sehatiapp-production.up.railway.app/api/deteksi/store'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(formData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to submit deteksi data\n'
        'Status Code: ${response.statusCode}\n'
        'Body: ${response.body}',
      );
    }
  }
}
