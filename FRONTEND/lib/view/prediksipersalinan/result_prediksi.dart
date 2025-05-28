import 'package:flutter/material.dart';

class ResultPrediksi extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultPrediksi({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final String hasil = (result['hasil_prediksi'] ?? 'Tidak tersedia').toString();
    final String faktor = (result['faktor'] ?? '').toString();

    final bool isCaesar = hasil.toLowerCase() == 'caesar';
    final Color primaryColor = isCaesar ? const Color(0xFFFC5C9C) : const Color(0xFF4DAEFF);
    final Color bgColor = isCaesar ? const Color(0xFFFFF1F5) : const Color(0xFFF0F9FF);

    final String rekomendasi = isCaesar
        ? '''
Persalinan Caesar dilakukan melalui sayatan di perut dan rahim. Umumnya disarankan jika:
• Bayi dalam posisi sungsang atau melintang
• Bayi berukuran besar
• Ibu memiliki komplikasi medis
• Riwayat persalinan Caesar sebelumnya

👉 Konsultasikan dengan dokter untuk memastikan pilihan terbaik bagi kehamilan bunda.
'''
        : '''
Persalinan Normal adalah proses melahirkan secara alami melalui vagina. Umumnya disarankan jika:
• Posisi bayi normal (kepala di bawah)
• Kondisi ibu dan janin sehat
• Tidak ada riwayat komplikasi medis serius
• Kehamilan cukup bulan (usia kehamilan > 37 minggu)

👉 Persalinan normal memiliki waktu pemulihan yang lebih cepat. Tetap kontrol rutin ke dokter, ya.
''';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Prediksi Persalinan',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: primaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hasil Prediksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor),
                    ),
                    child: Text(
                      hasil[0].toUpperCase() + hasil.substring(1).toLowerCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  if (faktor.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Faktor utama: $faktor',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    rekomendasi,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF334155),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(fontSize: 14, fontFamily: 'Poppins', color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
