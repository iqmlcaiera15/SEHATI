import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Sehati/services/api/api_service_penyakit.dart';
import 'package:Sehati/view/deteksipenyakit/add_data_penyakit.dart';
import 'package:Sehati/view/deteksipenyakit/index_penyakit.dart';
import 'package:Sehati/view/komunitas/index_komunitas.dart';
import 'package:Sehati/view/polusiudara/index_polusi.dart';
import 'package:Sehati/view/homeprofile/profile.dart';
import 'package:Sehati/view/rekomenmakanan/index_rekomen.dart';
import 'package:Sehati/view/shop/shop_index.dart';
import 'package:Sehati/providers/auth_provider.dart';
import 'package:Sehati/services/api/dio_client.dart';
import 'package:Sehati/view/registerlogin/login_screen.dart';
import 'package:Sehati/view/prediksipersalinan/index_prediksi.dart';
import 'package:Sehati/view/asupanair/index_asupanair.dart';
import 'package:Sehati/view/kalkulatorhpl/index_hpl.dart';
import 'package:Sehati/view/kalkulatorhpl/kalkulator_hpl_intro.dart';
import 'package:intl/intl.dart';
import 'package:Sehati/view/prediksidepresi/index_depresi.dart'; 
import 'package:Sehati/view/kickcounter/index_kickcounter.dart'; 
import 'package:Sehati/view/postpartum/postpartum.dart'; 
import 'package:Sehati/services/api/api_service_hpl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _recentData;
  int _currentIndex = 0;
  final DioClient _dioClient = DioClient(); 
  String _protectedData = ''; // From first file
  bool _isLoading = false; 
  String? _hpl;
  int? _mingguKe;

  @override
  void initState() {
    super.initState();
    _loadRecentData();
    _fetchProtectedData(); // From first file (called once)
    _loadHPLFromApi();
  }

  @override
  void didChangeDependencies() {
  super.didChangeDependencies();
  _loadHPLFromApi();
}


  void _loadRecentData() {
    setState(() {
      // Limit to only 3 most recent entries
      _recentData = ApiService.fetchDeteksiData().then((data) {
        return data.take(3).toList();
      });
    });
  }

  // Tambahkan ini di dalam class _HomePageState, ganti _loadHPLData()
Future<void> _loadHPLFromApi() async {
  try {
    final dataList = await ApiServiceHPL.getDataHPL();
    if (dataList.isNotEmpty) {
      final latest = dataList.first;
      setState(() {
        _hpl = latest['hpl']?.toString() ?? latest['due_date']?.toString();
        _mingguKe = latest['minggu_ke'] is int
            ? latest['minggu_ke']
            : int.tryParse(latest['minggu_ke']?.toString() ?? latest['pregnancy_week']?.toString() ?? '0');
      });
    } else {
      setState(() {
        _hpl = null;
        _mingguKe = null;
      });
    }
  } catch (e) {
    setState(() {
      _hpl = null;
      _mingguKe = null;
    });
  }
}


  // From first file
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
        _protectedData = ''; // Clear data on error
        _isLoading = false;
      });
    }
  }

String _formatHPL(String? hpl) {
  if (hpl == null || hpl.isEmpty) return '-';
  try {
    // Tangani format YYYY-MM-DD atau YYYY-MM-DDTHH:MM:SS
    return DateFormat('dd MMM yy', 'id_ID').format(DateTime.parse(hpl));
  } catch (_) {
    try {
      // Tangani format DD-MM-YYYY
      final parts = hpl.split('-');
      if (parts.length == 3 && parts[0].length == 2) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final dt = DateTime(year, month, day);
        return DateFormat('dd MMM yy', 'id_ID').format(dt);
      }
    } catch (_) {}
    return hpl; // fallback tampilkan raw
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
            height: 44, // Standard status bar height might vary, consider SafeArea
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  left: 21,
                  top: 10.50,
                  child: SizedBox(
                    width: 54,
                    child: Text(
                      '', // Placeholder for time or other status icons
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
                // Battery/Wi-Fi icons are usually handled by the OS
              ],
            ),
          ),

          // App Bar (from first file, with logout)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container( // Left placeholder/icon
                  width: 24,
                  height: 24,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(),
                  child: const Stack(), // Could be a menu icon if needed
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
                Consumer<AuthProvider>( // Logout button from first file
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
                                : const SizedBox(), // Or a login icon if not authenticated
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
                    // Welcome Section (from first file, with dynamic name)
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
                              const Text(
                                'Pantau kesehatan kehamilan Anda bersama Sehati',
                                style: TextStyle(
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
                              Icon(Icons.calendar_today, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _mingguKe != null ? 'Minggu ke-$_mingguKe' : 'Minggu belum dihitung',
                                style: TextStyle(
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
                                'Prediksi Depresi Antenatal', // From second file
                                Icons.assignment_outlined, // Using icon from second file for depresi
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => IndexDepresi()),
                                  );
                                },
                              ),
                               _buildServiceItem( // From first file (prioritized)
                                'Prediksi Persalinan',
                                Icons.pregnant_woman_outlined,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => IndexPrediksi()),
                                  );
                                },
                              ),
                              // _buildServiceItem( // From second file (commented out)
                              // 'Konsultasi',
                              // Icons.chat_outlined,
                              // () {
                              //   // Navigate to consultation page
                              // },
                              // ),
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

                    // Health Tips Section (Combined into one ListView)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fitur Kesehatan Kehamilan lainnya', // Title from first file
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180, // Adjust height as needed for one row of cards
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // From first file
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => KalkulatorHPLIntro(
                                          onStart: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => const AddDataHPL()),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: _buildTipCard(
                                    'Kalkulator HPL',
                                    'Hitung perkiraan hari lahir bayi Anda secara cepat',
                                    Icons.date_range,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AsupanAirPage()));
                                  },
                                  child: _buildTipCard(
                                    'Hidrasi Harian',
                                    'Pantau asupan cairan Anda setiap hari',
                                    Icons.local_drink,
                                  ),
                                ),
                                // From second file
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => IndexKickCounter()));
                                  },
                                  child: _buildTipCard(
                                    'Hitung Tendangan Bayi',
                                    'Hitung tendangan untuk memantau kesehatan bayi',
                                    Icons.monitor_heart,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => IndexPostpartum()));
                                  },
                                  child: _buildTipCard(
                                    'Perawatan PostPartum',
                                    'Artikel perawatan setelah melahirkan',
                                    Icons.healing,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Protected Data Section (from first file)
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

  Widget _buildServiceItem(String label, IconData icon, VoidCallback onTap) {
    return Expanded( // Added Expanded to help with spacing if labels are long
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Added to prevent excessive vertical space
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
              overflow: TextOverflow.ellipsis, // Handles long labels better
              maxLines: 2, // Allow up to two lines for labels
            ),
          ],
        ),
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
            maxLines: 2, // Allow title to wrap
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded( // Allow description to take remaining space
            child: Text(
              description,
              style: const TextStyle(
                color: Color(0xFF4C617F),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3, // Adjust as needed
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

    Color cardColor = const Color(0xFFE0F7FA); // Light blue for healthy
    if (hasdiabetes || hashypertension || hasmaternalrisk) {
      cardColor = const Color(0xFFFCEFEE); // Light pink for risk
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
                      ? const Color(0xFFFC5C9C) // Pink
                      : const Color(0xFF4DBAFF), // Blue
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
          // Avoid pushing if already on the current page or handle differently
          if (index == 0 && !(ModalRoute.of(context)?.settings.name == 'HomePage')) { // Check if not already on HomePage
             Navigator.pushReplacement( // Use pushReplacement if you don't want to stack HomePages
               context,
               MaterialPageRoute(builder: (context) => const HomePage()),
             );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CommunityPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShopPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserDataViewPage()),
            );
          }
        });
      },
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4DBAFF),
      unselectedItemColor: const Color(0xFF4C617F),
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Poppins', // Ensure Poppins is in pubspec.yaml and assets
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Komunitas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}