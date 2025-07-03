import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_penyakit.dart';
import 'dart:developer' as developer;

class ResultDeteksiPage extends StatefulWidget {
  final Map<String, dynamic>? resultData;

  const ResultDeteksiPage({super.key, this.resultData});

  @override
  State<ResultDeteksiPage> createState() => _ResultDeteksiPageState();
}

class _ResultDeteksiPageState extends State<ResultDeteksiPage> {
  late Map<String, dynamic>? _resultData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _resultData = widget.resultData;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ambil data dari API (langsung 1 objek Map)
      Map<String, dynamic> latestData = await ApiService.fetchDeteksiDataLatest();

      setState(() {
        _resultData = latestData;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading result data: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    try {
      // Extract data - will throw if any field is missing
      final String name = _resultData?['nama']?.toString() ?? '-';
      final String age = _resultData?['age']?.toString() ?? '-';
      final String bmi = _resultData?['bmi']?.toString() ?? '-';
      final String systolicBp = _resultData?['systolic_bp']?.toString() ?? '-';
      final String diastolicBp = _resultData?['diastolic_bp']?.toString() ?? '-';
      final String bloodSugar = _resultData?['bs']?.toString() ?? '-';

      final bool hasdiabetes =
          _resultData?['diabetes_prediction']?.toString() == '1';
      final bool hashypertension =
          _resultData?['hypertension_prediction']?.toString() == '1';
      final bool hasmaternalrisk =
          _resultData?['maternal_health_prediction']?.toString().toLowerCase() == 'high risk';

      final isRisky = hasdiabetes || hashypertension || hasmaternalrisk;

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // Status Bar Space
            Container(
              width: double.infinity,
              height: 44,
              color: Colors.white,
            ),
            
            // App Bar with Back Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DBAFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4DBAFF).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF4DBAFF),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Hasil Prediksi Kesehatan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                        letterSpacing: 0.12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // Header Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isRisky 
                            ? [const Color(0xFFFFE5F1), const Color(0xFFFFF0F5)]
                            : [const Color(0xFFE0F4FF), const Color(0xFFF0F9FF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Status Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isRisky 
                                ? const Color(0xFFFC5C9C).withOpacity(0.2)
                                : const Color(0xFF4DBAFF).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isRisky ? Icons.warning_rounded : Icons.check_circle_rounded,
                              size: 40,
                              color: isRisky ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Name and Status
                          Text(
                            name,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isRisky
                                  ? const Color(0xFFFC5C9C)
                                  : const Color(0xFF4DBAFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isRisky ? 'Status: Berisiko' : 'Status: Sehat',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Data Kesehatan
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Data Kesehatan",
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildEnhancedDataRow("Umur", age, Icons.person_outline),
                          _buildEnhancedDataRow("BMI", bmi, Icons.monitor_weight_outlined),
                          _buildEnhancedDataRow("Tekanan Darah", "$systolicBp/$diastolicBp mmHg", Icons.favorite_outline),
                          _buildEnhancedDataRow("Gula Darah", "$bloodSugar mmol/l", Icons.opacity_outlined),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Hasil Prediksi
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hasil Prediksi",
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildPredictionCard("Diabetes", hasdiabetes, Icons.bloodtype_outlined),
                          const SizedBox(height: 12),
                          _buildPredictionCard("Hipertensi", hashypertension, Icons.monitor_heart_outlined),
                          const SizedBox(height: 12),
                          _buildPredictionCard("Risiko Maternal", hasmaternalrisk, Icons.pregnant_woman_outlined),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Penjelasan Detail
                    if (hasdiabetes || hashypertension || hasmaternalrisk) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: const Color(0xFF4DBAFF),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Penjelasan Kondisi",
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            if (hasdiabetes) _buildExplanationCard(
                              "Diabetes",
                              "Kondisi dimana kadar gula darah lebih tinggi dari normal. Hal ini terjadi ketika tubuh tidak dapat memproduksi atau menggunakan insulin dengan baik.",
                              "• Perbanyak konsumsi sayuran dan buah\n• Batasi makanan manis dan berlemak\n• Olahraga teratur minimal 30 menit/hari\n• Kontrol rutin ke dokter",
                              const Color(0xFFFF6B6B),
                            ),
                            
                            if (hashypertension) _buildExplanationCard(
                              "Hipertensi",
                              "Tekanan darah tinggi yang dapat meningkatkan risiko penyakit jantung dan stroke. Normal: <120/80 mmHg, Tinggi: ≥140/90 mmHg.",
                              "• Kurangi konsumsi garam\n• Hindari makanan berlemak jenuh\n• Kelola stress dengan baik\n• Pantau tekanan darah secara rutin",
                              const Color(0xFFFF8C42),
                            ),
                            
                            if (hasmaternalrisk) _buildExplanationCard(
                              "Risiko Maternal Tinggi",
                              "Kondisi yang dapat membahayakan kesehatan ibu dan bayi selama kehamilan. Memerlukan pemantauan medis yang lebih intensif.",
                              "• Kontrol prenatal rutin ke dokter\n• Jaga pola makan bergizi seimbang\n• Istirahat yang cukup\n• Hindari stress berlebihan\n• Pantau tekanan darah dan gula darah",
                              const Color(0xFFFC5C9C),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Rekomendasi Umum
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4DBAFF), Color(0xFF3B9AE1)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4DBAFF).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Saran Kesehatan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "• Konsultasikan hasil ini dengan dokter\n• Lakukan pemeriksaan kesehatan rutin\n• Jaga pola hidup sehat dan olahraga teratur\n• Pantau kondisi kesehatan secara berkala",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DBAFF),
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: const Color(0xFF4DBAFF).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Kembali ke Beranda',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error menampilkan data: ${e.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEnhancedDataRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF4DBAFF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(String label, bool isPositive, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPositive 
          ? const Color(0xFFFCEFEE) 
          : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive 
            ? const Color(0xFFFC5C9C).withOpacity(0.3)
            : const Color(0xFF4DBAFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPositive 
                ? const Color(0xFFFC5C9C).withOpacity(0.1)
                : const Color(0xFF4DBAFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPositive ? 'Terdeteksi' : 'Normal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(String title, String description, String recommendations, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medical_information_outlined,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rekomendasi:",
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendations,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}