// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiService {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app';

  // 1. Get semua data deteksi
  static Future<List<dynamic>> fetchDeteksiData() async {
    final response = await http.get(Uri.parse('https://sehatiapp-production.up.railway.app/deteksi/history'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['DeteksiPenyakit'];
    } else {
      throw Exception('Failed to fetch deteksi data');
    }
  }

  // 2. Submit data untuk deteksi baru
  static Future<Map<String, dynamic>> submitDeteksiData(Map<String, dynamic> formData) async {
    final response = await http.post(
      Uri.parse('https://sehatiapp-production.up.railway.app/deteksi/store'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(formData),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit deteksi dataa');
    }
  }

  // 3. Get data prediksi (kalau ada endpoint khusus)
  static Future<Map<String, dynamic>> fetchPrediksiData() async {
    final response = await http.get(Uri.parse('$baseUrl/prediksi'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch prediksi data');
    }
  }
}
