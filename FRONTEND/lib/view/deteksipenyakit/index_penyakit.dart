import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_penyakit.dart';
import 'package:Sehati/view/deteksipenyakit/add_data_penyakit.dart';
import 'package:Sehati/view/homeprofile/home.dart';

void main() {
  runApp(const IndexPenyakit());
}

class IndexPenyakit extends StatelessWidget {
  const IndexPenyakit({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehati App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePenyakit(),
    );
  }
}

class HomePenyakit extends StatefulWidget {
  const HomePenyakit({Key? key}) : super(key: key);

  @override
  State<HomePenyakit> createState() => _HomePenyakitState();
}

class _HomePenyakitState extends State<HomePenyakit> with TickerProviderStateMixin {
  late Future<List<dynamic>> _data;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _data = ApiService.fetchDeteksiData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF8FAFC),
            ],
          ),
        ),
        child: Column(
          children: [
            // Enhanced Status Bar
            Container(
              width: double.infinity,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            
            // Enhanced App Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Enhanced Back Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4DBAFF).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                      'Index Penyakit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            
            // Enhanced Main Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF8FAFC),
                        Color(0xFFF1F5F9),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Enhanced Header Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4DBAFF),
                                  Color(0xFF3B82F6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4DBAFF).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Prediksi Dini Resiko\nKesehatan Bunda',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    height: 1.40,
                                    letterSpacing: 0.10,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pantau kondisi kesehatan Anda secara berkala',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    height: 1.40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Enhanced Add Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4DBAFF),
                                  Color(0xFF3B82F6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4DBAFF).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddDataPenyakit(),
                                  ),
                                );
                                
                                if (result == true) {
                                  _loadData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Tambah Data Baru',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Enhanced Data List
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 400),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: FutureBuilder(
                                future: _data,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final data = snapshot.data as List<dynamic>;
                                    if (data.isEmpty) {
                                      return _buildEmptyState();
                                    }
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4DBAFF),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Riwayat Pemeriksaan',
                                              style: TextStyle(
                                                color: Color(0xFF1E293B),
                                                fontSize: 18,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        ...data.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final item = entry.value;
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: index == data.length - 1 ? 0 : 16,
                                            ),
                                            child: _buildEnhancedPredictionItem(item),
                                          );
                                        }).toList(),
                                      ],
                                    );
                                  } else if (snapshot.hasError) {
                                    return _buildErrorState(snapshot.error.toString());
                                  }
                                  return _buildLoadingState();
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPredictionItem(dynamic item) {
    final hasdiabetes = item['diabetes_prediction'] == '1' || item['diabetes_prediction'] == 1;
    final hashypertension = item['hypertension_prediction'] == '1' || item['hypertension_prediction'] == 1;
    final hasmaternalrisk = item['maternal_health_prediction'] == 'high risk' || 
                            item['maternal_health_prediction'] == 'High Risk';
    
    final hasRisk = hasdiabetes || hashypertension || hasmaternalrisk;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasRisk 
            ? [
                const Color(0xFFFCEFEE),
                const Color(0xFFFDF2F8),
              ]
            : [
                const Color(0xFFF0F9FF),
                const Color(0xFFF8FAFC),
              ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasRisk 
            ? const Color(0xFFFC5C9C).withOpacity(0.2)
            : const Color(0xFF4DBAFF).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasRisk 
              ? const Color(0xFFFC5C9C).withOpacity(0.1)
              : const Color(0xFF4DBAFF).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: hasRisk 
                              ? [const Color(0xFFFC5C9C), const Color(0xFFEC4899)]
                              : [const Color(0xFF4DBAFF), const Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            (item['nama'] ?? 'N').toString().substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama'] ?? 'Tidak ada nama',
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pemeriksaan ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              style: TextStyle(
                                color: const Color(0xFF1E293B).withOpacity(0.6),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasRisk 
                        ? [const Color(0xFFFC5C9C), const Color(0xFFEC4899)]
                        : [const Color(0xFF4DBAFF), const Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (hasRisk ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF)).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasRisk ? Icons.warning_rounded : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasRisk ? 'Berisiko' : 'Sehat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Health metrics in cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard("Umur", "${item['age'] ?? 'N/A'} tahun", Icons.person_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard("BMI", item['bmi']?.toString() ?? 'N/A', Icons.monitor_weight_rounded)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard("Tekanan Darah", "${item['systolic_bp'] ?? 'N/A'}/${item['diastolic_bp'] ?? 'N/A'}", Icons.favorite_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard("Gula Darah", "${item['bs'] ?? 'N/A'} mg/dL", Icons.water_drop_rounded)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Prediction badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildEnhancedPredictionBadge("Diabetes", hasdiabetes, Icons.water_drop_rounded),
                _buildEnhancedPredictionBadge("Hipertensi", hashypertension, Icons.favorite_rounded),
                _buildEnhancedPredictionBadge("Risiko Maternal", hasmaternalrisk, Icons.pregnant_woman_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF4DBAFF),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF1E293B).withOpacity(0.7),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
    );
  }

  Widget _buildEnhancedPredictionBadge(String label, bool isPositive, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive 
            ? [const Color(0xFFFCCCE2), const Color(0xFFFDF2F8)]
            : [const Color(0xFFAEE2FF), const Color(0xFFF0F9FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF)).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4DBAFF), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada data pemeriksaan',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan data pemeriksaan pertama Anda',
            style: TextStyle(
              color: const Color(0xFF1E293B).withOpacity(0.6),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFC5C9C), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Terjadi kesalahan',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF1E293B).withOpacity(0.6),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4DBAFF), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Memuat data...',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}