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

  // Method to submit EPDS questionnaire data
  Future<Map<String, dynamic>> submitEpdsQuestionnaire(Map<String, dynamic> data) async {
  try {
    final List<int> answersArray = [];
      for (int i = 1; i <= 10; i++) {
        answersArray.add(data['q$i'] as int);
      }
      
      // Prepare the request payload
      final payload = {
        'prediksi_depresi_id': data['prediksi_depresi_id'],
        'answers': answersArray,
      };
    // data sudah berisi 'prediksi_depresi_id' dan jawaban-jawaban kuesioner
    final response = await http.post(
      Uri.parse('$baseUrl/epds/store'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload), // Menggunakan data yang sudah disiapkan sebelumnya
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
        // Format response to match what the Flutter app expects
        return {
          'status': 'success',
          'message': responseBody['message'] ?? 'EPDS berhasil disimpan.',
          'data': {
            'hasil_prediksi': responseBody['score'] >= 10 ? 1 : 0,
            'answers': responseBody['score'],
            ...responseBody['data']
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