import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DepressionService {
  // Base URL for API
  final String baseUrl = 'https://sehatiapp-production.up.railway.app/api';

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Helper method to parse error response from backend
  String _parseErrorResponse(http.Response response) {
    try {
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      
      // Try different possible error message fields
      if (errorBody.containsKey('message')) {
        return errorBody['message'];
      } else if (errorBody.containsKey('error')) {
        return errorBody['error'];
      } else if (errorBody.containsKey('errors')) {
        // Handle validation errors
        final errors = errorBody['errors'];
        if (errors is Map) {
          return errors.values.first.toString();
        } else if (errors is List) {
          return errors.first.toString();
        }
      }
      
      // If no specific error message found, return the raw response
      return response.body;
    } catch (e) {
      // If JSON parsing fails, return status code and raw response
      return 'HTTP ${response.statusCode}: ${response.body}';
    }
  }

  // Method to submit depression questionnaire data
  Future<Map<String, dynamic>> submitDepressionQuestionnaire(Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/prediksidepresi/store'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorMessage = _parseErrorResponse(response);
        throw Exception('Failed to submit questionnaire: $errorMessage');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> submitEpdsQuestionnaire(Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      return {
        'status': 'error',
        'message': 'No token found. User might not be logged in.',
      };
    }

    try {
      // Convert individual q1, q2, etc. into an array
      final List<int> answersArray = [];
      for (int i = 1; i <= 10; i++) {
        answersArray.add(data['q$i'] as int);
      }
      
      // Prepare the request payload
      final Map<String, dynamic> payload = {
        'prediksi_depresi_id': data['prediksi_depresi_id'],
        'answers': answersArray,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/epds/store'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      final responseBody = Map<String, dynamic>.from(jsonDecode(response.body));
      
      if (response.statusCode == 201) {
        // Format response to match what the Flutter app expects
        final int score = responseBody['score'] ?? 0;
        
        return {
          'status': 'success',
          'message': responseBody['message'] ?? 'EPDS berhasil disimpan.',
          'data': {
            'hasil_prediksi': score >= 10 ? 1 : 0,
            'answers': score, // This will be used as the EPDS score
            ...(responseBody['data'] is Map 
                ? Map<String, dynamic>.from(responseBody['data']) 
                : {'data': responseBody['data']}),
          }
        };
      } else {
        final errorMessage = _parseErrorResponse(response);
        return {
          'status': 'error',
          'message': errorMessage,
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }

    // Method to get all prediction history
    Future<List<dynamic>> getDepressionHistory() async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prediksidepresi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Handle different response formats
        if (decoded is List) {
          // Format: PrediksiDepresi::all() - direct array
          return decoded;
        } else if (decoded is Map<String, dynamic>) {
          // Format: wrapped in object
          if (decoded.containsKey('PrediksiDepresi')) {
            final data = decoded['PrediksiDepresi'];
            if (data is List) {
              return data; // Return array (bisa kosong atau berisi data)
            }
          }
          // Jika ada key lain, sesuaikan di sini
          return []; // Return empty list jika tidak ada data
        }
        
        return []; // Default return empty list
      } else {
        final errorMessage = _parseErrorResponse(response);
        throw Exception('Failed to get depression history: $errorMessage');
      }
    } catch (e) {
      print('Error in getDepressionHistory: $e'); // Debug log
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // Method to get EPDS history
  Future<List<dynamic>> getEpdsHistory() async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/epds'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorMessage = _parseErrorResponse(response);
        throw Exception('Failed to get EPDS history: $errorMessage');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // Method to get specific depression record
  Future<Map<String, dynamic>> getDepressionRecord(String id) async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prediksidepresi/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorMessage = _parseErrorResponse(response);
        throw Exception('Failed to get depression record: $errorMessage');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
  
  // Method to get specific EPDS record
  Future<Map<String, dynamic>> getEpdsRecord(String id) async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/epds/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorMessage = _parseErrorResponse(response);
        throw Exception('Failed to get EPDS record: $errorMessage');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // Additional helper method to handle common HTTP status codes
  void _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        throw Exception('Bad Request: ${_parseErrorResponse(response)}');
      case 401:
        throw Exception('Unauthorized: ${_parseErrorResponse(response)}');
      case 403:
        throw Exception('Forbidden: ${_parseErrorResponse(response)}');
      case 404:
        throw Exception('Not Found: ${_parseErrorResponse(response)}');
      case 422:
        throw Exception('Validation Error: ${_parseErrorResponse(response)}');
      case 500:
        throw Exception('Server Error: ${_parseErrorResponse(response)}');
      default:
        throw Exception('HTTP ${response.statusCode}: ${_parseErrorResponse(response)}');
    }
  }
}