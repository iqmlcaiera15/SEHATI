import 'package:Sehati/providers/depression_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:Sehati/view/prediksidepresi/detail_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming the DepressionHistoryProvider is in the same file or imported

class Historyview extends StatefulWidget {
  const Historyview({Key? key}) : super(key: key);

  @override
  State<Historyview> createState() => _HistoryviewState();
}

class _HistoryviewState extends State<Historyview> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    
    if (userId != null && mounted) {
      // Fetch history setelah mendapatkan user_id
      context.read<DepressionHistoryProvider>().fetchHistoryByUserId(userId!);
    }
  }

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
        // Trigger fetch jika belum ada data dan userId tersedia
        if (provider.historyItems.isEmpty && !provider.isLoading && userId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.fetchHistoryByUserId(userId!);
          });
        }

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
                  onPressed: () {
                    if (userId != null) {
                      provider.fetchHistoryByUserId(userId!);
                    }
                  },
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
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ilustrasi dengan lingkaran latar belakang
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DBAFF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.history,
                        size: 60,
                        color: Color(0xFF4DBAFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Belum ada riwayat prediksi',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Lakukan tes prediksi depresi untuk melihat hasilnya di sini',
                    style: TextStyle(
                      color: Color(0xFF4C617F),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Tambahan card kecil untuk visual appeal
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4DBAFF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Riwayat Anda akan muncul di sini',
                          style: TextStyle(
                            color: Color(0xFF4C617F),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (userId != null) {
              await provider.fetchHistoryByUserId(userId!);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.historyItems.length,
            itemBuilder: (context, index) {
              final item = provider.historyItems[index];
              final bool hasEpds = item['has_epds'] ?? false;
              final int score = item['score'] as int? ?? 0;
              final int? hasilPrediksi = item['hasil_prediksi'] as int?;
              final date = provider.getFormattedDate(item['created_at']);
              final status = provider.getDepressionStatus(score, hasEpds, hasilPrediksi);
              final statusColor = provider.getStatusColor(score, hasEpds, hasilPrediksi);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    if (hasEpds) {
                      final epdsData = item['epds_data'];
                      // Properly cast the data to Map<String, dynamic>
                      final castData = epdsData is Map ? Map<String, dynamic>.from(epdsData) : <String, dynamic>{};
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DepressionDetailView(
                            score: score,
                            data: castData,
                            id: item['id'],
                          ),
                        ),
                      );
                    } else {
                      // Properly cast the prediksi data
                      final castItem = Map<String, dynamic>.from(item);
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _buildPrediksiDetailPage(context, castItem),
                        ),
                      );
                    }
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
                                hasEpds ? 'Skor: $score' : (hasilPrediksi == 1 ? 'Potensi' : 'Aman'),
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
                        if (!hasEpds && hasilPrediksi == 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Hasil prediksi awal',
                              style: TextStyle(
                                color: const Color(0xFF4C617F),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  // Helper method to create a basic detail page for prediksi results without EPDS
  Widget _buildPrediksiDetailPage(BuildContext context, Map<String, dynamic> prediksi) {
    final hasilPrediksi = prediksi['hasil_prediksi'] as int? ?? 0;
  
  // Safely handle the date string
      String dateStr;
      try {
        dateStr = prediksi['created_at']?.toString() ?? DateTime.now().toIso8601String();
      } catch (e) {
        dateStr = DateTime.now().toIso8601String();
      }
      
      final date = DateFormat('dd MMMM yyyy, HH:mm').format(
        DateTime.tryParse(dateStr) ?? DateTime.now()
      );
      
      final status = hasilPrediksi == 1 ? 'Berpotensi Depresi' : 'Tidak Ada Gejala Depresi';
      final statusColor = hasilPrediksi == 1 ? const Color(0xFFFFAA4D) : const Color(0xFF4DBAFF);
  
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Hasil Prediksi Awal',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          hasilPrediksi == 1 ? Icons.warning_rounded : Icons.check_circle_rounded,
                          color: statusColor,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF4C617F),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Rekomendasi
              const Text(
                'Rekomendasi',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
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
                child: Text(
                  hasilPrediksi == 1
                      ? 'Berdasarkan hasil prediksi awal, Anda berpotensi mengalami depresi. Kami sarankan untuk melakukan tes EPDS lebih lanjut untuk evaluasi lebih mendetail.'
                      : 'Berdasarkan hasil prediksi awal, Anda tidak menunjukkan gejala depresi. Tetap jaga kesehatan mental Anda dengan pola hidup sehat dan seimbang.',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ),

              if (hasilPrediksi == 1) ...[
                const SizedBox(height: 24),
                
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to EPDS test
                      // You can implement this navigation later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigasi ke tes EPDS akan diimplementasikan')),
                      );
                    },
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
                    child: const Text(
                      'Lakukan Tes EPDS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Tombol bantuan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Butuh Bantuan?',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Jika Anda memerlukan bantuan segera, hubungi layanan konseling atau hotline berikut:',
                      style: TextStyle(
                        color: Color(0xFF4C617F),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Implementasi untuk menghubungi hotline
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DBAFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.phone),
                            label: const Text(
                              'Hotline',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Implementasi untuk menghubungi konselor
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4DBAFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFF4DBAFF),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text(
                              'Konselor',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}