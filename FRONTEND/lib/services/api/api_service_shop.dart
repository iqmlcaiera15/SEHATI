// lib/services/api/api_service_shop.dart
import 'dart:convert';
import 'dart:async'; // Untuk TimeoutException
import 'package:http/http.dart' as http;
import 'package:Sehati/models/product_model.dart'; // <- IMPORT ProductModel DI SINI

class ApiServiceShop {
  // Pastikan URL ini benar dan sesuai dengan backend Anda
  // Jika backend di lokal: 'http://10.0.2.2:8000/api' (untuk Android emulator)
  // atau 'http://localhost:8000/api' (untuk iOS simulator/web)
  static const String baseUrl = 'http://your-laravel-backend.com/api';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Jika API Anda memerlukan token otentikasi:
    // 'Authorization': 'Bearer YOUR_AUTH_TOKEN',
  };

  static Future<List<ProductModel>> fetchProducts() async {
    try {
      // print('[ApiServiceShop] Fetching products from $baseUrl/products'); // Hapus/komentari untuk produksi
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
      ).timeout(const Duration(seconds: 20)); // Tambahkan timeout

      // print('[ApiServiceShop] Response status: ${response.statusCode}');
      // print('[ApiServiceShop] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);

        if (decodedBody is Map<String, dynamic> &&
            decodedBody.containsKey('data') &&
            decodedBody['data'] is List) {
          final List<dynamic> productsJson = decodedBody['data'];
          return productsJson
              .map((jsonItem) => ProductModel.fromJson(jsonItem as Map<String, dynamic>))
              .toList();
        } else if (decodedBody is List) {
          // Jika respons API adalah array JSON langsung
          return decodedBody
              .map((jsonItem) => ProductModel.fromJson(jsonItem as Map<String, dynamic>))
              .toList();
        } else {
          // print('[ApiServiceShop] Unexpected JSON format for products list.');
          throw Exception('Format JSON tidak dikenali dari API produk');
        }
      } else {
        // print('[ApiServiceShop] Failed to load products. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Gagal memuat produk: Status ${response.statusCode}');
      }
    } on TimeoutException {
      // print('[ApiServiceShop] Error fetching products: Timeout');
      throw Exception('Koneksi timeout. Periksa jaringan internet Anda.');
    } on http.ClientException {
      // print('[ApiServiceShop] Error fetching products: ClientException (Network Error)');
      throw Exception('Kesalahan jaringan. Periksa koneksi internet Anda.');
    } catch (e) {
      // print('[ApiServiceShop] Error fetching products: $e');
      throw Exception('Terjadi kesalahan saat mengambil produk: $e');
    }
  }

  static Future<ProductModel> fetchProductById(int id) async {
    try {
      // print('[ApiServiceShop] Fetching product with ID: $id from $baseUrl/products/$id');
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 20));

      // print('[ApiServiceShop] Response status: ${response.statusCode}');
      // print('[ApiServiceShop] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);

        if (decodedBody is Map<String, dynamic> &&
            decodedBody.containsKey('data') &&
            decodedBody['data'] is Map<String, dynamic>) {
          return ProductModel.fromJson(decodedBody['data'] as Map<String, dynamic>);
        } else if (decodedBody is Map<String, dynamic>) {
          // Jika respons API adalah objek produk langsung
          return ProductModel.fromJson(decodedBody);
        } else {
          // print('[ApiServiceShop] Unexpected JSON format for single product.');
          throw Exception('Format JSON tidak dikenali dari API detail produk');
        }
      } else {
        // print('[ApiServiceShop] Failed to load product. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Gagal memuat produk: Status ${response.statusCode}');
      }
    } on TimeoutException {
      // print('[ApiServiceShop] Error fetching product: Timeout');
      throw Exception('Koneksi timeout. Periksa jaringan internet Anda.');
    } on http.ClientException {
      // print('[ApiServiceShop] Error fetching product: ClientException (Network Error)');
      throw Exception('Kesalahan jaringan. Periksa koneksi internet Anda.');
    } catch (e) {
      // print('[ApiServiceShop] Error fetching product: $e');
      throw Exception('Terjadi kesalahan saat mengambil detail produk: $e');
    }
  }
} // <-- KURUNG KURAWAL PENUTUP KELAS DITAMBAHKAN DI SINI