import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Sehati/models/user_model.dart';


class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Base URL API Anda
  final String _baseUrl = 'https://sehatiapp-production.up.railway.app/api';

  // Simpan token
  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Ambil token
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Hapus token
  Future<void> _deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  // Register user
  Future<User?> register(String name, String email, String password, String passwordConfirmation) async {
    try {
      // Print data untuk debugging
      print('Sending registration data: $name, $email, password length: ${password.length}, confirmation length: ${passwordConfirmation.length}');
      
      final response = await _dio.post('$_baseUrl/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation, // Pastikan ini dikirim dengan benar
      });

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String token = response.data['authorization']['token'];
        await _saveToken(token);
        return User.fromJson(response.data['user']);
      }
      return null;
    } on DioException catch (e) {
      print('Error response: ${e.response?.data}');
      print('Error message: ${e.message}');
      return null;
    }
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      final response = await _dio.post('$_baseUrl/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final String token = response.data['authorization']['token'];
        await _saveToken(token); // Simpan token menggunakan FlutterSecureStorage

        // Jangan gunakan SharedPreferences di sini, karena token disimpan di FlutterSecureStorage
        final storedToken = await _storage.read(key: 'jwt_token'); // Ambil token dari FlutterSecureStorage
        print("Token yang disimpan: $storedToken");

        return User.fromJson(response.data['user']);
      }
      return null;
    } on DioException catch (e) {
      print(e.response?.data);
      return null;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token == null) {
        return false;
      }

      final response = await _dio.post(
        '$_baseUrl/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        await _deleteToken();
        return true;
      }
      return false;
    } on DioException catch (e) {
      print(e.response?.data);
      return false;
    }
  }

  // Ambil data user
  Future<User?> getUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        return null;
      }

      final response = await _dio.get(
        '$_baseUrl/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      // Jika token expired
      if (e.response?.statusCode == 401) {
        // Coba refresh token
        final refreshed = await refreshToken();
        if (refreshed) {
          // Coba lagi dengan token baru
          return await getUser();
        }
      }
      print(e.response?.data);
      return null;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) {
        return false;
      }

      final response = await _dio.post(
        '$_baseUrl/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final String newToken = response.data['authorization']['token'];
        await _saveToken(newToken);
        return true;
      }
      return false;
    } on DioException catch (e) {
      print(e.response?.data);
      return false;
    }
  }
}