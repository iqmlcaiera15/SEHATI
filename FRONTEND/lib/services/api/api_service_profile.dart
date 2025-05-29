import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiServiceProfile {
  // Ganti dengan URL API Anda yang sebenarnya
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/api';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Method untuk mengambil token dari secure storage
  static Future<String> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }
    return token;
  }

  // Method untuk mengambil data icons dari API
  static Future<List<dynamic>> fetchIcons() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/icons'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      // Asumsikan API mengembalikan struktur seperti: 
      // { "data": [ { "id": 1, "name": "Wajah Senyum", "type": "material", "data": "https://..." }, ... ] }
      if (responseBody is Map && responseBody.containsKey('data')) {
        if (responseBody['data'] is List) {
           return responseBody['data'] as List<dynamic>;
        } else {
          throw Exception('Icon data is not a list.');
        }
      } else if (responseBody is List) {
        // Jika API langsung mengembalikan list
        return responseBody;
      }
      throw Exception('Invalid API response structure for icons. Expected a key "data" with a list or a direct list.');
    } else {
      // Coba decode body untuk pesan error yang lebih detail dari server
      String errorMessage = 'Failed to load icons: ${response.statusCode}';
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

  // Method untuk menyimpan pilihan icon user ke backend
  static Future<void> updateSelectedIcon(int iconId) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/user/select-icon'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'icon_id': iconId,
      }),
    );

    if (response.statusCode == 200) {
      // Berhasil update icon
      final responseBody = json.decode(response.body);
      
      // Optional: Log response untuk debugging
      print('Icon updated successfully: $responseBody');
      
      return;
    } else {
      // Handle error response
      String errorMessage = 'Failed to update selected icon: ${response.statusCode}';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData is Map && errorData.containsKey('error')) {
          errorMessage = errorData['error'];
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

  // Method untuk mengambil data user profile (optional, jika diperlukan)
  static Future<Map<String, dynamic>> getUserProfile() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      
      if (responseBody is Map && responseBody.containsKey('data')) {
        return Map<String, dynamic>.from(responseBody['data'] as Map);
      } else if (responseBody is Map) {
        return Map<String, dynamic>.from(responseBody);
      }
      throw Exception('Invalid API response structure for user profile.');
    } else {
      String errorMessage = 'Failed to load user profile: ${response.statusCode}';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage += ' - ${errorData['message']}';
        }
      } catch (e) {
        if(response.body.isNotEmpty) {
          errorMessage += ' - ${response.body}';
        }
      }
      throw Exception(errorMessage);
    }
  }

  // Method untuk mengambil icon yang dipilih user saat ini (optional)
  static Future<Map<String, dynamic>?> getSelectedIcon() async {
    try {
      final userProfile = await getUserProfile();
      
      // Asumsikan response user profile memiliki informasi selected_icon
      if (userProfile.containsKey('selected_icon') && userProfile['selected_icon'] != null) {
        return Map<String, dynamic>.from(userProfile['selected_icon'] as Map);
      }
      
      return null;
    } catch (e) {
      print('Error getting selected icon: $e');
      return null;
    }
  }

}