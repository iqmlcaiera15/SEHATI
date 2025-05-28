import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiServiceHPL {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/api';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// 🔹 Hitung HPL berdasarkan tanggal HPHT
  static Future<Map<String, dynamic>> calculateHPL(DateTime hpht) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Pengguna mungkin belum login.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/pregnancy-calculators'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'hpht': hpht.toIso8601String().split('T')[0]}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal menghitung HPL (${response.statusCode})');
    }
  }
}
