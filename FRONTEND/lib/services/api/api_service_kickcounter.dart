import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Sehati/models/kick_counter_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiServiceKickCounter {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/api/kick-counter';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

 static Future<List<KickCounter>> fetchKickCounterData() async {
  final token = await _storage.read(key: 'jwt_token');

  if (token == null || token.isEmpty) {
    throw Exception('No token found. User might not be logged in.');
  }
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => KickCounter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load kick counter data');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

  static Future<KickCounter> saveKickCounterData(KickCounter kickCounter) async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }
    

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/store'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',},
        body: json.encode(kickCounter.toJson()),
      );
      
      if (response.statusCode == 201) {
        return KickCounter.fromJson(json.decode(response.body)['data']);
      } else {
        throw Exception('Failed to save kick counter data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}