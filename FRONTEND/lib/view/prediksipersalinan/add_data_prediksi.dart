import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_prediksi.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result_prediksi.dart';

class AddDataPrediksi extends StatefulWidget {
  const AddDataPrediksi({super.key});

  @override
  State<AddDataPrediksi> createState() => _AddDataPrediksiState();
}

class _AddDataPrediksiState extends State<AddDataPrediksi> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usiaIbuController = TextEditingController();
  final TextEditingController riwayatKesehatanIbuController = TextEditingController();
  final TextEditingController kondisiKesehatanJaninController = TextEditingController();

  String? tekananDarah;
  String? riwayatPersalinan;
  String? posisiJanin;
  bool _loading = false;
  bool _profileLoading = true;

  final Map<String, String> infoMap = {
    'usia': 'Usia Anda saat ini dalam tahun.',
    'tekanan': 'Bagaimana tekanan darah Anda saat ini. Apakah Normal, Rendah atau Tinggi',
    'persalinan': "Apakah anda sebelumnya pernah melahirkan? Jika Iya, Normal atau Caesar. Jika Tidak Pilih \'Tidak Ada\'",
    'kesehatan': 'Apakah anda memiliki riwayat kesehatan? Contoh : Hipertensi, Diabetes, Mata Minus Dll',
    'posisi': 'Bagaimana Posisi Janin Anda Saat ini ? Normal, Lintang atau Sungsang',
    'kondisi': 'Bagaimana kondisi kesehatan janin anda saat ini, apakah Gemelli, Fetal Distress dll'
  };

  @override
  void initState() {
    super.initState();
    _loadProfileAndSetUsia();
  }

  Future<void> _loadProfileAndSetUsia() async {
    setState(() => _profileLoading = true);
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('https://sehatiapp-production.up.railway.app/api/user-data'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        usiaIbuController.text = data['data']?['usia']?.toString() ?? '';
      } else {
        usiaIbuController.text = '';
      }
    } catch (e) {
      usiaIbuController.text = '';
    }
    setState(() => _profileLoading = false);
  }

  void _submit() {
    if (usiaIbuController.text.trim().isEmpty) {
      _showInfoPopup('Data Tidak Lengkap', 'Usia tidak ditemukan. Silakan lengkapi data profil di halaman Profil.');
      return;
    }
    if (_formKey.currentState!.validate() &&
        tekananDarah != null &&
        riwayatPersalinan != null &&
        posisiJanin != null) {
      _showKonfirmasiDialog();
    } else {
      _showInfoPopup("Lengkapi Data", "Mohon lengkapi semua field terlebih dahulu.");
    }
  }

  void _showKonfirmasiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pastikan data yang Anda masukkan sudah benar.\n'),
              Text('• Usia : ${usiaIbuController.text} Tahun'),
              Text('• Tekanan Darah : $tekananDarah'),
              Text('• Riwayat Persalinan : $riwayatPersalinan'),
              Text('• Riwayat Kesehatan : ${riwayatKesehatanIbuController.text.isEmpty ? "Normal" : riwayatKesehatanIbuController.text}'),
              Text('• Posisi Janin : $posisiJanin'),
              Text('• Kondisi Janin : ${kondisiKesehatanJaninController.text.isEmpty ? "Normal" : kondisiKesehatanJaninController.text}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Periksa Kembali'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                setState(() => _loading = true);

                try {
                  final result = await ApiServicePrediksi.prediksi({
                    'usia_ibu': int.tryParse(usiaIbuController.text.trim()) ?? 0,
                    'tekanan_darah': tekananDarah!.toLowerCase(),
                    'riwayat_persalinan': riwayatPersalinan!.toLowerCase(),
                    'posisi_janin': posisiJanin!.toLowerCase(),
                    'riwayat_kesehatan_ibu': riwayatKesehatanIbuController.text.trim().isEmpty
                        ? 'normal'
                        : riwayatKesehatanIbuController.text.trim().toLowerCase(),
                    'kondisi_kesehatan_janin': kondisiKesehatanJaninController.text.trim().isEmpty
                        ? 'normal'
                        : kondisiKesehatanJaninController.text.trim().toLowerCase(),
                  });

                  if (result.containsKey('hasil_prediksi')) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ResultPrediksi(result: result)),
                    );
                  } else {
                    _showInfoPopup("Gagal", "Tidak ada hasil prediksi yang diterima.");
                  }
                } catch (e) {
                  _showInfoPopup('Error', 'Gagal memproses data. Pastikan backend Flask & Laravel aktif.\n$e');
                } finally {
                  setState(() => _loading = false);
                }
              },
              child: const Text('Prediksi'),
            ),
          ],
        );
      },
    );
  }

  void _showInfoPopup(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.info, color: Color(0xFF4DAEFF)),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Mengerti"),
            ),
          ],
        );
      },
    );
  }

  void _refreshData() {
    setState(() {
      // usia tidak perlu di-clear, tetap readonly
      riwayatKesehatanIbuController.clear();
      kondisiKesehatanJaninController.clear();
      tekananDarah = null;
      riwayatPersalinan = null;
      posisiJanin = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_profileLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFFF9F9F9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: Color(0xFF4DBAFF), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Color(0xFF4C617F), fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'Data Anda aman. ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Kami menjamin kerahasiaan semua informasi yang Anda berikan.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildAppBar(),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildField('Usia Ibu', usiaIbuController, 'usia', TextInputType.number, true),
                          _buildDropdownField('Tekanan Darah', ['Normal', 'Rendah', 'Tinggi'], tekananDarah, (val) => setState(() => tekananDarah = val), 'tekanan'),
                          _buildDropdownField('Riwayat Persalinan', ['Tidak Ada', 'Normal', 'Caesar'], riwayatPersalinan, (val) => setState(() => riwayatPersalinan = val), 'persalinan'),
                          _buildField('Riwayat Kesehatan', riwayatKesehatanIbuController, 'kesehatan'),
                          _buildDropdownField('Posisi Janin', ['Normal', 'Lintang', 'Sungsang'], posisiJanin, (val) => setState(() => posisiJanin = val), 'posisi'),
                          _buildField('Kondisi Janin', kondisiKesehatanJaninController, 'kondisi'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4DAEFF),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _loading
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  : const Text('Mulai Prediksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          ),
          const Text('Tambah Data Prediksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
        ],
      ),
    );
  }

  // readOnly = true untuk usia (otomatis dari profil, tidak bisa diedit)
  Widget _buildField(String label, TextEditingController controller, String infoKey, [TextInputType? type, bool readOnly = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
            const Text(' *', style: TextStyle(color: Colors.red)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showInfoPopup(label, infoMap[infoKey] ?? '-'),
              child: const Icon(Icons.info_outline, size: 18, color: Color(0xFF4DAEFF)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: type,
          readOnly: readOnly,
          enabled: !readOnly ? true : false,
          style: readOnly ? const TextStyle(color: Colors.grey) : null,
          decoration: InputDecoration(
            hintText: readOnly ? 'Otomatis dari profil' : 'Masukkan ${label.toLowerCase()}',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, Function(String?) onChanged, String infoKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
            const Text(' *', style: TextStyle(color: Colors.red)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showInfoPopup(label, infoMap[infoKey] ?? '-'),
              child: const Icon(Icons.info_outline, size: 18, color: Color(0xFF4DAEFF)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          value: value,
          hint: Text('Pilih ${label.toLowerCase()}'),
          onChanged: onChanged,
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          validator: (val) => val == null ? 'Wajib dipilih' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
