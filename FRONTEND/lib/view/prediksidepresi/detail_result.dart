import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DepressionDetailView extends StatelessWidget {
  final int score;
  final Map<String, dynamic> data;
  final int id;

  const DepressionDetailView({
    Key? key,
    required this.score,
    required this.data,
    required this.id,
  }) : super(key: key);

  String _getDepressionStatus(int score) {
  if (score >= 10) {
    return 'Risiko Bergejala Depresi';
  }  else {
    return 'Tidak Terindikasi Depresi';
  }
}


  Color _getStatusColor(int score) {
    if (score >= 10) {
      return const Color(0xFFFF4D4D);
    } else {
      return const Color(0xFF4DBAFF);
    }
  }

  String _getFormattedDate(dynamic dateString) {
  try {
    if (dateString == null) return 'Tanggal tidak tersedia';
    final date = DateTime.parse(dateString.toString());
    return DateFormat('dd MMMM yyyy, HH:mm').format(date);
  } catch (e) {
    return dateString?.toString() ?? 'Tanggal tidak tersedia';
  }
}

  String _getRecommendation(int score) {
  if (score >= 10) {
    return 'Skor Anda menunjukkan risiko bergejala depresi. Segera lakukan penilaian diagnostik dan pengobatan dengan tenaga kesehatan profesional atau spesialis.';
  } else {
    return 'Skor Anda menunjukkan gejala ringan. Lakukan skrining ulang dalam 2–4 minggu dan pertimbangkan berkonsultasi dengan tenaga medis.';
  }
}

  List<Map<String, dynamic>> _getQuestionAnswers() {
    // Contoh pertanyaan EPDS (Edinburgh Postnatal Depression Scale)
    // Ganti dengan pertanyaan yang sesuai dengan API Anda
    final questions = [
      'Saya dapat tertawa dan melihat sisi lucu dari berbagai hal',
      'Saya menikmati berbagai hal',
      'Saya menyalahkan diri sendiri jika sesuatu berjalan tidak semestinya',
      'Saya merasa cemas atau khawatir tanpa alasan yang jelas',
      'Saya merasa takut atau panik tanpa alasan yang jelas',
      'Saya merasa kewalahan dengan berbagai hal',
      'Saya begitu tidak bahagia sehingga sulit tidur',
      'Saya merasa sedih atau menyedihkan',
      'Saya begitu tidak bahagia sehingga saya menangis',
      'Pikiran untuk menyakiti diri sendiri pernah terpikir oleh saya',
    ];

    final answers = data['answers'] as List<dynamic>? ?? [];
    final result = <Map<String, dynamic>>[];

    for (int i = 0; i < questions.length; i++) {
      // Pastikan indeks tidak melebihi batas array
      final answer = i < answers.length ? answers[i] : 0;
      result.add({
        'question': questions[i],
        'answer': answer,
      });
    }

    return result;
  }

  // Function to open WhatsApp
  Future<void> _openWhatsApp() async {
    const phoneNumber = '6285720110281'; // Ganti dengan nomor WhatsApp yang diinginkan
    const message = 'Halo, saya memerlukan bantuan konseling terkait kesehatan mental.';
    
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
      // Bisa tambahkan snackbar atau dialog untuk memberi tahu user
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getDepressionStatus(score);
    final statusColor = _getStatusColor(score);
    final date = _getFormattedDate(data['created_at'] ?? '');
    final recommendation = _getRecommendation(score);
    final questionAnswers = _getQuestionAnswers();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Hasil Prediksi',
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
                        child: Text(
                          score.toString(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 28,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
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
                  recommendation,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Jawaban Pertanyaan
              const Text(
                'Detail Jawaban',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questionAnswers.length,
                itemBuilder: (context, index) {
                  final qa = questionAnswers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}.',
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                qa['question'],
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Jawaban:',
                              style: TextStyle(
                                color: Color(0xFF4C617F),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getAnswerText(qa['answer']),
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
                      ],
                    ),
                  );
                },
              ),

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
                      'Jika Anda memerlukan bantuan segera, hubungi layanan konseling melalui WhatsApp:',
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openWhatsApp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366), // WhatsApp green color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.chat),
                        label: const Text(
                          'Hubungi via WhatsApp',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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

  String _getAnswerText(int answer) {
    // Sesuaikan dengan skala jawaban yang digunakan pada EPDS
    switch (answer) {
      case 0:
        return 'Tidak Pernah';
      case 1:
        return 'Jarang';
      case 2:
        return 'Kadang-kadang';
      case 3:
        return 'Sering';
      default:
        return 'Tidak Diketahui';
    }
  }
}