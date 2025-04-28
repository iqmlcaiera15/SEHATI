// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiService {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app';


  static Future<String> getCsrfToken() async {
    try {
      final response = await http.get(Uri.parse('https://sehatiapp-production.up.railway.app/token'));
      
      // Cetak respons mentah untuk debugging
      print('Raw token response: ${response.body}');
      
      if (response.statusCode == 200) {
        // Periksa apakah respons adalah JSON valid
        try {
          final data = json.decode(response.body);
          // Cek di mana token berada dalam respons
          if (data is Map && data.containsKey('csrf_token')) {
            return data['csrf_token'];
          } else if (data is Map && data.containsKey('token')) {
            return data['token'];
          } else {
            // Jika token ada dalam format lain dalam respons JSON
            print('Token structure: $data');
            // Coba kembalikan data jika string
            if (data is String) return data;
            return response.body; // Fallback: gunakan respons mentah
          }
        } catch (e) {
          // Jika bukan JSON valid, mungkin token langsung dikembalikan sebagai plaintext
          print('Response is not JSON: $e');
          return response.body.trim(); // Gunakan respons mentah sebagai token
        }
      } else {
        throw Exception('Failed to get CSRF token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting CSRF token: $e');
    }
  }
  
      static Future<Map<String, String>> getSessionCookies() async {
      try {
        final response = await http.get(Uri.parse('https://sehatiapp-production.up.railway.app'));
        Map<String, String> cookies = {};
        
        if (response.headers.containsKey('set-cookie')) {
          String allCookies = response.headers['set-cookie']!;
          print('Received cookies: $allCookies');
          
          // Ekstrak semua cookie yang diterima
          final cookiesList = allCookies.split(',');
          for (var cookieStr in cookiesList) {
            final cookieParts = cookieStr.split(';')[0].split('=');
            if (cookieParts.length >= 2) {
              String name = cookieParts[0].trim();
              String value = cookieParts[1].trim();
              cookies[name] = value;
            }
          }
        }
        
        return cookies;
      } catch (e) {
        print('Error getting session cookies: $e');
        return {};
      }
    }
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

static Future<Map<String, dynamic>> submitDeteksiData(Map<String, dynamic> formData) async {
    try {
      // 1. Ambil cookies session terlebih dahulu
      final cookies = await getSessionCookies();
      String cookieHeader = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
      
      // 2. Ambil CSRF token
      final csrfToken = await getCsrfToken();
      print('Using CSRF token: $csrfToken');
      
      if (csrfToken == null) {
        throw Exception('Failed to get CSRF token');
      }
      
      // 3. Persiapkan headers
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-TOKEN': csrfToken,
        'X-Requested-With': 'XMLHttpRequest', // Penting untuk request Ajax di Laravel
      };
      
      // Tambahkan cookie jika ada
      if (cookieHeader.isNotEmpty) {
        headers['Cookie'] = cookieHeader;
      }
      
      // 4. Kirim data dengan token CSRF
      final response = await http.post(
        Uri.parse('https://sehatiapp-production.up.railway.app/deteksi/store'),
        headers: headers,
        body: json.encode(formData),
      );
      
      print('Submit response status: ${response.statusCode}');
      print('Submit response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit deteksi data ${response.statusCode}');
      }
    } catch (e) {
      print('Error in submitDeteksiData: $e');
      throw Exception('Error submitting deteksi data: $e');
    }
  }
  
  // Fungsi untuk mengambil riwayat deteksi
  static Future<List<dynamic>> getDeteksiHistory() async {
    try {
      // 1. Ambil cookies session terlebih dahulu
      final cookies = await getSessionCookies();
      String cookieHeader = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
      
      // 2. Ambil CSRF token
      final csrfToken = await getCsrfToken();
      
      // 3. Persiapkan headers
      final headers = {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };
      
      // Tambahkan CSRF token jika ada
      if (csrfToken != null) {
        headers['X-CSRF-TOKEN'] = csrfToken;
      }
      
      // Tambahkan cookie jika ada
      if (cookieHeader.isNotEmpty) {
        headers['Cookie'] = cookieHeader;
      }
      
      // 4. Ambil data history
      final response = await http.get(
        Uri.parse('https://sehatiapp-production.up.railway.app/deteksi/history'),
        headers: headers,
      );
      
      print('History response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get deteksi history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting deteksi history: $e');
    }
  }


// Fungsi helper untuk menghindari error jika string terlalu pendek
int min(int a, int b) {
  return (a < b) ? a : b;
}

  // 3. Get data prediksi (kalau ada endpoint khusus)
  static Future<Map<String, dynamic>> fetchPrediksiData() async {
    final response = await http.get(Uri.parse('https://sehatiapp-production.up.railway.app/deteksi/store'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch prediksi data');
    }
  }
}
