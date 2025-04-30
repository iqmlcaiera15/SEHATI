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
  Future<Map<String, dynamic>> submitEpdsQuestionnaire(List<int> answers) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/skor-epds'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'answers': answers,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit EPDS questionnaire: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Method to get depression history
  Future<List<dynamic>> getDepressionHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prediksi-depresi'),
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
        Uri.parse('$baseUrl/prediksi-depresi/$id'),
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