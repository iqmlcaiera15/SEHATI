import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Sehati/view/homeprofile/updatedata.dart';
import 'package:Sehati/view/homeprofile/updateicon.dart';
import 'package:Sehati/view/homeprofile/home.dart';
import 'package:Sehati/view/komunitas/index_komunitas.dart';
import 'package:Sehati/view/shop/shop_index.dart'; 

class UserDataViewPage extends StatefulWidget {
  @override
  _UserDataViewPageState createState() => _UserDataViewPageState();
}

class _UserDataViewPageState extends State<UserDataViewPage> {
  final _secureStorage = FlutterSecureStorage();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _errorMessage;
  int _currentIndex = 3; // Indeks untuk halaman Profil

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Method to get JWT token from secure storage
  Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  // Fetch user data from API
  Future<void> _fetchUserData() async {
     try {
      final token = await getJwtToken();
      
      if (token == null) {
        if(mounted){
          setState(() {
            _errorMessage = 'Anda belum login. Silakan login terlebih dahulu.';
            _isLoading = false;
          });
        }
        return;
      }

      final response = await http.get(
        Uri.parse('https://sehatiapp-production.up.railway.app/api/user-data'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      
      if(!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _userData = responseData['data'] ?? responseData;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Data tidak ditemukan. Silakan lengkapi data Anda terlebih dahulu.';
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data (${response.statusCode}). Silakan coba lagi.';
        });
      }
    } catch (e) {
      if(mounted){
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan: $e';
        });
      }
    }
  }

  // Refresh data
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _userData = null;
    });
    await _fetchUserData();
  }

  // Helper method to display data field
  Widget _buildDataField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Tidak tersedia',
              style: TextStyle(
                color: value != null ? Color(0xFF1E293B) : Color(0xFF4C617F),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  // Widget untuk menampilkan gambar profil user
  Widget _buildUserProfileImage() {
    final imageUrl = _userData?['selected_icon_data_cache'];
    
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF4DBAFF),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x29000000),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 120,
                          height: 120,
                          color: Color(0xFFF4F4F4),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: Color(0xFF4DBAFF),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: Color(0xFFF4F4F4),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF4C617F),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: Color(0xFFF4F4F4),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF4C617F),
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectProfilePage()),
                  ).then((_) => _refreshData());
                },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(0xFF4DBAFF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x29000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk membangun Bottom Navigation Bar
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (!mounted) return;
        if (_currentIndex == index && index == 3) return;

        setState(() {
          _currentIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CommunityPage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ShopPage()),
            );
            break;
          case 3:
            if (ModalRoute.of(context)?.settings.name != '/user_data_view') {
                 Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserDataViewPage(), settings: RouteSettings(name: '/user_data_view')),
                );
            }
            break;
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          'Data Pengguna',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF4C617F)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF4DBAFF)),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4DBAFF)),
                  SizedBox(height: 16),
                  Text(
                    'Memuat data...',
                    style: TextStyle(
                      color: Color(0xFF4C617F),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFFCEFEE),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Color(0xFFFC5C9C),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: Text(
                            'Coba Lagi',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4DBAFF),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Color(0xFF4DBAFF),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x29000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUserProfileImage(),
                            Divider(height: 32, color: Color(0xFFF4F4F4), thickness: 2),
                            
                            _buildSectionHeader('Informasi Akun'),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildDataField('Nama', _userData?['name']),
                                  _buildDataField('Email', _userData?['email']),
                                ],
                              ),
                            ),
                            
                            _buildSectionHeader('Data Pribadi'),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildDataField('Tanggal Lahir', _userData?['tanggal_lahir']),
                                  _buildDataField('Usia', _userData?['usia']?.toString()),
                                  _buildDataField(
                                      'Usia Kehamilan',
                                      _userData?['usia_kehamilan'] != null
                                          ? '${_userData!['usia_kehamilan']} minggu'
                                          : null),
                                  _buildDataField('Alamat', _userData?['alamat']),
                                  _buildDataField('Nomor Telepon', _userData?['nomor_telepon']),
                                  _buildDataField('Pendidikan Terakhir', _userData?['pendidikan_terakhir']),
                                  _buildDataField('Pekerjaan', _userData?['pekerjaan']),
                                  _buildDataField('Golongan Darah', _userData?['golongan_darah']),
                                ],
                              ),
                            ),
                            
                            _buildSectionHeader('Data Suami'),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildDataField('Nama Suami', _userData?['nama_suami']),
                                  _buildDataField('Telepon Suami', _userData?['telepon_suami']),
                                  _buildDataField('Usia Suami', _userData?['usia_suami']?.toString()),
                                  _buildDataField('Pekerjaan Suami', _userData?['pekerjaan_suami']),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 24),
                            if (_userData?['updated_at'] != null)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF4F4F4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Terakhir diperbarui: ${_userData?['updated_at']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4C617F),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: _userData != null
          ? FloatingActionButton(
              onPressed: () async {
                if (_userData != null && _userData!['id'] != null) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDataUpdatePage(
                        userData: _userData!,
                        userId: _userData!['id'].toString(),
                      ),
                    ),
                  );
                  if (result == true && mounted) {
                    _refreshData();
                  }
                } else {
                   if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Data pengguna tidak lengkap atau ID pengguna tidak ditemukan untuk diedit.'),
                      backgroundColor: Color(0xFFFC5C9C),
                    ),
                    );
                   }
                }
              },
              child: Icon(Icons.edit, color: Colors.white),
              backgroundColor: Color(0xFF4DBAFF),
              tooltip: 'Edit Data Profil',
              elevation: 4,
            )
          : null,
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}