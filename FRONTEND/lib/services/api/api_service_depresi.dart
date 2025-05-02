import 'dart:convert';
import 'package:http/http.dart' as http;

class DepressionService {
  // Base URL for API
  final String baseUrl = 'https://sehatiapp-production.up.railway.app'; // Update with your actual API URL

  // Method to submit depression questionnaire data
  Future<Map<String, dynamic>> submitDepressionQuestionnaire(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('https://sehatiapp-production.up.railway.app/prediksidepresi/store'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit questionnaire: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> submitEpdsQuestionnaire(Map<String, dynamic> data) async {
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
      throw Exception(responseBody['error'] ?? 'Failed to submit EPDS questionnaire');
    }
  } catch (e) {
    return {
      'status': 'error',
      'message': e.toString(),
    };
  }
}

  // Method to get depression history
  Future<List<dynamic>> getDepressionHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prediksidepresi'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get depression history: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Method to get specific depression record
  Future<Map<String, dynamic>> getDepressionRecord(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prediksidepresi/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get depression record: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}