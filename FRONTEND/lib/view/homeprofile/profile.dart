import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Sehati/view/homeprofile/updatedata.dart';
import 'package:Sehati/view/homeprofile/updateicon.dart';

class UserDataViewPage extends StatefulWidget {
  @override
  _UserDataViewPageState createState() => _UserDataViewPageState();
}

class _UserDataViewPageState extends State<UserDataViewPage> {
  final _secureStorage = FlutterSecureStorage();
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

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
        setState(() {
          _errorMessage = 'Anda belum login. Silakan login terlebih dahulu.';
          _isLoading = false;
        });
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
          _errorMessage = 'Gagal memuat data. Silakan coba lagi.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
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
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(': '),
          Expanded(
            child: Text(
              value ?? 'Tidak tersedia',
              style: TextStyle(
                color: value != null ? Colors.black87 : Colors.grey,
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
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  // Widget untuk menampilkan gambar profil user
  Widget _buildUserProfileImage() {
    final imageUrl = _userData?['selected_icon_data_cache'];
    
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue[300]!,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 3),
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
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[500],
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey[500],
                      ),
                    ),
            ),
          ),
          // Tombol untuk ganti gambar (akan diimplementasi nanti)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
               onTap: () {
                Navigator.pushReplacement(
                  context,
                MaterialPageRoute(builder: (context) =>   SelectProfilePage()), // Assuming HomePage has a const constructor
               );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Pengguna'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
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
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[600],
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Profile Image Section
                            _buildUserProfileImage(),
                            
                            Divider(height: 32),
                            
                            // User Info Section
                            _buildSectionHeader('Informasi Akun'),
                            _buildDataField('Nama', _userData?['name']),
                            _buildDataField('Email', _userData?['email']),
                            
                            Divider(height: 32),
                            
                            // Personal Data Section
                            _buildSectionHeader('Data Pribadi'),
                            _buildDataField('Tanggal Lahir', _userData?['tanggal_lahir']),
                            _buildDataField('Usia', _userData?['usia']?.toString()),
                            _buildDataField('Usia Kehamilan', _userData?['usia_kehamilan']?.toString() != null 
                                ? '${_userData?['usia_kehamilan']} minggu' 
                                : null),
                            _buildDataField('Alamat', _userData?['alamat']),
                            _buildDataField('Nomor Telepon', _userData?['nomor_telepon']),
                            _buildDataField('Pendidikan Terakhir', _userData?['pendidikan_terakhir']),
                            _buildDataField('Pekerjaan', _userData?['pekerjaan']),
                            _buildDataField('Golongan Darah', _userData?['golongan_darah']),
                            
                            Divider(height: 32),
                            
                            // Husband Data Section
                            _buildSectionHeader('Data Suami'),
                            _buildDataField('Nama Suami', _userData?['nama_suami']),
                            _buildDataField('Telepon Suami', _userData?['telepon_suami']),
                            _buildDataField('Usia Suami', _userData?['usia_suami']?.toString()),
                            _buildDataField('Pekerjaan Suami', _userData?['pekerjaan_suami']),
                            
                            SizedBox(height: 24),
                            
                            // Last updated info
                            if (_userData?['updated_at'] != null)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Terakhir diperbarui: ${_userData?['updated_at']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
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
                        onPressed: () async { // Make onPressed async to await Navigator.push
                          // Navigasi ke UserDataUpdatePage
                          if (_userData != null && _userData!['id'] != null) { // Ensure userData and its 'id' key are available
                            final result = await Navigator.push( // await the result of the push
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserDataUpdatePage(
                                  userData: _userData!, // Pass the fetched user data
                                  userId: _userData!['id'].toString(), // Pass the user ID (assuming key is 'id' and converting to string)
                                ),
                              ),
                            );

                            if (result == true) { // If UserDataUpdatePage returned true (indicating successful update)
                              _refreshData(); // Refresh the data on UserDataViewPage
                            }
                          } else {
                            // Handle the case where userData or userId is null
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Data pengguna tidak lengkap atau ID pengguna tidak ditemukan untuk diedit.')),
                            );
                          }
                        },
                        child: Icon(Icons.edit),
                        backgroundColor: Colors.blue[600],
                        tooltip: 'Edit Data Profil',
                      )
                    : null, // FAB tidak akan tampil jika _userData null
                );
                }
}