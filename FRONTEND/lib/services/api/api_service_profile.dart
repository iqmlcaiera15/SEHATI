import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiServiceProfile {
  // Ganti dengan URL API Anda yang sebenarnya
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/api';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Model sederhana untuk data profil
  // Anda mungkin ingin membuat file model terpisah jika lebih kompleks
  static Future<List<dynamic>> fetchProfiles() async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
        throw Exception('No token found. User might not be logged in.');
      }


    // Ganti '/profiles' dengan endpoint API Anda yang sebenarnya untuk mengambil data profil
    final response = await http.get(
      Uri.parse('$baseUrl/icons'), // CONTOH ENDPOINT, SESUAIKAN!
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      // Asumsikan API mengembalikan struktur seperti: { "data": [ { "id": 1, "name": "Profile A", "html_content": "<h1>...</h1>" }, ... ] }
      // Sesuaikan 'data' key jika berbeda di API Anda
      if (responseBody is Map && responseBody.containsKey('data')) {
        if (responseBody['data'] is List) {
           return responseBody['data'] as List<dynamic>;
        } else {
          throw Exception('Profile data is not a list.');
        }
      } else if (responseBody is List) {
        // Jika API langsung mengembalikan list
        return responseBody;
      }
      throw Exception('Invalid API response structure for profiles. Expected a key "data" with a list or a direct list.');
    } else {
      // Coba decode body untuk pesan error yang lebih detail dari server
      String errorMessage = 'Failed to load profiles: ${response.statusCode}';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage += ' - ${errorData['message']}';
        }
      } catch (e) {
        // Gagal decode, gunakan body response mentah jika ada
        if(response.body.isNotEmpty) {
          errorMessage += ' - ${response.body}';
        }
      }
      throw Exception(errorMessage);
    }
  }
}