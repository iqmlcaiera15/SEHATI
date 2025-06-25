import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Sehati/view/homeprofile/selecticon.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DataFormPage extends StatefulWidget {
  const DataFormPage({Key? key}) : super(key: key);

  @override
  _DataFormPageState createState() => _DataFormPageState();
}

class _DataFormPageState extends State<DataFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = FlutterSecureStorage();
  bool _isLoading = false;
  String? _errorMessage;

  // Controller untuk setiap field
  final TextEditingController tanggalLahirController = TextEditingController();
  final TextEditingController usiaController = TextEditingController();
  final TextEditingController usiaKehamilanController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController nomorTeleponController = TextEditingController();
  final TextEditingController pendidikanTerakhirController =
      TextEditingController();
  final TextEditingController pekerjaanController = TextEditingController();
  final TextEditingController pekerjaanLainnyaController =
      TextEditingController(); // Untuk pekerjaan custom
  final TextEditingController golonganDarahController = TextEditingController();
  final TextEditingController namaSuamiController = TextEditingController();
  final TextEditingController teleponSuamiController = TextEditingController();
  final TextEditingController usiaSuamiController = TextEditingController();
  final TextEditingController pekerjaanSuamiController = TextEditingController();
  final TextEditingController pekerjaanSuamiLainnyaController =
      TextEditingController(); // Untuk pekerjaan suami custom

  // Dropdown values
  String? selectedGolonganDarah;
  String? selectedPendidikan;
  String? selectedPekerjaan;
  String? selectedPekerjaanSuami;

  // Dropdown options
  final List<String> golonganDarahOptions = ['A', 'B', 'AB', 'O'];
  final List<String> pendidikanOptions = [
    'SD',
    'SMP',
    'SMA/SMK',
    'D1',
    'D2',
    'D3',
    'S1',
    'S2',
    'S3',
  ];
  final List<String> pekerjaanOptions = [
    'Ibu Rumah Tangga',
    'Pegawai Negeri Sipil',
    'Pegawai Swasta',
    'Wiraswasta',
    'Petani',
    'Buruh',
    'Guru',
    'Perawat',
    'Bidan',
    'Dokter',
    'Pedagang',
    'Mahasiswa',
    'Tidak Bekerja',
    'Lainnya',
  ];

  // Method untuk mendapatkan JWT token dari secure storage
  Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  // Method untuk validasi tanggal
  bool _isValidDate(String dateString) {
    // Renamed the parameter to avoid conflict
    try {
      final parts = dateString.split('-');
      if (parts.length != 3) return false;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      if (year < 1900 || year > DateTime.now().year) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      // Validasi tanggal yang lebih detail
      final parsedDate = DateTime(
          year, month, day); // Use a different name for the DateTime object
      return parsedDate.year == year &&
          parsedDate.month == month &&
          parsedDate.day == day;
    } catch (e) {
      return false;
    }
  }

  // Method untuk validasi nomor telepon Indonesia
  bool _isValidPhoneNumber(String phone) {
    // Remove all spaces and special characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Indonesian phone number
    if (cleanPhone.startsWith('08') &&
        cleanPhone.length >= 10 &&
        cleanPhone.length <= 13) {
      return true;
    }
    if (cleanPhone.startsWith('628') &&
        cleanPhone.length >= 12 &&
        cleanPhone.length <= 15) {
      return true;
    }
    return false;
  }

  // ** BARU: Method untuk menampilkan kalender **
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)), // Default 25 tahun yang lalu
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'PILIH TANGGAL LAHIR',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
    );

    if (picked != null) {
      setState(() {
        // Format tanggal ke YYYY-MM-DD dan set ke controller
        tanggalLahirController.text =
            "${picked.year.toString()}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Fungsi untuk submit data ke API
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final token = await getJwtToken();

        if (token == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Anda belum login. Silakan login terlebih dahulu.')),
            );
          }
          setState(() {
            _isLoading = false;
            _errorMessage = 'Anda belum login. Silakan login terlebih dahulu.';
          });
          return;
        }

        // Prepare pekerjaan value
        String pekerjaanValue = selectedPekerjaan == 'Lainnya'
            ? pekerjaanLainnyaController.text
            : selectedPekerjaan ?? '';

        String pekerjaanSuamiValue = selectedPekerjaanSuami == 'Lainnya'
            ? pekerjaanSuamiLainnyaController.text
            : selectedPekerjaanSuami ?? '';

        final response = await http.post(
          Uri.parse('https://sehatiapp-production.up.railway.app/api/isidata'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'tanggal_lahir': tanggalLahirController.text,
            'usia': int.parse(usiaController.text),
            'usia_kehamilan': int.parse(usiaKehamilanController.text),
            'alamat': alamatController.text,
            'nomor_telepon': nomorTeleponController.text,
            'pendidikan_terakhir': selectedPendidikan,
            'pekerjaan': pekerjaanValue,
            'golongan_darah': selectedGolonganDarah,
            'nama_suami': namaSuamiController.text,
            'telepon_suami': teleponSuamiController.text,
            'usia_suami': int.parse(usiaSuamiController.text),
            'pekerjaan_suami': pekerjaanSuamiValue,
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
              MaterialPageRoute(builder: (context) => const SelectProfilePage()),
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
              _errorMessage = validationErrorMessage;
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
            errorMsg = responseData['message'] ??
                'Gagal mengirim data: ${response.statusCode}';
          } catch (e) {
            errorMsg =
                'Server error: ${response.statusCode}. Detail: ${response.body}';
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
            // Background with gradient
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

            // Back Button
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
                  child:
                      const Icon(Icons.arrow_back, color: Color(0xFF4DBAFF)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Welcome Text
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
                                  color:
                                      const Color(0xFF4DBAFF).withOpacity(0.3),
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

                    // Error message display
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCEFEE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFC5C9C).withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFFC5C9C)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style:
                                    const TextStyle(color: Color(0xFFFC5C9C)),
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

                    // ** DIMODIFIKASI: Date of birth field **
                    _buildInputField(
                      controller: tanggalLahirController,
                      label: 'Tanggal Lahir',
                      icon: Icons.calendar_today_outlined,
                      hint: 'Pilih tanggal lahir Anda',
                      readOnly: true, // Membuat field tidak bisa diketik
                      onTap: () { // Menjalankan _selectDate ketika diketuk
                        _selectDate(context);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal lahir tidak boleh kosong';
                        }
                        if (!_isValidDate(value)) {
                          return 'Format tanggal tidak valid (YYYY-MM-DD)';
                        }
                        // Check if date is not in the future
                        try {
                          final inputDate = DateTime.parse(value);
                          if (inputDate.isAfter(DateTime.now())) {
                            return 'Tanggal lahir tidak boleh di masa depan';
                          }
                          // Check if age is reasonable (between 12 and 50 years old)
                          final age =
                              DateTime.now().difference(inputDate).inDays /
                                  365;
                          if (age < 12 || age > 50) {
                            return 'Usia harus antara 12-50 tahun';
                          }
                        } catch (e) {
                          return 'Format tanggal tidak valid';
                        }
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
                        final age = int.tryParse(value);
                        if (age == null) {
                          return 'Usia harus berupa angka';
                        }
                        if (age < 12 || age > 50) {
                          return 'Usia harus antara 12-50 tahun';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Usia Kehamilan field
                    _buildInputField(
                      controller: usiaKehamilanController,
                      label: 'Usia Kehamilan (Minggu)',
                      icon: Icons.pregnant_woman_outlined,
                      keyboardType: TextInputType.number,
                      hint: 'Contoh: 12 (1-42 minggu)',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Usia kehamilan tidak boleh kosong';
                        }
                        final weeks = int.tryParse(value);
                        if (weeks == null) {
                          return 'Usia kehamilan harus berupa angka';
                        }
                        if (weeks < 1 || weeks > 42) {
                          return 'Usia kehamilan harus antara 1-42 minggu';
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
                        if (value.length < 10) {
                          return 'Alamat terlalu singkat (minimal 10 karakter)';
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
                        if (!_isValidPhoneNumber(value)) {
                          return 'Format nomor telepon tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pendidikan Dropdown
                    _buildDropdownField(
                      value: selectedPendidikan,
                      label: 'Pendidikan Terakhir',
                      icon: Icons.school_outlined,
                      items: pendidikanOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedPendidikan = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pendidikan terakhir harus dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pekerjaan Dropdown
                    _buildDropdownField(
                      value: selectedPekerjaan,
                      label: 'Pekerjaan',
                      icon: Icons.work_outline,
                      items: pekerjaanOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedPekerjaan = value;
                          if (value != 'Lainnya') {
                            pekerjaanLainnyaController.clear();
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pekerjaan harus dipilih';
                        }
                        return null;
                      },
                    ),

                    // Pekerjaan Lainnya field (conditional)
                    if (selectedPekerjaan == 'Lainnya') ...[
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: pekerjaanLainnyaController,
                        label: 'Pekerjaan Lainnya',
                        icon: Icons.work_outline,
                        hint: 'Sebutkan pekerjaan Anda',
                        validator: (value) {
                          if (selectedPekerjaan == 'Lainnya' &&
                              (value == null || value.isEmpty)) {
                            return 'Pekerjaan lainnya tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Golongan Darah Dropdown
                    _buildDropdownField(
                      value: selectedGolonganDarah,
                      label: 'Golongan Darah',
                      icon: Icons.bloodtype_outlined,
                      items: golonganDarahOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedGolonganDarah = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Golongan darah harus dipilih';
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
                        if (value.length < 2) {
                          return 'Nama suami terlalu singkat';
                        }
                        // Check if name contains only letters and spaces
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Nama hanya boleh mengandung huruf dan spasi';
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
                        if (!_isValidPhoneNumber(value)) {
                          return 'Format nomor telepon tidak valid';
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
                        final age = int.tryParse(value);
                        if (age == null) {
                          return 'Usia suami harus berupa angka';
                        }
                        if (age < 18 || age > 70) {
                          return 'Usia suami harus antara 18-70 tahun';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pekerjaan Suami Dropdown
                    _buildDropdownField(
                      value: selectedPekerjaanSuami,
                      label: 'Pekerjaan Suami',
                      icon: Icons.work_outline,
                      items: pekerjaanOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedPekerjaanSuami = value;
                          if (value != 'Lainnya') {
                            pekerjaanSuamiLainnyaController.clear();
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pekerjaan suami harus dipilih';
                        }
                        return null;
                      },
                    ),

                    // Pekerjaan Suami Lainnya field (conditional)
                    if (selectedPekerjaanSuami == 'Lainnya') ...[
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: pekerjaanSuamiLainnyaController,
                        label: 'Pekerjaan Suami Lainnya',
                        icon: Icons.work_outline,
                        hint: 'Sebutkan pekerjaan suami',
                        validator: (value) {
                          if (selectedPekerjaanSuami == 'Lainnya' &&
                              (value == null || value.isEmpty)) {
                            return 'Pekerjaan suami lainnya tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
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

  // ** DIMODIFIKASI: Helper _buildInputField **
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
    bool readOnly = false,     // Parameter baru
    VoidCallback? onTap,      // Parameter baru
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
        readOnly: readOnly, // Digunakan di sini
        onTap: onTap,       // Digunakan di sini
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Color(0xFF4C617F),
            fontSize: 14,
          ),
          hintStyle: TextStyle(
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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

  // Helper _buildDropdownField
  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
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
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF4C617F),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF4DBAFF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
        ),
        dropdownColor: Colors.white,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF4DBAFF),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    tanggalLahirController.dispose();
    usiaController.dispose();
    usiaKehamilanController.dispose();
    alamatController.dispose();
    nomorTeleponController.dispose();
    pendidikanTerakhirController.dispose();
    pekerjaanController.dispose();
    pekerjaanLainnyaController.dispose();
    golonganDarahController.dispose();
    namaSuamiController.dispose();
    teleponSuamiController.dispose();
    usiaSuamiController.dispose();
    pekerjaanSuamiController.dispose();
    pekerjaanSuamiLainnyaController.dispose();
    super.dispose();
  }
}