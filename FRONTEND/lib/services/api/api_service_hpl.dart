import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiServiceHPL {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/api';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// 🔹 Hitung & simpan HPL berdasarkan tanggal HPHT (POST)
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

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal menghitung HPL (${response.statusCode}): ${response.body}');
    }
  }

  /// 🔹 Ambil semua data HPL user yang sedang login (GET)
  static Future<List<dynamic>> getDataHPL() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Pengguna mungkin belum login.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/pregnancy-calculators'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // Struktur: { "message": "...", "data": [ ... ] }
      if (body is Map && body.containsKey('data')) {
        return List<Map<String, dynamic>>.from(body['data']);
      } else if (body is List) {
        return body;
      } else {
        throw Exception('Struktur response tidak sesuai, data HPL tidak ditemukan.');
      }
    } else {
      throw Exception('Gagal mengambil data HPL (${response.statusCode}): ${response.body}');
    }
  }

  /// 🔹 Simpan HPL manual (POST)
  static Future<Map<String, dynamic>> inputManualHPL(DateTime hpl) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Pengguna mungkin belum login.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/pregnancy-calculators/manual'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'hpl': hpl.toIso8601String().split('T')[0]}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal input HPL manual (${response.statusCode}): ${response.body}');
    }
  }
}
