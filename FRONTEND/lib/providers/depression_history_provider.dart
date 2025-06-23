import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:Sehati/view/prediksidepresi/detail_result.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class DepressionHistoryProvider with ChangeNotifier {
  bool isLoading = true;
  List<dynamic> historyItems = [];
  String errorMessage = '';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  DepressionHistoryProvider() {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      errorMessage = 'No token found. User might not be logged in.';
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      
      final prediksiResponse = await http.get(
        Uri.parse('https://sehatiapp-production.up.railway.app/api/prediksidepresi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final epdsResponse = await http.get(
        Uri.parse('https://sehatiapp-production.up.railway.app/api/epds'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (prediksiResponse.statusCode == 200 && epdsResponse.statusCode == 200) {
        final prediksiData = json.decode(prediksiResponse.body);
        final epdsData = json.decode(epdsResponse.body);
        
      
        final Map<int, dynamic> epdsMap = {};
        for (var epds in epdsData) {
          epdsMap[epds['prediksi_depresi_id']] = epds;
        }
        
      
        final List<dynamic> combinedData = [];
        
        for (var prediksi in prediksiData) {
          final int prediksiId = prediksi['id'];
          
          if (epdsMap.containsKey(prediksiId)) {
           
            combinedData.add({
              ...prediksi,
              'has_epds': true,
              'epds_data': epdsMap[prediksiId],
              'score': epdsMap[prediksiId]['score'],
            });
          } else {
           
            combinedData.add({
              ...prediksi,
              'has_epds': false,
              'score': 0, 
            });
          }
        }
        
        combinedData.sort((a, b) {
          DateTime dateA = DateTime.parse(a['created_at']);
          DateTime dateB = DateTime.parse(b['created_at']);
          return dateB.compareTo(dateA);
        });
        
        historyItems = combinedData;
        isLoading = false;
        notifyListeners();
      } else {
        errorMessage = 'Gagal memuat data: ${prediksiResponse.statusCode} / ${epdsResponse.statusCode}';
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistoryByUserId(String userId) async {
    await fetchHistory();
  }

  String getFormattedDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String getDepressionStatus(int score, bool hasEpds, int? hasilPrediksi) {
    if (!hasEpds) {
      return hasilPrediksi == 1 ? 'Berpotensi Depresi' : 'Tidak Ada Gejala Depresi';
    }
    
    // For EPDS results
    if (score >= 14) {
        return 'Risiko Tinggi Depresi';
    } else if (score >= 12) {
        return 'Kemungkinan Depresi';
    } else if (score >= 9) {
        return 'Gejala Ringan';
    } else {
        return 'Tidak Ada Indikasi Depresi';
    }
  }

  Color getStatusColor(int score, bool hasEpds, int? hasilPrediksi) {
    if (!hasEpds) {
      return hasilPrediksi == 1 ? const Color(0xFFFFAA4D) : const Color(0xFF4DBAFF);
    }
    
    if (score >= 13) {
      return const Color(0xFFFF4D4D);
    } else if (score >= 10) {
      return const Color(0xFFFFAA4D);
    } else {
      return const Color(0xFF4DBAFF);
    }
  }
}