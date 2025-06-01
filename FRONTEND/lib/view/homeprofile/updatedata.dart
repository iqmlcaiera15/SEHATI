import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserDataUpdatePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const UserDataUpdatePage({
    Key? key,
    required this.userData,
    required this.userId,
  }) : super(key: key);

  @override
  _UserDataUpdatePageState createState() => _UserDataUpdatePageState();
}

class _UserDataUpdatePageState extends State<UserDataUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = FlutterSecureStorage();
  bool _isLoading = false;

  // Controllers untuk form fields
  late TextEditingController _tanggalLahirController;
  late TextEditingController _usiaController;
  late TextEditingController _alamatController;
  late TextEditingController _nomorTeleponController;
  late TextEditingController _pendidikanTerakhirController;
  late TextEditingController _pekerjaanController;
  late TextEditingController _golonganDarahController;
  late TextEditingController _namaSuamiController;
  late TextEditingController _teleponSuamiController;
  late TextEditingController _usiaSuamiController;
  late TextEditingController _pekerjaanSuamiController;
  late TextEditingController _usiaKehamilanController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _tanggalLahirController = TextEditingController(text: widget.userData['tanggal_lahir'] ?? '');
    _usiaController = TextEditingController(text: widget.userData['usia']?.toString() ?? '');
    _alamatController = TextEditingController(text: widget.userData['alamat'] ?? '');
    _nomorTeleponController = TextEditingController(text: widget.userData['nomor_telepon'] ?? '');
    _pendidikanTerakhirController = TextEditingController(text: widget.userData['pendidikan_terakhir'] ?? '');
    _pekerjaanController = TextEditingController(text: widget.userData['pekerjaan'] ?? '');
    _golonganDarahController = TextEditingController(text: widget.userData['golongan_darah'] ?? '');
    _namaSuamiController = TextEditingController(text: widget.userData['nama_suami'] ?? '');
    _teleponSuamiController = TextEditingController(text: widget.userData['telepon_suami'] ?? '');
    _usiaSuamiController = TextEditingController(text: widget.userData['usia_suami']?.toString() ?? '');
    _pekerjaanSuamiController = TextEditingController(text: widget.userData['pekerjaan_suami'] ?? '');
    _usiaKehamilanController = TextEditingController(text: widget.userData['usia_kehamilan']?.toString() ?? '');
  }

  @override
  void dispose() {
    _tanggalLahirController.dispose();
    _usiaController.dispose();
    _alamatController.dispose();
    _nomorTeleponController.dispose();
    _pendidikanTerakhirController.dispose();
    _pekerjaanController.dispose();
    _golonganDarahController.dispose();
    _namaSuamiController.dispose();
    _teleponSuamiController.dispose();
    _usiaSuamiController.dispose();
    _pekerjaanSuamiController.dispose();
    _usiaKehamilanController.dispose();
    super.dispose();
  }

  // Method to get JWT token from secure storage
  Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  // Method untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        _tanggalLahirController.text = formattedDate;
      });
    }
  }

  // Method untuk update data
  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await getJwtToken();
      
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      // Prepare data untuk dikirim
      Map<String, dynamic> requestData = {
        'tanggal_lahir': _tanggalLahirController.text.isNotEmpty ? _tanggalLahirController.text : null,
        'usia': _usiaController.text.isNotEmpty ? int.tryParse(_usiaController.text) : null,
        'alamat': _alamatController.text.isNotEmpty ? _alamatController.text : null,
        'nomor_telepon': _nomorTeleponController.text.isNotEmpty ? _nomorTeleponController.text : null,
        'pendidikan_terakhir': _pendidikanTerakhirController.text.isNotEmpty ? _pendidikanTerakhirController.text : null,
        'pekerjaan': _pekerjaanController.text.isNotEmpty ? _pekerjaanController.text : null,
        'golongan_darah': _golonganDarahController.text.isNotEmpty ? _golonganDarahController.text : null,
        'nama_suami': _namaSuamiController.text.isNotEmpty ? _namaSuamiController.text : null,
        'telepon_suami': _teleponSuamiController.text.isNotEmpty ? _teleponSuamiController.text : null,
        'usia_suami': _usiaSuamiController.text.isNotEmpty ? int.tryParse(_usiaSuamiController.text) : null,
        'pekerjaan_suami': _pekerjaanSuamiController.text.isNotEmpty ? _pekerjaanSuamiController.text : null,
        'usia_kehamilan': _usiaKehamilanController.text.isNotEmpty ? int.tryParse(_usiaKehamilanController.text) : null,
      };

      final response = await http.post(
        Uri.parse('https://sehatiapp-production.up.railway.app/api/update-data/${widget.userId}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil diperbarui!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to profile page
        Navigator.of(context).pop(true); // Return true to indicate successful update
        
      } else if (response.statusCode == 422) {
        final responseData = json.decode(response.body);
        String errorMessage = 'Validasi gagal:\n';
        if (responseData['errors'] != null) {
          responseData['errors'].forEach((key, value) {
            if (value is List) {
              errorMessage += '• ${value.join(', ')}\n';
            }
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.trim()),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User tidak ditemukan.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui data. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Widget untuk membuat text field dengan desain yang konsisten
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    String? suffixText,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        style: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Color(0xFF4C617F),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          suffixText: suffixText,
          suffixStyle: TextStyle(
            color: Color(0xFF4C617F),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF4DBAFF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFFC5C9C), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFFC5C9C), width: 2),
          ),
          filled: true,
          fillColor: readOnly ? Color(0xFFF9F9F9) : Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // Widget untuk section header dengan desain yang konsisten
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

  // Widget untuk data field yang read-only dengan desain yang konsisten
  Widget _buildReadOnlyField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF4C617F),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value ?? 'Tidak tersedia',
              style: TextStyle(
                color: value != null ? Color(0xFF1E293B) : Color(0xFF4C617F),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          'Edit Data Pengguna',
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
          TextButton(
            onPressed: _isLoading ? null : _updateUserData,
            child: Text(
              'SIMPAN',
              style: TextStyle(
                color: _isLoading ? Color(0xFF4C617F) : Color(0xFF4DBAFF),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
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
                    'Menyimpan data...',
                    style: TextStyle(
                      color: Color(0xFF4C617F),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
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
                        // Informasi Akun (Read-only)
                        _buildSectionHeader('Informasi Akun'),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildReadOnlyField('Nama', widget.userData['name']),
                              _buildReadOnlyField('Email', widget.userData['email']),
                            ],
                          ),
                        ),

                        // Data Pribadi (Editable)
                        _buildSectionHeader('Data Pribadi'),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                label: 'Tanggal Lahir',
                                controller: _tanggalLahirController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    try {
                                      DateTime.parse(value);
                                    } catch (e) {
                                      return 'Format tanggal tidak valid';
                                    }
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Usia',
                                controller: _usiaController,
                                keyboardType: TextInputType.number,
                                suffixText: 'tahun',
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final age = int.tryParse(value);
                                    if (age == null || age < 0 || age > 150) {
                                      return 'Usia harus berupa angka antara 0-150';
                                    }
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Usia Kehamilan',
                                controller: _usiaKehamilanController,
                                keyboardType: TextInputType.number,
                                suffixText: 'minggu',
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final weeks = int.tryParse(value);
                                    if (weeks == null || weeks < 0 || weeks > 42) {
                                      return 'Usia kehamilan harus berupa angka antara 0-42';
                                    }
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Alamat',
                                controller: _alamatController,
                                maxLines: 3,
                              ),

                              _buildTextField(
                                label: 'Nomor Telepon',
                                controller: _nomorTeleponController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && value.length > 20) {
                                    return 'Nomor telepon maksimal 20 karakter';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Pendidikan Terakhir',
                                controller: _pendidikanTerakhirController,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && value.length > 255) {
                                    return 'Pendidikan terakhir maksimal 255 karakter';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Pekerjaan',
                                controller: _pekerjaanController,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && value.length > 255) {
                                    return 'Pekerjaan maksimal 255 karakter';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Golongan Darah',
                                controller: _golonganDarahController,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (value.length > 5) {
                                      return 'Golongan darah maksimal 5 karakter';
                                    }
                                    final validTypes = ['A', 'B', 'AB', 'O'];
                                    final bloodType = value.toUpperCase().replaceAll(RegExp(r'[+-]'), '');
                                    if (!validTypes.contains(bloodType)) {
                                      return 'Golongan darah tidak valid (A, B, AB, O)';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        // Data Suami (Editable)
                        _buildSectionHeader('Data Suami'),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                label: 'Nama Suami',
                                controller: _namaSuamiController,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && value.length > 255) {
                                    return 'Nama suami maksimal 255 karakter';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Telepon Suami',
                                controller: _teleponSuamiController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && value.length > 20) {
                                    return 'Telepon suami maksimal 20 karakter';
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Usia Suami',
                                controller: _usiaSuamiController,
                                keyboardType: TextInputType.number,
                                suffixText: 'tahun',
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final age = int.tryParse(value);
                                    if (age == null || age < 0 || age > 150) {
                                      return 'Usia suami harus berupa angka antara 0-150';
                                    }
                                  }
                                  return null;
                                },
                              ),

                              _buildTextField(
                                label: 'Pekerjaan Suami',
                                controller: _pekerjaanSuamiController,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && value.length > 255) {
                                    return 'Pekerjaan suami maksimal 255 karakter';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateUserData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4DBAFF),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Menyimpan...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'SIMPAN DATA',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Cancel Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF4DBAFF),
                              side: BorderSide(color: Color(0xFF4DBAFF)),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'BATAL',
                              style: TextStyle(
                                fontSize: 16,
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
    );
  }
}