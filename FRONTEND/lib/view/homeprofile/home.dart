import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Sehati/services/api/api_service_penyakit.dart';
import 'package:Sehati/view/deteksipenyakit/add_data_penyakit.dart';
import 'package:Sehati/view/deteksipenyakit/index_penyakit.dart'; 
import 'package:Sehati/view/komunitas/index_komunitas.dart'; 
import 'package:Sehati/view/polusiudara/index_polusi.dart'; 
import 'package:Sehati/view/rekomenmakanan/index_rekomen.dart';
import 'package:Sehati/providers/auth_provider.dart';
import 'package:Sehati/services/api/dio_client.dart';
import 'package:Sehati/view/registerlogin/login_screen.dart';
import 'package:Sehati/view/prediksipersalinan/index_prediksi.dart';
import 'package:Sehati/view/asupanair/index_asupanair.dart';
import 'package:Sehati/view/kalkulatorhpl/index_hpl.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _recentData;
  int _currentIndex = 0;
  final DioClient _dioClient = DioClient();
  String _protectedData = '';
  bool _isLoading = false;
  String? _hpl;
  int? _mingguKe;

  
  @override
  void initState() {
    super.initState();
    _loadRecentData();
    _fetchProtectedData();
    _fetchProtectedData();
    _loadHPLData(); // ← tambahan ini
  }

  void _loadRecentData() {
    setState(() {
      // Limit to only 3 most recent entries
      _recentData = ApiService.fetchDeteksiData().then((data) {
        return data.take(3).toList();
      });
    });
  }

  Future<void> _fetchProtectedData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dioClient.get('/protected-data');
      setState(() {
        _protectedData = response.data['message'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _protectedData = '';
        _isLoading = false;
      });
    }
  }

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
          
          // App Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(),
                  child: const Stack(),
                ),
                const Text(
                  'Sehati',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                    letterSpacing: 0.12,
                  ),
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return GestureDetector(
                      onTap: () async {
                        if (authProvider.isAuthenticated) {
                          final success = await authProvider.logout();
                          if (success && mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: Stack(
                          children: [
                            authProvider.isAuthenticated
                                ? const Icon(Icons.logout, size: 24, color: Color(0xFF4C617F))
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
                child: Column(
                  children: [
                    // Welcome Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          final user = authProvider.user;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user != null 
                                    ? 'Selamat Datang, ${user.name}!' 
                                    : 'Selamat Datang, Bunda!',
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pantau kesehatan kehamilan Anda bersama Sehati',
                                style: const TextStyle(
                                  color: Color(0xFF4C617F),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    // Quick Stats Banner
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 36),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4DBAFF), Color(0xFF2D9CFF)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x29000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _mingguKe != null ? 'Minggu ke-$_mingguKe' : 'Minggu belum dihitung',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('HPL', _formatHPL(_hpl)),
                              _buildStatItem('Usia', '30 tahun'),
                              _buildStatItem('BMI', '23.5'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Services Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Layanan Kesehatan',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildServiceItem(
                                'Deteksi Penyakit', 
                                Icons.medical_services_outlined,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const IndexPenyakit(),
                                    ),
                                  );
                                },
                              ),
                              _buildServiceItem(
                              'Deteksi Depresi', 
                              Icons.sentiment_dissatisfied_outlined,
                              () {
                                // TODO: Navigasi ke halaman deteksi depresi
                                // Navigator.push(context, MaterialPageRoute(builder: (_) => const DeteksiDepresiPage()));
                              },
                            ),
                                _buildServiceItem(
                                  'Prediksi Persalinan', 
                                  Icons.pregnant_woman_outlined,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => IndexPrediksi()),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Recent Health Data
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Riwayat Kesehatan Terbaru',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const IndexPenyakit(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Lihat Semua',
                                  style: TextStyle(
                                    color: Color(0xFF4DBAFF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: FutureBuilder(
                                future: _recentData,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final data = snapshot.data as List<dynamic>;
                                    if (data.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              const Icon(Icons.folder_open, color: Color(0xFF4DBAFF), size: 48),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'Belum ada data kesehatan',
                                                style: TextStyle(
                                                  color: Color(0xFF4C617F),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final result = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => const AddDataPenyakit(),
                                                    ),
                                                  );
                                                  
                                                  if (result == true) {
                                                    _loadRecentData();
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF4DBAFF),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                ),
                                                child: const Text(
                                                  'Tambah Data Baru',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: data.length,
                                      separatorBuilder: (context, index) => const Divider(
                                        color: Color(0xFFD9D9D9),
                                        thickness: 1,
                                      ),
                                      itemBuilder: (context, index) {
                                        final item = data[index];
                                        return _buildPredictionItem(item);
                                      },
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.error, color: Color(0xFFFC5C9C), size: 48),
                                          const SizedBox(height: 16),
                                          Text(
                                            "Error: ${snapshot.error}",
                                            style: const TextStyle(
                                              color: Color(0xFF1E293B),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(color: Color(0xFF4DBAFF)),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Health Tips Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fitur Kesehatan Kehamilan lainnya',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RekomendasiMakananPage()));
                                  },
                                  child: _buildTipCard(
                                    'Makanan Dengan Nutrisi Penting Untuk Ibu Hamil',
                                    'Penuhi kebutuhan gizi dengan makanan bergizi seimbang',
                                    Icons.restaurant,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const IndexPolusi()));
                                  },
                                  child: _buildTipCard(
                                    'Cek Kualitas Udara',
                                    'Cek Kualitas Udara Untuk Bandung dan Sekitarnya',
                                    Icons.wind_power_sharp,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // TODO: Navigasi ke halaman TidurPage
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => TidurPage()));
                                  },
                                  child: _buildTipCard(
                                    'Pola Tidur Sehat',
                                    'Istirahat cukup untuk kesehatan ibu dan janin',
                                    Icons.hotel,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // TODO: Navigasi ke Kalkulator HPL
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDataHPL()));
                                  },
                                  child: _buildTipCard(
                                    'Kalkulator HPL',
                                    'Hitung perkiraan hari lahir bayi Anda secara cepat',
                                    Icons.date_range,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // TODO: Navigasi ke Hidrasi Harian
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AsupanAirPage()));
                                  },
                                  child: _buildTipCard(
                                    'Hidrasi Harian',
                                    'Pantau asupan cairan Anda setiap hari',
                                    Icons.local_drink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Protected Data Section (only shown if authenticated)
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        if (!authProvider.isAuthenticated || _protectedData.isEmpty) {
                          return const SizedBox();
                        }
                        
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data Pribadi',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _isLoading
                                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF4DBAFF)))
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _protectedData,
                                            style: const TextStyle(
                                              color: Color(0xFF1E293B),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: _fetchProtectedData,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF4DBAFF),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Refresh Data',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    // Spacer at the bottom
                    const SizedBox(height: 75),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action menu button
        },
        backgroundColor: const Color(0xFFAEE2FF),
        child: const Icon(Icons.grid_view, color: Color(0xFF414549)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  Future<void> _loadHPLData() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _hpl = prefs.getString('last_hpl');
    _mingguKe = prefs.getInt('last_week');
  });
}

String _formatHPL(String? hpl) {
  if (hpl == null) return 'Belum dihitung';
  try {
    final parsedDate = DateTime.parse(hpl);
    return DateFormat('dd MMM yyyy').format(parsedDate);
  } catch (_) {
    return 'Format salah';
  }
}

  Widget _buildServiceItem(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF4DBAFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4DBAFF),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTipCard(String title, String description, IconData icon) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4DBAFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4DBAFF),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF4C617F),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionItem(dynamic item) {
    final hasdiabetes = item['diabetes_prediction'] == '1' || item['diabetes_prediction'] == 1;
    final hashypertension = item['hypertension_prediction'] == '1' || item['hypertension_prediction'] == 1;
    final hasmaternalrisk = item['maternal_health_prediction'] == 'high risk' || 
                            item['maternal_health_prediction'] == 'High Risk';
    
    Color cardColor = const Color(0xFFFDEFEE);
    if (hasdiabetes || hashypertension || hasmaternalrisk) {
      cardColor = const Color(0xFFFCEFEE);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['nama'] ?? 'No Name',
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: hasdiabetes || hashypertension || hasmaternalrisk
                      ? const Color(0xFFFC5C9C)
                      : const Color(0xFF4DBAFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  hasdiabetes || hashypertension || hasmaternalrisk ? 'Berisiko' : 'Sehat',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDataRow("Umur", item['age']?.toString() ?? 'N/A'),
          _buildDataRow("BMI", item['bmi']?.toString() ?? 'N/A'),
          _buildDataRow("Tekanan Darah", "${item['systolic_bp'] ?? 'N/A'}/${item['diastolic_bp'] ?? 'N/A'} mmHg"),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              _buildPredictionBadge("Diabetes", hasdiabetes),
              const SizedBox(width: 8),
              _buildPredictionBadge("Hipertensi", hashypertension),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          // Tambahkan logika navigasi di sini
          if (index == 1) { // Indeks untuk item 'Komunitas' (dimulai dari 0)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CommunityPage()),
            );
          } else if (index == 0) {
            // Navigasi ke halaman Beranda (jika Anda punya halaman Beranda terpisah)
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const BerandaPage()),
            // );
          } else if (index == 3) {
            // Navigasi ke halaman Tersimpan
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const TersimpanPage()),
            // );
          } else if (index == 4) {
            // Navigasi ke halaman Profil
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const ProfilPage()),
            // );
          }
        });
      },
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4DBAFF),
      unselectedItemColor: const Color(0xFF4C617F),
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Komunitas',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(), // Empty space for FAB
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Tersimpan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}