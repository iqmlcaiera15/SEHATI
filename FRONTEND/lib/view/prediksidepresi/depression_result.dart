import 'package:flutter/material.dart';
import 'package:Sehati/view/homeprofile/home.dart';
import 'package:intl/intl.dart';
import 'package:Sehati/view/prediksidepresi/riwayat_prediksidepresi.dart'; // Import halaman riwayat
import 'package:url_launcher/url_launcher.dart'; // Add this import for WhatsApp

class DepressionResult extends StatelessWidget {
  final bool isDepressed;
  final Map<String, dynamic> data;
  final int? score;

  // WhatsApp phone number constant
  static const phoneNumber = '6285720110281';

  const DepressionResult({
    Key? key,
    required this.isDepressed,
    required this.data,
    this.score,
  }) : super(key: key);

  // Get the formatted date
  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('dd MMMM yyyy').format(now);
  }

  // Function to open WhatsApp
  Future<void> _openWhatsApp(BuildContext context) async {
    final message = Uri.encodeComponent(
      'Halo, saya memerlukan bantuan profesional untuk kesehatan mental. '
      'Saya telah melakukan tes depresi dan hasilnya menunjukkan risiko tinggi. '
      'Bisakah saya berkonsultasi dengan Anda?'
    );
    
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$message';
    
    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka WhatsApp. Pastikan aplikasi terinstal.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat membuka WhatsApp.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get result status text and color
  Map<String, dynamic> _getResultStatus() {
    if (!isDepressed) {
      return {
        'title': 'Tidak Ada Gejala Depresi',
        'description': 'Berdasarkan jawaban Anda, tidak ada indikasi gejala depresi saat ini.',
        'color': const Color(0xFF4DBAFF),
        'buttonText': 'Kembali ke Dashboard',
      };
    }

    // EPDS Score severity levels
    if (score != null) {
      if (score! >= 10) {
        return {
          'title': 'Risiko Bergejala Depresi',
          'description':
              'Skor EPDS Anda menunjukkan risiko gejala depresi. Diperlukan penilaian diagnostik dan pengobatan oleh profesional kesehatan atau spesialis.',
          'color': const Color(0xFFFF4D4D),
          'buttonText': 'Cari Bantuan Profesional',
        };
      }  else {
        return {
          'title': 'Tidak Ada Gejala Depresi',
          'description':
              'Berdasarkan jawaban Anda, tidak ada indikasi gejala depresi saat ini.',
          'color': const Color(0xFF4DBAFF),
          'buttonText': 'Lihat Saran',
        };
      } 
    }

    // Default for initial screening (should not reach here)
    return {
      'title': 'Terdeteksi Gejala Depresi',
      'description': 'Berdasarkan jawaban Anda, kami mendeteksi kemungkinan adanya gejala depresi.',
      'color': const Color(0xFFFFAA4D),
      'buttonText': 'Kembali ke Dashboard',
    };
  }

  // Get recommendations based on result
  List<Map<String, String>> _getRecommendations() {
    if (!isDepressed) {
      return [
        {
          'title': 'Jaga kesehatan mental',
          'description': 'Tetap jaga kesehatan mental dengan kegiatan positif seperti olahraga, meditasi, atau hobi yang menyenangkan.'
        },
        {
          'title': 'Pola hidup sehat',
          'description': 'Pertahankan pola hidup sehat dengan tidur yang cukup, makan makanan bergizi, dan rutin berolahraga.'
        },
        {
          'title': 'Kelola stres',
          'description': 'Pelajari teknik pengelolaan stres seperti pernapasan dalam atau mindfulness.'
        }
      ];
    }

    // If depressed based on EPDS
    if (score != null) {
      if (score! >= 10) {
        return [
          {
            'title': 'Konsultasi segera',
            'description': 'Segera konsultasikan kondisi Anda dengan psikiater atau psikolog profesional.'
          },
          {
            'title': 'Dukungan keluarga',
            'description': 'Libatkan keluarga atau orang terdekat untuk memberikan dukungan emosional.'
          },
          {
            'title': 'Kelola aktivitas',
            'description': 'Tetapkan target aktivitas harian yang sederhana dan realistis untuk diri Anda.'
          },
          {
            'title': 'Hindari isolasi',
            'description': 'Meskipun sulit, hindari mengasingkan diri dan tetap menjalin komunikasi dengan orang terdekat.'
          }
        ];
      } else {
        return [
          {
            'title': 'Monitor suasana hati',
            'description': 'Pantau suasana hati Anda secara teratur dan perhatikan jika ada perubahan yang signifikan.'
          },
          {
            'title': 'Kelola stres',
            'description': 'Terapkan teknik manajemen stres seperti pernapasan dalam, meditasi, atau yoga.'
          },
          {
            'title': 'Jaga komunikasi',
            'description': 'Bicarakan perasaan Anda dengan orang terdekat yang dapat dipercaya.'
          },
          {
            'title': 'Kualitas tidur',
            'description': 'Pastikan Anda mendapatkan tidur yang berkualitas dan cukup setiap malamnya.'
          }
        ];
      }
    }

    // Default recommendations for initial screening
    return [
      {
        'title': 'Konsultasi lebih lanjut',
        'description': 'Lakukan konsultasi dengan profesional kesehatan mental untuk evaluasi lebih lanjut.'
      },
      {
        'title': 'Jaga pola hidup',
        'description': 'Pertahankan pola makan, tidur, dan aktivitas fisik yang teratur.'
      },
      {
        'title': 'Dukungan sosial',
        'description': 'Libatkan keluarga atau teman dalam perjalanan pemulihan Anda.'
      }
    ];
  }

  Widget _buildResultCard(BuildContext context) {
    final resultStatus = _getResultStatus();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Result Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: resultStatus['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDepressed ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: resultStatus['color'],
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          
          // Result Title
          Text(
            resultStatus['title'],
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Result Date
          Text(
            _getFormattedDate(),
            style: const TextStyle(
              color: Color(0xFF4C617F),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Score (if available)
          if (score != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: resultStatus['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Skor EPDS: $score',
                style: TextStyle(
                  color: resultStatus['color'],
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Result Description
          Text(
            resultStatus['description'],
            style: const TextStyle(
              color: Color(0xFF4C617F),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final recommendations = _getRecommendations();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Rekomendasi',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Recommendations list
        ...recommendations.map((recommendation) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF4DBAFF),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendation['title']!,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recommendation['description']!,
                              style: const TextStyle(
                                color: Color(0xFF4C617F),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultStatus = _getResultStatus();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Hasil Prediksi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1E293B)),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result Card
              Padding(
                padding: const EdgeInsets.all(24),
                child: _buildResultCard(context),
              ),
              
              // Divider
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE5E7EB),
                ),
              ),
              const SizedBox(height: 24),
              
              // Recommendations
              _buildRecommendationsSection(),
              const SizedBox(height: 24),
              
              // Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: () async {
                    // Action button based on result
                    if (isDepressed && (score != null && score! >= 10)) {
                      // Open WhatsApp for professional help
                      await _openWhatsApp(context);
                    } else {
                      // Go back to dashboard
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomePage()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: resultStatus['color'],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isDepressed && (score != null && score! >= 10)) ...[
                        const Icon(Icons.phone, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        resultStatus['buttonText'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tombol Lihat Riwayat Prediksi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Historyview(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4C617F),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text(
                    'Lihat Riwayat Prediksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
          
              if (isDepressed) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4C617F),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text(
                      'Kembali ke Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
