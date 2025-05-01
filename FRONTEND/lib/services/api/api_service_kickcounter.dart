import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Sehati/models/kick_counter_model.dart';

class ApiServiceKickCounter {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/kick-counter';
  
  static Future<List<KickCounter>> fetchKickCounterData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl'));
      
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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/store'),
        headers: {'Content-Type': 'application/json'},
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