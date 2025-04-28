import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Sehati/models/air_quality_model.dart';

class ApiService {
  static Future<Map<String, dynamic>> getAirQualityData(String ip, String city, String country) async {
    final String url = 'https://sehatiapp-production.up.railway.app/kualitasudara?city=${Uri.encodeComponent("Bandung")}&country=${Uri.encodeComponent("Indonesia")}';

    final response = await http.get(Uri.parse(url));

    // Debugging output
    print('URL API: $url');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data kualitas udara');
    }
  }
}

