import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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


  @override
  void initState() {
    super.initState();
    _loadProfileAndSetUsia();
  }
String _getInfoContent(String infoKey) {
  switch (infoKey) {
    case 'usia':
      return "💡 Pastikan data usia sudah benar dan terisi di profil Anda.\n\nUsia sangat berpengaruh terhadap kesehatan kehamilan. Jika belum terisi, silakan lengkapi profil Anda terlebih dahulu.";
    case 'tekanan':
      return "💡 Pilih kategori tekanan darah Anda saat ini:\n\n✅ Normal: Tidak ada keluhan, tekanan stabil\n✅ Rendah: Sering pusing/lemas\n✅ Tinggi: Pernah didiagnosis hipertensi atau hasil pengukuran tinggi";
    case 'persalinan':
      return "💡 Informasi apakah Anda pernah melahirkan sebelumnya:\n\n- Tidak Ada: Belum pernah melahirkan\n- Normal: Pernah melahirkan normal\n- Caesar: Pernah melahirkan caesar\n\nJawaban ini membantu menentukan risiko pada persalinan berikutnya.";
    case 'kesehatan':
      return "💡 Contoh kondisi yang perlu dicantumkan:\n- Anemia\n- Hipertensi\n- Preeklampsia\n- Dll\n\nJika tidak ada, ketik \"Normal\".";
    case 'posisi':
      return "💡 Pilih posisi janin sesuai hasil pemeriksaan terakhir:\n- Normal: Kepala di bawah\n- Lintang: Posisi melintang\n- Sungsang: Kaki/bokong di bawah";
    case 'kondisi':
      return "💡 Contoh kondisi yang dapat diisi:\n- Bayi Besar\n- Fetal Distress\n- Asfiksia\n- Dll\n\nJika tidak ada, ketik \"Normal\".";
    default:
      return "-";
  }
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
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: const Color(0xFFF4F0FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFF4DAEFF), size: 23),
                  const SizedBox(width: 8),
                  Text(
                    'Konfirmasi Data',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Pastikan data yang Anda masukkan sudah benar.\n',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              _konfirmasiItem('Usia', "${usiaIbuController.text} Tahun"),
              _konfirmasiItem('Tekanan Darah', tekananDarah ?? "-"),
              _konfirmasiItem('Riwayat Persalinan', riwayatPersalinan ?? "-"),
              _konfirmasiItem('Riwayat Kesehatan', riwayatKesehatanIbuController.text.isEmpty ? "Normal" : riwayatKesehatanIbuController.text),
              _konfirmasiItem('Posisi Janin', posisiJanin ?? "-"),
              _konfirmasiItem('Kondisi Janin', kondisiKesehatanJaninController.text.isEmpty ? "Normal" : kondisiKesehatanJaninController.text),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    child: const Text('Periksa Kembali'),
                  ),
                  const SizedBox(width: 4),
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
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6C63FF),
                      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    child: const Text('Prediksi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Helper untuk tampilan baris data konfirmasi
Widget _konfirmasiItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        children: [
          TextSpan(text: "• $label : ", style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}


void _showInfoPopup(String title, String content) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: const Color(0xFFF9FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFEC857), size: 27),
                  const SizedBox(width: 10),
                  Text(
                    "Petunjuk Pengisian",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF2277b6),
                ),
              ),
              const Divider(thickness: 1, height: 22, color: Color(0xFFE3E7ED)),
              Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6C63FF),
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text("Saya Mengerti"),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}



void _refreshData() {
  setState(() {
    riwayatKesehatanIbuController.clear();
    kondisiKesehatanJaninController.clear();
    tekananDarah = null;
    riwayatPersalinan = null;
    posisiJanin = null;
  });

  // Tampilkan snackbar warna hijau setelah refresh
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Form telah diperbarui', style: GoogleFonts.poppins()),
      backgroundColor: const Color(0xFF4CAF50), // hijau modern
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (_profileLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFD),
      body: SafeArea(
        child: Column(
          children: [
// AppBar baru: title center, font tidak besar
Container(
  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(28),
      bottomRight: Radius.circular(28),
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0x2034aaf4),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Stack(
    alignment: Alignment.center,
    children: [
      // Tombol Back
      Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF2277b6)),
        ),
      ),
      // Judul di tengah
      Center(
        child: Text(
          'Prediksi Persalinan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      // Tombol Refresh di kanan
      Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF2277b6)),
          onPressed: _refreshData,
        ),
      ),
    ],
  ),
),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.09),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.lightBlueAccent.withOpacity(0.13),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildField('Usia Ibu', usiaIbuController, 'usia', TextInputType.number, true),
                            _buildDropdownField('Tekanan Darah', ['Normal', 'Rendah', 'Tinggi'], tekananDarah, (val) => setState(() => tekananDarah = val), 'tekanan'),
                            _buildDropdownField('Riwayat Persalinan', ['Tidak Ada', 'Normal', 'Caesar'], riwayatPersalinan, (val) => setState(() => riwayatPersalinan = val), 'persalinan'),
                            _buildField('Riwayat Kesehatan', riwayatKesehatanIbuController, 'kesehatan'),
                            _buildDropdownField('Posisi Janin', ['Normal', 'Lintang', 'Sungsang'], posisiJanin, (val) => setState(() => posisiJanin = val), 'posisi'),
                            _buildField('Kondisi Janin', kondisiKesehatanJaninController, 'kondisi'),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4DAEFF),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: _loading
                                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    : Text('Mulai Prediksi', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security, color: Color(0xFF4DBAFF), size: 19),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Data Anda aman. Kami menjamin kerahasiaan semua informasi yang Anda berikan.',
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4C617F)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black)),
          const Text(' *', style: TextStyle(color: Colors.red)),
          const SizedBox(width: 4),
          GestureDetector(
            // GANTI ke _getInfoContent
            onTap: () => _showInfoPopup(label, _getInfoContent(infoKey)),
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
        style: readOnly ? GoogleFonts.poppins(color: Colors.grey) : GoogleFonts.poppins(),
        decoration: InputDecoration(
          hintText: readOnly ? 'Otomatis dari profil' : 'Masukkan ${label.toLowerCase()}',
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
      ),
      const SizedBox(height: 16),
    ],
  );
}


Widget _buildDropdownField(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
    String infoKey,
  ) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black)),
          const Text(' *', style: TextStyle(color: Colors.red)),
          const SizedBox(width: 4),
          GestureDetector(
            // Ganti pemanggilan infoMap ke _getInfoContent
            onTap: () => _showInfoPopup(label, _getInfoContent(infoKey)),
            child: const Icon(Icons.info_outline, size: 18, color: Color(0xFF4DAEFF)),
          ),
        ],
      ),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        value: value,
        hint: Text('Pilih ${label.toLowerCase()}', style: GoogleFonts.poppins()),
        onChanged: onChanged,
        items: items.map((val) => DropdownMenuItem(
          value: val,
          child: Text(val, style: GoogleFonts.poppins()),
        )).toList(),
        validator: (val) => val == null ? 'Wajib dipilih' : null,
      ),
      const SizedBox(height: 16),
    ],
  );
}

}