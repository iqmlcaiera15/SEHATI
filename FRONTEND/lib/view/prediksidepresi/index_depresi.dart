import 'package:flutter/material.dart';
import 'package:Sehati/view/homeprofile/home.dart'; // Import home page
import 'package:Sehati/view/prediksidepresi/ml_kuisioner.dart';
import 'package:Sehati/view/prediksidepresi/riwayat_prediksidepresi.dart';

class IndexDepresi extends StatelessWidget {
  const IndexDepresi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehati App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: const DepressionHomePage(),
    );
  }
}

class DepressionHomePage extends StatefulWidget {
  const DepressionHomePage({Key? key}) : super(key: key);

  @override
  State<DepressionHomePage> createState() => _DepressionHomePageState();
}

class _DepressionHomePageState extends State<DepressionHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Status Bar Space
          Container(
            width: double.infinity,
            height: 44,
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  left: 21,
                  top: 10.50,
                  child: SizedBox(
                    width: 54,
                    child: Text(
                      '9:41',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ),
                ),
                // Battery icon
                Positioned(
                  left: 389.33,
                  top: 17.33,
                  child: Opacity(
                    opacity: 0.35,
                    child: Container(
                      width: 22,
                      height: 11.33,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFF1E293B),
                          ),
                          borderRadius: BorderRadius.circular(2.67),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 391.33,
                  top: 19.33,
                  child: Container(
                    width: 18,
                    height: 7.33,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.33),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // App Bar with Back Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back arrow button
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1E293B),
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Prediksi Depresi Antenatal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
                // Empty container to balance the layout
                SizedBox(width: 36),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(4, 0),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header illustration
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFAEE2FF).withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.psychology,
                            size: 100,
                            color: const Color(0xFF4DBAFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      const Text(
                        'Deteksi Dini Depresi Antenatal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Description
                      const Text(
                        'Kuesioner ini dirancang untuk membantu mendeteksi gejala depresi pada ibu hamil. '
                        'Hasil prediksi hanya bersifat informatif dan tidak menggantikan diagnosa medis profesional.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF4C617F),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Instructions Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4DBAFF).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF4DBAFF),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Petunjuk Pengisian',
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInstructionItem(
                              '1',
                              'Kuesioner terdiri dari 8 pertanyaan seputar perasaan dan pikiran Anda dalam 7 hari terakhir.'
                            ),
                            const SizedBox(height: 12),
                            _buildInstructionItem(
                              '2',
                              'Kuisioner akan dilanjutkan dengan 10 pertanyaan EPDS (Edinburgh Postnatal Depression Scale), jika kuisioner tahap pertama menunjukkan gejala depresi.'
                            ),
                            const SizedBox(height: 12),
                            _buildInstructionItem(
                              '3',
                              'Jawablah setiap pertanyaan dengan jujur sesuai dengan kondisi Anda saat ini.'
                            ),
                            const SizedBox(height: 12),
                            _buildInstructionItem(
                              '4',
                              'Hasil prediksi akan muncul setelah Anda menyelesaikan semua pertanyaan.'
                            ),
                            const SizedBox(height: 12),
                            _buildInstructionItem(
                              '5',
                              'Waktu pengisian sekitar 3-5 menit.'
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Start Questionnaire Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DepressionQuestionnaire(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DBAFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Mulai Kuesioner',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // View History Button
                      SizedBox(
                        width: double.infinity,
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
                            backgroundColor: const Color(0xFFFCCCE2),
                            foregroundColor: const Color(0xFFFC5C9C),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Riwayat Prediksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF4DBAFF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF4DBAFF),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4C617F),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}