import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultPrediksi extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultPrediksi({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final String hasil = (result['hasil_prediksi'] ?? 'Tidak tersedia').toString();
    final String faktor = (result['faktor'] ?? '').toString();
    final double? confidence = result['confidence'] is num
        ? (result['confidence'] as num).toDouble()
        : double.tryParse(result['confidence']?.toString() ?? '');

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
      backgroundColor: const Color(0xFFF6FAFD),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x2034aaf4),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF2277b6)),
                ),
              ),
              Center(
                child: Text(
                  'Hasil Prediksi',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Kosong di kanan, jika perlu nanti tambahkan
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withOpacity(0.13)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.09),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    hasil[0].toUpperCase() + hasil.substring(1).toLowerCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (confidence != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: primaryColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bar_chart, size: 18, color: Color(0xFF4DAEFF)),
                          const SizedBox(width: 6),
                          Text(
                            "${confidence.toStringAsFixed(0)}%", // HANYA PERSEN
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (faktor.trim().isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFF4DAEFF), size: 18),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            "Faktor utama: $faktor",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: primaryColor.withOpacity(0.09)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
                    child: Text(
                      rekomendasi,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF334155),
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DAEFF),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Text(
                  'Selesai',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
