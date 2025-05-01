// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiServiceRekomen {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app';

  // 1. Get semua data deteksi
static Future<List<dynamic>> fetchMakananData() async {
  final response = await http.get(Uri.parse('https://sehatiapp-production.up.railway.app/rekomendasimakanan'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // Jika respons adalah list langsung
    if (data is List) {
      return data;
    }

    // Jika respons adalah map yang punya key 'data'
    if (data is Map && data.containsKey('data')) {
      return data['data'];
    }

    return []; // fallback kosong
  } else {
    throw Exception('Failed to fetch makanan data');
  }
}

}