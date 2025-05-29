import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiServiceAsupanAir {
  static const String _baseUrl = 'https://sehatiapp-production.up.railway.app/api';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// 🔄 Ambil total konsumsi air hari ini & riwayat 7 hari ke belakang
  static Future<Map<String, dynamic>> getTotalDanRiwayat() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final url = Uri.parse('$_baseUrl/water-intake');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'total': decoded['total_konsumsi'] ?? 0,
          'history': List<Map<String, dynamic>>.from(decoded['history'] ?? []),
        };
      } else {
        throw Exception(decoded['message'] ?? 'Gagal mengambil data.');
      }
    } catch (e) {
      throw Exception('⚠️ Kesalahan saat mengambil data hidrasi: $e');
    }
  }

  /// 💧 Tambah konsumsi air sebanyak 250ml
  static Future<Map<String, dynamic>> tambahMinum() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    // ✅ Ganti endpoint ke /add
    final url = Uri.parse('$_baseUrl/water-intake');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': decoded['data'],
          'total_ml_today': decoded['total_ml_today'] ?? 0,
          'max_reached': decoded['max_reached'] ?? false,
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'max_reached': true,
          'message': decoded['message'] ?? 'Batas maksimum tercapai',
        };
      } else {
        throw Exception(decoded['message'] ?? 'Gagal menambahkan konsumsi air.');
      }
    } catch (e) {
      throw Exception('⚠️ Kesalahan saat menambahkan konsumsi air: $e');
    }
  }

  /// 🔍 Ambil detail konsumsi air berdasarkan ID
  static Future<Map<String, dynamic>> getDetail(int id) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final url = Uri.parse('$_baseUrl/water-intake/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': Map<String, dynamic>.from(decoded['data'] ?? {}),
        };
      } else {
        throw Exception(decoded['message'] ?? 'Data tidak ditemukan.');
      }
    } catch (e) {
      throw Exception('⚠️ Gagal memuat detail konsumsi air: $e');
    }
  }

  /// 🔁 Update konsumsi air berdasarkan ID
  static Future<bool> updateJumlah(int id, int jumlahMl) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final url = Uri.parse('$_baseUrl/water-intake/$id');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'jumlah_ml': jumlahMl}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('⚠️ Gagal memperbarui data: $e');
    }
  }

  /// 🗑️ Hapus data konsumsi berdasarkan ID
  static Future<bool> hapusData(int id) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final url = Uri.parse('$_baseUrl/water-intake/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('⚠️ Gagal menghapus data: $e');
    }
  }
}
