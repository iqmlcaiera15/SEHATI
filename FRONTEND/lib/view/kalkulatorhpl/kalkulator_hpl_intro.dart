import 'package:flutter/material.dart';
import 'package:Sehati/view/homeprofile/home.dart';
import 'package:Sehati/view/kalkulatorhpl/index_hpl.dart';
import 'package:google_fonts/google_fonts.dart';

class KalkulatorHPLIntro extends StatelessWidget {
  final VoidCallback? onStart;

  const KalkulatorHPLIntro({super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F7FF), Color(0xFFF8FCFF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Fancy AppBar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 44, left: 18, right: 18, bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
                backgroundBlendMode: BlendMode.overlay,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.93),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.09),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF1E293B),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Kalkulator HPL',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E293B),
                      fontSize: 20,
                      fontWeight: FontWeight.w700, // konsisten, bukan w800
                      letterSpacing: 0.14,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.white,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Opacity(opacity: 0, child: Icon(Icons.refresh)),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Illustration
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.92, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4DBAFF), Color(0xFF1A87E3)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4DBAFF).withOpacity(0.15),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.calculate,
                                  size: 55,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Title (headline, sama seperti index HPL)
                      Text(
                        "Kalkulator Hari Perkiraan Lahir (HPL)",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1E293B),
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description (reguler, slightly larger)
                      Text(
                        "Gunakan kalkulator HPL untuk memperkirakan tanggal lahir si Kecil secara cepat.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF4C617F),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Instructions Card (card style mirip index HPL)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.07),
                              blurRadius: 20,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gradient header with icon
                            Container(
                              margin: const EdgeInsets.only(top: 20, bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF4DBAFF).withOpacity(0.17),
                                          const Color(0xFF1A87E3).withOpacity(0.14)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF4DBAFF),
                                      size: 21,
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  Text(
                                    'Petunjuk Pengisian',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF1E293B),
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: const Color(0xFFE0E0E0), thickness: 1, height: 6),
                            const SizedBox(height: 10),
                            _buildInstructionItem('1', 'Siapkan tanggal Hari Pertama Haid Terakhir (HPHT) Anda.'),
                            const SizedBox(height: 10),
                            _buildInstructionItem('2', 'Masukkan tanggal HPHT pada kolom yang disediakan.'),
                            const SizedBox(height: 10),
                            _buildInstructionItem('3', 'Hasil prediksi HPL akan muncul setelah Anda mengisi data dan menekan tombol hitung.'),
                            const SizedBox(height: 10),
                            _buildInstructionItem('4', 'Perhitungan usia kehamilan (minggu) juga akan tampil bersama hasil HPL.'),
                            const SizedBox(height: 10),
                            _buildInstructionItem('5', 'Perhitungan ini hanya sebagai estimasi, konsultasikan ke dokter untuk hasil yang lebih akurat.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 34),

                      // Start Button (tebal, font dan radius sama seperti index hpl)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onStart ??
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddDataHPL()),
                                );
                              },
                          icon: const Icon(Icons.calculate, size: 20, color: Colors.white),
                          label: Text(
                            'Mulai Kalkulator',
                            style: GoogleFonts.poppins(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DBAFF),
                            foregroundColor: Colors.white,
                            shadowColor: const Color(0xFF4DBAFF).withOpacity(0.18),
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: const Color(0xFF4DBAFF).withOpacity(0.13),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: const Color(0xFF4DBAFF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF4C617F),
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              height: 1.53,
            ),
          ),
        ),
      ],
    );
  }
}
