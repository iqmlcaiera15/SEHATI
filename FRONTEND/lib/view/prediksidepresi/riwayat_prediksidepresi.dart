import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:Sehati/view/prediksidepresi/detail_result.dart';

// Provider untuk mengelola state
class DepressionHistoryProvider with ChangeNotifier {
  bool isLoading = true;
  List<dynamic> historyItems = [];
  String errorMessage = '';

  DepressionHistoryProvider() {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      // Ganti URL dengan endpoint API sesuai kebutuhan
      final response = await http.get(
        Uri.parse('YOUR_API_BASE_URL/epds'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Tambahkan header authorization jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        historyItems = data;
        isLoading = false;
        notifyListeners();
      } else {
        errorMessage = 'Gagal memuat data: ${response.statusCode}';
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  String getFormattedDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String getDepressionStatus(int score) {
    if (score >= 13) {
      return 'Depresi Berat';
    } else if (score >= 10) {
      return 'Depresi Sedang';
    } else if (score >= 1) {
      return 'Depresi Ringan';
    } else {
      return 'Tidak Ada Gejala Depresi';
    }
  }

  Color getStatusColor(int score) {
    if (score >= 13) {
      return const Color(0xFFFF4D4D);
    } else if (score >= 10) {
      return const Color(0xFFFFAA4D);
    } else if (score >= 1) {
      return const Color(0xFFFFE04D);
    } else {
      return const Color(0xFF4DBAFF);
    }
  }
}

// Stateless Widget
class Historyview extends StatelessWidget {
  const Historyview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DepressionHistoryProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Riwayat Prediksi',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<DepressionHistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.fetchHistory(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DBAFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (provider.historyItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/no_data.png', // Ganti dengan asset yang sesuai
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada riwayat prediksi',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lakukan tes prediksi depresi untuk melihat hasilnya di sini',
                  style: TextStyle(
                    color: Color(0xFF4C617F),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.historyItems.length,
          itemBuilder: (context, index) {
            final item = provider.historyItems[index];
            final score = item['score'] as int;
            final date = provider.getFormattedDate(item['created_at']);
            final status = provider.getDepressionStatus(score);
            final statusColor = provider.getStatusColor(score);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DepressionDetailView(
                        score: score,
                        data: item,
                        id: item['id'],
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Skor: $score',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Color(0xFF4C617F),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}