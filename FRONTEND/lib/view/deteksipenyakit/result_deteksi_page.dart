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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                      'Hasil Prediksi',
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
                  const SizedBox(width: 36),
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 45, bottom: 20),
                      child: Text(
                        'Hasil Prediksi Kesehatan Bunda',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 29),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: ShapeDecoration(
                          color: isRisky ? const Color(0xFFFCEFEE) : const Color(0xFFF9F9F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: ShapeDecoration(
                                    color: isRisky
                                        ? const Color(0xFFFC5C9C)
                                        : const Color(0xFF4DBAFF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    isRisky ? 'Berisiko' : 'Sehat',
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
                            const SizedBox(height: 20),
                            
                            _buildDataRow("Umur", age),
                            _buildDataRow("BMI", bmi),
                            _buildDataRow("Tekanan Darah", "$systolicBp/$diastolicBp mmHg"),
                            _buildDataRow("Gula Darah", bloodSugar),
                            
                            const SizedBox(height: 24),
                            const Text(
                              "Hasil Prediksi:",
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildPredictionBadge("Diabetes", hasdiabetes),
                                  const SizedBox(width: 8),
                                  _buildPredictionBadge("Hipertensi", hashypertension),
                                  const SizedBox(width: 8),
                                  _buildPredictionBadge("Risiko Maternal", hasmaternalrisk),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            Center(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4DBAFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                                child: const Text(
                                  'Kembali',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
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

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Color(0xFF1E293B),
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
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionBadge(String label, bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPositive ? const Color(0xFFFCCCE2) : const Color(0xFFAEE2FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
          fontSize: 12,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}