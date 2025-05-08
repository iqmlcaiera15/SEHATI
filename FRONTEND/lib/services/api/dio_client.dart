import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://sehatiapp-production.up.railway.app';

  DioClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ambil token dari storage
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, coba refresh
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Coba ulang request dengan token baru
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _storage.read(key: 'jwt_token');
    final options = Options(
      method: requestOptions.method,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        return false;
      }

      final response = await Dio().post(
        '$_baseUrl/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final String newToken = response.data['authorization']['token'];
        await _storage.write(key: 'jwt_token', value: newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response> get(String endpoint) async {
    return await _dio.get('$_baseUrl$endpoint');
  }

  Future<Response> post(String endpoint, dynamic data) async {
    return await _dio.post('$_baseUrl$endpoint', data: data);
  }

  Future<Response> put(String endpoint, dynamic data) async {
    return await _dio.put('$_baseUrl$endpoint', data: data);
  }

  Future<Response> delete(String endpoint) async {
    return await _dio.delete('$_baseUrl$endpoint');
  }
}