import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiServicePrediksi {
  static const String _baseUrl = 'https://sehatiapp-production.up.railway.app/api';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// 🔹 Kirim data prediksi ke Laravel → diteruskan ke Flask
  static Future<Map<String, dynamic>> prediksi(Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final url = Uri.parse('$_baseUrl/predictions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('🔄 POST /predictions => ${response.statusCode}');
      print('📦 Response: ${response.body}');

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'hasil_prediksi': decoded['hasil_prediksi'] ?? 'Tidak tersedia',
          'faktor': decoded['faktor'] ?? '-',
          'confidence': decoded['confidence'] ?? 0,
          'message': decoded['message'] ?? '',
          'data': decoded['data'] ?? {},
        };
      } else {
        throw Exception(decoded['message'] ?? 'Terjadi kesalahan saat prediksi.');
      }
    } catch (e) {
      throw Exception('⚠️ Gagal menghubungi server: $e');
    }
  }

  /// 🔹 Ambil riwayat prediksi dari backend Laravel
  static Future<List<dynamic>> getRiwayatPrediksi() async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final url = Uri.parse('$_baseUrl/predictions');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('🔄 GET /predictions => ${response.statusCode}');
      print('📦 Response: ${response.body}');

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
        return decoded['data'] as List<dynamic>;
      } else {
        throw Exception(decoded['message'] ?? 'Gagal mengambil data prediksi.');
      }
    } catch (e) {
      throw Exception('⚠️ Gagal memuat riwayat: $e');
    }
  }
}
