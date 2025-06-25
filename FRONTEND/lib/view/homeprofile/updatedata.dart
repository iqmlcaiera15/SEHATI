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
  late TextEditingController _namaSuamiController;
  late TextEditingController _teleponSuamiController;
  late TextEditingController _usiaSuamiController;
  late TextEditingController _usiaKehamilanController;

  // --- MODIFIKASI: Controller untuk field "Lainnya" ---
  late TextEditingController _pekerjaanLainnyaController;
  late TextEditingController _pekerjaanSuamiLainnyaController;

  // --- MODIFIKASI: State untuk Dropdown ---
  String? _selectedPendidikan;
  String? _selectedPekerjaan;
  String? _selectedGolonganDarah;
  String? _selectedPekerjaanSuami;

  // --- MODIFIKASI: Opsi untuk Dropdown ---
  final List<String> pendidikanOptions = ['SD','SMP','SMA/SMK','D1','D2','D3','S1','S2','S3',];
  final List<String> golonganDarahOptions = ['A', 'B', 'AB', 'O'];
  final List<String> pekerjaanOptions = ['Ibu Rumah Tangga','Pegawai Negeri Sipil','Pegawai Swasta','Wiraswasta','Petani','Buruh','Guru','Perawat','Bidan','Dokter','Pedagang','Mahasiswa','Tidak Bekerja','Lainnya',];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Inisialisasi controller standar
    _tanggalLahirController = TextEditingController(text: widget.userData['tanggal_lahir'] ?? '');
    _usiaController = TextEditingController(text: widget.userData['usia']?.toString() ?? '');
    _alamatController = TextEditingController(text: widget.userData['alamat'] ?? '');
    _nomorTeleponController = TextEditingController(text: widget.userData['nomor_telepon'] ?? '');
    _namaSuamiController = TextEditingController(text: widget.userData['nama_suami'] ?? '');
    _teleponSuamiController = TextEditingController(text: widget.userData['telepon_suami'] ?? '');
    _usiaSuamiController = TextEditingController(text: widget.userData['usia_suami']?.toString() ?? '');
    _usiaKehamilanController = TextEditingController(text: widget.userData['usia_kehamilan']?.toString() ?? '');

    // Inisialisasi controller untuk "Lainnya"
    _pekerjaanLainnyaController = TextEditingController();
    _pekerjaanSuamiLainnyaController = TextEditingController();

    // Logika untuk mengisi nilai awal dropdown dan field "Lainnya"
    _selectedPendidikan = widget.userData['pendidikan_terakhir'];
    _selectedGolonganDarah = widget.userData['golongan_darah'];

    // Pekerjaan Ibu
    final initialPekerjaan = widget.userData['pekerjaan'];
    if (initialPekerjaan != null && pekerjaanOptions.contains(initialPekerjaan)) {
      _selectedPekerjaan = initialPekerjaan;
    } else if (initialPekerjaan != null && initialPekerjaan.isNotEmpty) {
      _selectedPekerjaan = 'Lainnya';
      _pekerjaanLainnyaController.text = initialPekerjaan;
    }

    // Pekerjaan Suami
    final initialPekerjaanSuami = widget.userData['pekerjaan_suami'];
    if (initialPekerjaanSuami != null && pekerjaanOptions.contains(initialPekerjaanSuami)) {
      _selectedPekerjaanSuami = initialPekerjaanSuami;
    } else if (initialPekerjaanSuami != null && initialPekerjaanSuami.isNotEmpty) {
      _selectedPekerjaanSuami = 'Lainnya';
      _pekerjaanSuamiLainnyaController.text = initialPekerjaanSuami;
    }
  }

  @override
  void dispose() {
    _tanggalLahirController.dispose();
    _usiaController.dispose();
    _alamatController.dispose();
    _nomorTeleponController.dispose();
    _namaSuamiController.dispose();
    _teleponSuamiController.dispose();
    _usiaSuamiController.dispose();
    _usiaKehamilanController.dispose();
    _pekerjaanLainnyaController.dispose();
    _pekerjaanSuamiLainnyaController.dispose();
    super.dispose();
  }

  Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initial;
    try {
      initial = DateTime.parse(_tanggalLahirController.text);
    } catch (e) {
      initial = DateTime.now();
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
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

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap periksa kembali data yang Anda isi.'),
          backgroundColor: Colors.orange,
        ),
      );
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

      // --- MODIFIKASI: Menyiapkan data dari dropdown dan field lainnya ---
      String pekerjaanValue = _selectedPekerjaan ?? '';
      if (_selectedPekerjaan == 'Lainnya') {
        pekerjaanValue = _pekerjaanLainnyaController.text;
      }

      String pekerjaanSuamiValue = _selectedPekerjaanSuami ?? '';
      if (_selectedPekerjaanSuami == 'Lainnya') {
        pekerjaanSuamiValue = _pekerjaanSuamiLainnyaController.text;
      }

      Map<String, dynamic> requestData = {
        'tanggal_lahir': _tanggalLahirController.text.isNotEmpty ? _tanggalLahirController.text : null,
        'usia': _usiaController.text.isNotEmpty ? int.tryParse(_usiaController.text) : null,
        'alamat': _alamatController.text.isNotEmpty ? _alamatController.text : null,
        'nomor_telepon': _nomorTeleponController.text.isNotEmpty ? _nomorTeleponController.text : null,
        'pendidikan_terakhir': _selectedPendidikan,
        'pekerjaan': pekerjaanValue.isNotEmpty ? pekerjaanValue : null,
        'golongan_darah': _selectedGolonganDarah,
        'nama_suami': _namaSuamiController.text.isNotEmpty ? _namaSuamiController.text : null,
        'telepon_suami': _teleponSuamiController.text.isNotEmpty ? _teleponSuamiController.text : null,
        'usia_suami': _usiaSuamiController.text.isNotEmpty ? int.tryParse(_usiaSuamiController.text) : null,
        'pekerjaan_suami': pekerjaanSuamiValue.isNotEmpty ? pekerjaanSuamiValue : null,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diperbarui!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
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
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui data. Kode: ${response.statusCode}'),
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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

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
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF4C617F),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          suffixText: suffixText,
          suffixStyle: const TextStyle(
            color: Color(0xFF4C617F),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4DBAFF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFC5C9C), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFC5C9C), width: 2),
          ),
          filled: true,
          fillColor: readOnly ? const Color(0xFFF9F9F9) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // --- MODIFIKASI: Widget baru untuk membuat dropdown ---
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF4C617F),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4DBAFF), width: 2),
          ),
           errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFC5C9C), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFC5C9C), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4C617F),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value != null && value.isNotEmpty ? value : 'Tidak tersedia',
              style: TextStyle(
                color: value != null && value.isNotEmpty ? const Color(0xFF1E293B) : const Color(0xFF4C617F),
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
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Edit Data Pengguna',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4C617F)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateUserData,
            child: Text(
              'SIMPAN',
              style: TextStyle(
                color: _isLoading ? const Color(0xFF4C617F) : const Color(0xFF4DBAFF),
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
                children: const [
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
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x29000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Informasi Akun'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildReadOnlyField('Nama', widget.userData['name']),
                              _buildReadOnlyField('Email', widget.userData['email']),
                            ],
                          ),
                        ),

                        _buildSectionHeader('Data Pribadi'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // --- MODIFIKASI: Menggunakan _buildTextField dengan onTap untuk kalender ---
                              _buildTextField(
                                label: 'Tanggal Lahir',
                                controller: _tanggalLahirController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Tanggal lahir tidak boleh kosong';
                                  try { DateTime.parse(value); } catch (e) { return 'Format tanggal tidak valid'; }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                label: 'Usia',
                                controller: _usiaController,
                                keyboardType: TextInputType.number,
                                suffixText: 'tahun',
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Usia tidak boleh kosong';
                                  final age = int.tryParse(value);
                                  if (age == null || age < 12 || age > 60) return 'Usia harus antara 12-60';
                                  return null;
                                },
                              ),
                              _buildTextField(
                                label: 'Usia Kehamilan',
                                controller: _usiaKehamilanController,
                                keyboardType: TextInputType.number,
                                suffixText: 'minggu',
                                validator: (value) {
                                   if (value == null || value.isEmpty) return 'Usia kehamilan tidak boleh kosong';
                                   final weeks = int.tryParse(value);
                                   if (weeks == null || weeks < 1 || weeks > 42) return 'Isi antara 1-42 minggu';
                                   return null;
                                },
                              ),
                              _buildTextField(
                                label: 'Alamat',
                                controller: _alamatController,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Alamat tidak boleh kosong';
                                  if (value.length < 10) return 'Alamat minimal 10 karakter';
                                  return null;
                                },
                              ),
                              _buildTextField(
                                label: 'Nomor Telepon',
                                controller: _nomorTeleponController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Nomor telepon tidak boleh kosong';
                                  if (!RegExp(r'^(08|628)\d{8,13}$').hasMatch(value)) return 'Format nomor telepon tidak valid';
                                  return null;
                                },
                              ),
                              // --- MODIFIKASI: Menggunakan _buildDropdownField ---
                              _buildDropdownField(
                                label: 'Pendidikan Terakhir',
                                value: _selectedPendidikan,
                                items: pendidikanOptions,
                                onChanged: (newValue) => setState(() => _selectedPendidikan = newValue),
                                validator: (value) => value == null ? 'Pilih pendidikan terakhir' : null,
                              ),
                              _buildDropdownField(
                                label: 'Pekerjaan',
                                value: _selectedPekerjaan,
                                items: pekerjaanOptions,
                                onChanged: (newValue) => setState(() => _selectedPekerjaan = newValue),
                                validator: (value) => value == null ? 'Pilih pekerjaan' : null,
                              ),
                              if (_selectedPekerjaan == 'Lainnya')
                                _buildTextField(
                                  label: 'Sebutkan Pekerjaan',
                                  controller: _pekerjaanLainnyaController,
                                   validator: (value) {
                                    if (_selectedPekerjaan == 'Lainnya' && (value == null || value.isEmpty)) return 'Pekerjaan harus diisi';
                                    return null;
                                  },
                                ),
                              _buildDropdownField(
                                label: 'Golongan Darah',
                                value: _selectedGolonganDarah,
                                items: golonganDarahOptions,
                                onChanged: (newValue) => setState(() => _selectedGolonganDarah = newValue),
                                validator: (value) => value == null ? 'Pilih golongan darah' : null,
                              ),
                            ],
                          ),
                        ),

                        _buildSectionHeader('Data Suami'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                label: 'Nama Suami',
                                controller: _namaSuamiController,
                                validator: (value) {
                                   if (value != null && value.isNotEmpty && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'Nama hanya boleh mengandung huruf';
                                   return null;
                                }
                              ),
                              _buildTextField(
                                label: 'Telepon Suami',
                                controller: _teleponSuamiController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty && !RegExp(r'^(08|628)\d{8,13}$').hasMatch(value)) return 'Format nomor telepon tidak valid';
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
                                    if (age == null || age < 18 || age > 80) return 'Usia harus antara 18-80';
                                  }
                                  return null;
                                },
                              ),
                              // --- MODIFIKASI: Menggunakan _buildDropdownField untuk pekerjaan suami ---
                               _buildDropdownField(
                                label: 'Pekerjaan Suami',
                                value: _selectedPekerjaanSuami,
                                items: pekerjaanOptions,
                                onChanged: (newValue) => setState(() => _selectedPekerjaanSuami = newValue),
                              ),
                              if (_selectedPekerjaanSuami == 'Lainnya')
                                _buildTextField(
                                  label: 'Sebutkan Pekerjaan Suami',
                                  controller: _pekerjaanSuamiLainnyaController,
                                  validator: (value) {
                                    if (_selectedPekerjaanSuami == 'Lainnya' && (value == null || value.isEmpty)) return 'Pekerjaan suami harus diisi';
                                    return null;
                                  },
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateUserData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DBAFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
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
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'SIMPAN PERUBAHAN',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}