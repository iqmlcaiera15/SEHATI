import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:Sehati/view/homeprofile/home.dart'; // Diganti dengan SelectProfilePage jika itu tujuan akhir
import 'package:Sehati/view/homeprofile/selecticon.dart'; // Dari kode kedua
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Dari kode kedua

class DataFormPage extends StatefulWidget {
  const DataFormPage({Key? key}) : super(key: key);

  @override
  _DataFormPageState createState() => _DataFormPageState();
}

class _DataFormPageState extends State<DataFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = FlutterSecureStorage(); // Instance FlutterSecureStorage
  bool _isLoading = false;
  String? _errorMessage;

  // Controller untuk setiap field
  final TextEditingController tanggalLahirController = TextEditingController();
  final TextEditingController usiaController = TextEditingController();
  final TextEditingController usiaKehamilanController = TextEditingController(); // Field baru
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController nomorTeleponController = TextEditingController();
  final TextEditingController pendidikanTerakhirController = TextEditingController();
  final TextEditingController pekerjaanController = TextEditingController();
  final TextEditingController golonganDarahController = TextEditingController();
  final TextEditingController namaSuamiController = TextEditingController();
  final TextEditingController teleponSuamiController = TextEditingController();
  final TextEditingController usiaSuamiController = TextEditingController();
  final TextEditingController pekerjaanSuamiController = TextEditingController();

  // Method untuk mendapatkan JWT token dari secure storage
  Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  // Fungsi untuk submit data ke API
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null; // Reset error message
      });

      try {
        final token = await getJwtToken();

        if (token == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Anda belum login. Silakan login terlebih dahulu.')),
            );
          }
          setState(() {
            _isLoading = false;
            _errorMessage = 'Anda belum login. Silakan login terlebih dahulu.';
          });
          return;
        }

        final response = await http.post(
          Uri.parse('https://sehatiapp-production.up.railway.app/api/isidata'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token', // Tambahkan token ke header
            'Accept': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'tanggal_lahir': tanggalLahirController.text,
            'usia': usiaController.text,
            'usia_kehamilan': usiaKehamilanController.text, // Field baru ditambahkan
            'alamat': alamatController.text,
            'nomor_telepon': nomorTeleponController.text,
            'pendidikan_terakhir': pendidikanTerakhirController.text,
            'pekerjaan': pekerjaanController.text,
            'golongan_darah': golonganDarahController.text,
            'nama_suami': namaSuamiController.text,
            'telepon_suami': teleponSuamiController.text,
            'usia_suami': usiaSuamiController.text,
            'pekerjaan_suami': pekerjaanSuamiController.text,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data berhasil disimpan')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SelectProfilePage()), // Navigasi ke SelectProfilePage
            );
          }
        } else if (response.statusCode == 422) {
          try {
            Map<String, dynamic> responseBody = json.decode(response.body);
            Map<String, dynamic> errors = responseBody['errors'] ?? {};
            String validationErrorMessage = 'Validasi gagal:\n';
            errors.forEach((field, messages) {
              if (messages is List) {
                validationErrorMessage += '- ${messages.join(', ')}\n';
              } else {
                validationErrorMessage += '- $messages\n';
              }
            });
            _showValidationErrorDialog(validationErrorMessage);
            setState(() {
              _errorMessage = validationErrorMessage; // Update UI error message
            });
          } catch (e) {
             final errorParsing = 'Error parsing validation errors: $e';
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorParsing)),
                );
            }
            setState(() {
                _errorMessage = errorParsing;
            });
          }
        } else {
          String errorMsg = 'Gagal mengirim data';
          try {
            Map<String, dynamic> responseData = json.decode(response.body);
            errorMsg = responseData['message'] ?? 'Gagal mengirim data: ${response.statusCode}';
          } catch (e) {
            errorMsg = 'Server error: ${response.statusCode}. Detail: ${response.body}';
          }
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMsg)),
            );
           }
          setState(() {
            _errorMessage = errorMsg;
          });
        }
      } catch (e) {
        final generalError = 'Error: $e';
        setState(() {
          _isLoading = false;
          _errorMessage = generalError;
        });
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(generalError)),
            );
        }
      }
    }
  }

  // Helper method untuk menampilkan error validasi dalam dialog
  void _showValidationErrorDialog(String errorMessage) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Validasi Gagal'),
          content: SingleChildScrollView(
            child: Text(errorMessage),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background with gradient (dipertahankan dari kode asli)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Color(0xFFAEE2FF).withOpacity(0.3),
                    Colors.white,
                  ],
                ),
              ),
            ),

            // Back Button (dipertahankan dari kode asli)
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
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
                  child: const Icon(Icons.arrow_back, color: Color(0xFF4DBAFF)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Main content (dipertahankan dari kode asli)
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Welcome Text (dipertahankan dari kode asli)
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF4DBAFF), Color(0xFF2D9CFF)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4DBAFF).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "S",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Data Pribadi',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Lengkapi data diri untuk pemantauan kehamilan yang optimal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF4C617F),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    // Error message display (dipertahankan dari kode asli)
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCEFEE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFC5C9C).withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFFC5C9C)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Color(0xFFFC5C9C)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Personal Information Form title
                    const Text(
                      'Informasi Pribadi',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date of birth field
                    _buildInputField(
                      controller: tanggalLahirController,
                      label: 'Tanggal Lahir',
                      icon: Icons.calendar_today_outlined,
                      hint: 'YYYY-MM-DD', // Diubah format hint agar lebih jelas
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal lahir tidak boleh kosong';
                        }
                        // Anda bisa menambahkan validasi format tanggal di sini jika perlu
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Age field
                    _buildInputField(
                      controller: usiaController,
                      label: 'Usia (Tahun)',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.number,
                      hint: 'Contoh: 28',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Usia tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                            return 'Usia harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Usia Kehamilan field (BARU)
                    _buildInputField(
                      controller: usiaKehamilanController,
                      label: 'Usia Kehamilan (Minggu)',
                      icon: Icons.pregnant_woman_outlined, // Contoh icon
                      keyboardType: TextInputType.number,
                      hint: 'Contoh: 12',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Usia kehamilan tidak boleh kosong';
                        }
                         if (int.tryParse(value) == null) {
                            return 'Usia kehamilan harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address field
                    _buildInputField(
                      controller: alamatController,
                      label: 'Alamat',
                      icon: Icons.home_outlined,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone number field
                    _buildInputField(
                      controller: nomorTeleponController,
                      label: 'Nomor Telepon',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      hint: 'Contoh: 081234567890',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: pendidikanTerakhirController,
                      label: 'Pendidikan Terakhir',
                      icon: Icons.school_outlined,
                      hint: 'Contoh: S1, SMA, dll',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pendidikan terakhir tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: pekerjaanController,
                      label: 'Pekerjaan',
                      icon: Icons.work_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pekerjaan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: golonganDarahController,
                      label: 'Golongan Darah',
                      icon: Icons.bloodtype_outlined,
                      hint: 'A, B, AB, atau O',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Golongan darah tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Husband Information title
                    const Text(
                      'Informasi Suami',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: namaSuamiController,
                      label: 'Nama Suami',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama suami tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: teleponSuamiController,
                      label: 'Telepon Suami',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      hint: 'Contoh: 081234567890',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon suami tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: usiaSuamiController,
                      label: 'Usia Suami (Tahun)',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.number,
                      hint: 'Contoh: 30',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Usia suami tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                            return 'Usia suami harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: pekerjaanSuamiController,
                      label: 'Pekerjaan Suami',
                      icon: Icons.work_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pekerjaan suami tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : submitForm,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF4DBAFF),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Simpan Data',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper _buildInputField (dipertahankan dari kode asli)
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Color(0xFF4C617F),
            fontSize: 14,
          ),
          hintStyle: TextStyle( // Ditambahkan untuk hint
            color: const Color(0xFF4C617F).withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF4DBAFF)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
        ),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    tanggalLahirController.dispose();
    usiaController.dispose();
    usiaKehamilanController.dispose(); // Jangan lupa dispose controller baru
    alamatController.dispose();
    nomorTeleponController.dispose();
    pendidikanTerakhirController.dispose();
    pekerjaanController.dispose();
    golonganDarahController.dispose();
    namaSuamiController.dispose();
    teleponSuamiController.dispose();
    usiaSuamiController.dispose();
    pekerjaanSuamiController.dispose();
    super.dispose();
  }
}