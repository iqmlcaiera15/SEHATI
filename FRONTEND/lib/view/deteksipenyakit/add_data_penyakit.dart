import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_penyakit.dart'; // Pastikan path ini benar
import 'result_deteksi_page.dart'; // Pastikan path ini benar

class AddDataPenyakit extends StatefulWidget {
  const AddDataPenyakit({super.key});

  @override
  State<AddDataPenyakit> createState() => _AddDataPenyakitState();
}

class _AddDataPenyakitState extends State<AddDataPenyakit> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers untuk input teks
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _pregnanciesController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  // --- MODIFIKASI ---
  // Controller ini sekarang akan diisi secara otomatis
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _bsController = TextEditingController();
  final TextEditingController _skinThicknessController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _cigsPerDayController = TextEditingController();
  final TextEditingController _systolicBpController = TextEditingController();
  final TextEditingController _diastolicBpController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bodyTempController = TextEditingController();

  // State untuk input Ya/Tidak
  String? _selectedCurrentSmoker;
  String? _selectedBpMeds;

  final List<String> _yesNoOptions = ['Ya', 'Tidak'];

  // Field info tooltips
  final Map<String, String> _fieldInfo = {
    'pregnancies': 'Jumlah kehamilan yang pernah dialami (angka, misal: 0, 1, 2)',
    'age': 'Usia Anda saat ini dalam tahun (angka, misal: 30)',
    'bmi': 'Body Mass Index (BMI) - indikator kegemukan. Dihitung dari berat (kg) / (tinggi (m))^2. Normal: 18.5-24.9',
    // --- MODIFIKASI --- Deskripsi diubah untuk mencerminkan perhitungan otomatis
    'blood_pressure': 'Mean Arterial Pressure (MAP) dihitung secara otomatis dari tekanan sistolik dan diastolik Anda.',
    'bs': 'Kadar gula darah (mg/dL). Normal puasa: <100 mg/dL, 2 jam setelah makan: <140 mg/dL',
    'skin_thickness': 'Ketebalan lipatan kulit trisep (mm). Biasanya diukur oleh tenaga medis.',
    'sex': 'Jenis kelamin. Sistem ini secara default untuk perempuan (nilai 1).',
    'current_smoker': 'Apakah Anda perokok aktif saat ini?',
    'cigs_per_day': 'Jika perokok, rata-rata jumlah batang rokok yang dihisap per hari. Jika tidak, isi 0 atau kosongkan.',
    'bp_meds': 'Apakah Anda sedang dalam pengobatan atau rutin mengonsumsi obat untuk tekanan darah?',
    'systolic_bp': 'Tekanan darah sistolik (angka atas, mmHg). Normal: <120 mmHg',
    'diastolic_bp': 'Tekanan darah diastolik (angka bawah, mmHg). Normal: <80 mmHg',
    'heart_rate': 'Detak jantung istirahat per menit. Normal: 60-100 bpm',
    'body_temp': 'Suhu tubuh dalam Celcius. Normal: 36.1°C - 37.2°C',
  };

  @override
  void initState() {
    super.initState();
    _sexController.text = "1";
    _selectedCurrentSmoker = "Tidak";
    _selectedBpMeds = "Tidak";
    _bodyTempController.text = "36.5";
    _updateCigsPerDayField();

    // --- MODIFIKASI BARU ---
    // Tambahkan listener ke controller sistolik dan diastolik
    _systolicBpController.addListener(_calculateAndSetMAP);
    _diastolicBpController.addListener(_calculateAndSetMAP);
  }

  // --- MODIFIKASI BARU ---
  // Fungsi untuk menghitung dan mengatur MAP (Mean Arterial Pressure)
  void _calculateAndSetMAP() {
    final double? systolic = double.tryParse(_systolicBpController.text);
    final double? diastolic = double.tryParse(_diastolicBpController.text);

    // Pastikan kedua nilai valid sebelum menghitung
    if (systolic != null && diastolic != null && systolic > 0 && diastolic > 0) {
      // Rumus MAP = (Sistolik + 2 * Diastolik) / 3
      final double map = (systolic + (2 * diastolic)) / 3;
      // Update controller dengan nilai yang sudah diformat ke 2 angka desimal
      setState(() {
          _bloodPressureController.text = map.toStringAsFixed(2);
      });
    } else {
      // Kosongkan field jika salah satu input tidak valid
      setState(() {
          _bloodPressureController.text = "";
      });
    }
  }

  void _updateCigsPerDayField() {
    if (_selectedCurrentSmoker == "Tidak") {
      _cigsPerDayController.text = "0";
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap periksa kembali semua input yang wajib diisi pada setiap langkah.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final shouldContinue = await _showConfirmationDialog();
    if (!shouldContinue) return;

    setState(() {
      _isLoading = true;
    });

    // --- MODIFIKASI ---
    // Perhitungan MAP tidak perlu dilakukan lagi di sini karena controller
    // _bloodPressureController sudah berisi nilai yang benar dari listener.
    // Kode di bawah ini akan mengambil nilai yang sudah dihitung secara otomatis.

    final formData = {
      "nama": _namaController.text,
      "pregnancies": int.tryParse(_pregnanciesController.text) ?? 0,
      "age": double.tryParse(_ageController.text) ?? 0.0,
      "bmi": double.tryParse(_bmiController.text) ?? 0.0,
      // Nilai ini diambil dari controller yang sudah di-update otomatis
      "blood_pressure": double.tryParse(_bloodPressureController.text),
      "bs": double.tryParse(_bsController.text) ?? 0.0,
      "skin_thickness": double.tryParse(_skinThicknessController.text),
      "sex": int.tryParse(_sexController.text) ?? 1,
      "current_smoker": _selectedCurrentSmoker == "Ya" ? 1 : 0,
      "cigs_per_day": _selectedCurrentSmoker == "Ya" ? (int.tryParse(_cigsPerDayController.text) ?? 0) : 0,
      "bp_meds": _selectedBpMeds == "Ya" ? 1 : 0,
      "systolic_bp": double.tryParse(_systolicBpController.text) ?? 0.0,
      "diastolic_bp": double.tryParse(_diastolicBpController.text) ?? 0.0,
      "heart_rate": int.tryParse(_heartRateController.text) ?? 0,
      "body_temp": double.tryParse(_bodyTempController.text) ?? 36.5,
    };

    formData.removeWhere((key, value) => value == null);

    try {
      final result = await ApiService.submitDeteksiData(formData);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultDeteksiPage(resultData: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim data: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
     // --- MODIFIKASI BARU ---
     // Pastikan nilai MAP terupdate di dialog konfirmasi
     _calculateAndSetMAP();

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Color(0xFF4DBAFF)),
                SizedBox(width: 10),
                Text('Konfirmasi Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pastikan data yang Anda masukkan sudah benar. Apakah Anda yakin ingin melanjutkan?', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 20),
                  Text('Berikut ringkasan data Anda:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildConfirmationRow('Nama', _namaController.text),
                        _buildConfirmationRow('Usia', '${_ageController.text} tahun'),
                        _buildConfirmationRow('BMI', _bmiController.text),
                        _buildConfirmationRow('Tekanan Darah', '${_systolicBpController.text}/${_diastolicBpController.text} mmHg'),
                        // --- MODIFIKASI --- Menampilkan MAP yang dihitung
                        _buildConfirmationRow('MAP (Rata-rata)', '${_bloodPressureController.text} mmHg'),
                        _buildConfirmationRow('Status Perokok', _selectedCurrentSmoker ?? 'Tidak'),
                        if (_selectedCurrentSmoker == "Ya")
                           _buildConfirmationRow('Rokok/Hari', _cigsPerDayController.text),
                        _buildConfirmationRow('Konsumsi Obat Darah', _selectedBpMeds ?? 'Tidak'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Periksa Kembali',
                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DBAFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Lanjutkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value.isNotEmpty ? value : '-', style: TextStyle(fontSize: 13, color: Colors.grey.shade800))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // --- MODIFIKASI BARU ---
    // Hapus listener untuk mencegah memory leak
    _systolicBpController.removeListener(_calculateAndSetMAP);
    _diastolicBpController.removeListener(_calculateAndSetMAP);

    _namaController.dispose();
    _pregnanciesController.dispose();
    _ageController.dispose();
    _bmiController.dispose();
    _bloodPressureController.dispose();
    _bsController.dispose();
    _skinThicknessController.dispose();
    _sexController.dispose();
    _cigsPerDayController.dispose();
    _systolicBpController.dispose();
    _diastolicBpController.dispose();
    _heartRateController.dispose();
    _bodyTempController.dispose();
    super.dispose();
  }

  // Widget _buildTextField tidak perlu diubah
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
    String? fieldKey,
    Widget? suffix,
    bool enabled = true,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (fieldKey != null && _fieldInfo.containsKey(fieldKey))
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: InkWell(
                    onTap: () => _showInfoPopup(context, label, _fieldInfo[fieldKey]!),
                    borderRadius: BorderRadius.circular(12),
                    child: const Icon(Icons.info_outline, size: 18, color: Color(0xFF4DBAFF)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: TextStyle(color: enabled ? Colors.black87 : Colors.grey.shade700, fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              fillColor: enabled ? Colors.white : Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF4DBAFF), width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
              ),
              suffixIcon: suffix,
            ),
            validator: isRequired
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bagian ini wajib diisi';
                    }
                    if (keyboardType == TextInputType.number) {
                      if (double.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // Widget-widget lain tidak perlu diubah...
  // ... (_buildYesNoDropdownField, _showInfoPopup, _buildInfoBox)

   Widget _buildYesNoDropdownField({
    required String currentValue,
    required String label,
    required ValueChanged<String?> onChanged,
    bool isRequired = true,
    String? fieldKey,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (fieldKey != null && _fieldInfo.containsKey(fieldKey))
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: InkWell(
                    onTap: () => _showInfoPopup(context, label, _fieldInfo[fieldKey]!),
                    borderRadius: BorderRadius.circular(12),
                    child: const Icon(Icons.info_outline, size: 18, color: Color(0xFF4DBAFF)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: currentValue,
            items: _yesNoOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 15)),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF4DBAFF), width: 1.5),
              ),
                disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
              ),
            ),
            validator: isRequired
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bagian ini wajib diisi';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }


  void _showInfoPopup(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actionsPadding: const EdgeInsets.fromLTRB(0,0,12,12),
        title: Row(
          children: [
            const Icon(Icons.info_rounded, color: Color(0xFF4DBAFF)),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
          ],
        ),
        content: Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DBAFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16)
            ),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDEBFF), width: 1)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF4DBAFF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: Color(0xFF005A8C)
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF27709B), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Data Pribadi', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBox(
              'Kenapa data ini penting?',
              'Data pribadi membantu kami untuk memberikan hasil yang lebih akurat sesuai dengan kondisi Anda. Semua data dijamin kerahasiaannya.'
            ),
            _buildTextField(
              controller: _namaController,
              label: 'Nama Lengkap',
              hintText: 'Masukkan nama lengkap Anda',
            ),
            _buildTextField(
              controller: _ageController,
              label: 'Usia',
              hintText: 'Contoh: 30',
              keyboardType: TextInputType.number,
              fieldKey: 'age',
            ),
            _buildTextField(
              controller: _sexController,
              label: 'Jenis Kelamin',
              keyboardType: TextInputType.number,
              fieldKey: 'sex',
              enabled: false,
              suffix: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text('Perempuan', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Riwayat Kehamilan', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBox(
              'Informasi Kehamilan',
              'Riwayat kehamilan Anda sebelumnya dapat mempengaruhi risiko terhadap berbagai kondisi kesehatan dalam kehamilan saat ini.'
            ),
            _buildTextField(
              controller: _pregnanciesController,
              label: 'Jumlah Kehamilan Sebelumnya',
              hintText: 'Contoh: 0, 1, 2',
              keyboardType: TextInputType.number,
              fieldKey: 'pregnancies',
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Indeks & Pengukuran Tubuh', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBox(
              'Pengukuran Fisik',
              'Pengukuran-pengukuran berikut membantu menilai kondisi fisik Anda yang berkaitan dengan risiko kesehatan tertentu.'
            ),
            _buildTextField(
              controller: _bmiController,
              label: 'BMI (Body Mass Index)',
              hintText: 'Contoh: 22.5',
              keyboardType: TextInputType.number,
              fieldKey: 'bmi',
              suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('kg/m²', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
            ),
            _buildTextField(
              controller: _skinThicknessController,
              label: 'Ketebalan Lipatan Kulit',
              hintText: 'Contoh: 20 (Jika ada)',
              keyboardType: TextInputType.number,
              fieldKey: 'skin_thickness',
              isRequired: false,
              suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('mm', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
            ),
            _buildTextField(
              controller: _bodyTempController,
              label: 'Suhu Tubuh',
              hintText: 'Contoh: 36.7',
              keyboardType: TextInputType.number,
              fieldKey: 'body_temp',
              suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('°C', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Kondisi Kardiovaskular', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _buildInfoBox(
              'Tekanan Darah & Jantung',
              'Tekanan darah yang sehat selama kehamilan sangat penting. Cukup isi tekanan Sistolik dan Diastolik, nilai rata-rata akan dihitung otomatis.'
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _systolicBpController,
                    label: 'Sistolik',
                    hintText: 'Atas, cth: 120',
                    keyboardType: TextInputType.number,
                    fieldKey: 'systolic_bp',
                    suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('mmHg', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _diastolicBpController,
                    label: 'Diastolik',
                    hintText: 'Bawah, cth: 80',
                    keyboardType: TextInputType.number,
                    fieldKey: 'diastolic_bp',
                    suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('mmHg', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
                  ),
                ),
              ],
            ),
            // --- MODIFIKASI UI ---
            // Field ini sekarang dinonaktifkan dan label/hintnya diubah
            _buildTextField(
              controller: _bloodPressureController,
              label: 'Tekanan Darah Rata-rata (MAP)',
              hintText: 'Dihitung otomatis',
              keyboardType: TextInputType.number,
              fieldKey: 'blood_pressure',
              isRequired: false,
              enabled: false, // <-- PENTING: Field tidak bisa diisi manual
              suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('mmHg', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
            ),
            _buildTextField(
              controller: _heartRateController,
              label: 'Detak Jantung',
              hintText: 'Contoh: 75',
              keyboardType: TextInputType.number,
              fieldKey: 'heart_rate',
              suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('bpm', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
            ),
            _buildYesNoDropdownField(
              currentValue: _selectedBpMeds!,
              label: 'Konsumsi Obat Tekanan Darah',
              onChanged: (value) {
                setState(() {
                  _selectedBpMeds = value;
                });
              },
              fieldKey: 'bp_meds',
            ),
          ],
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Gula Darah & Gaya Hidup', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBox(
              'Gula Darah & Kebiasaan',
              'Kadar gula darah dan kebiasaan merokok memiliki dampak signifikan terhadap kesehatan ibu dan janin.'
            ),
            _buildTextField(
              controller: _bsController,
              label: 'Kadar Gula Darah',
              hintText: 'Contoh: 90',
              keyboardType: TextInputType.number,
              fieldKey: 'bs',
                suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('mg/dL', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
            ),
            _buildYesNoDropdownField(
              currentValue: _selectedCurrentSmoker!,
              label: 'Status Perokok Aktif',
              onChanged: (value) {
                setState(() {
                  _selectedCurrentSmoker = value;
                  _updateCigsPerDayField();
                });
              },
              fieldKey: 'current_smoker',
            ),
            _buildTextField(
              controller: _cigsPerDayController,
              label: 'Rata-rata Jumlah Rokok/Hari',
              hintText: 'Jika perokok, contoh: 5',
              keyboardType: TextInputType.number,
              fieldKey: 'cigs_per_day',
              isRequired: _selectedCurrentSmoker == "Ya",
              enabled: _selectedCurrentSmoker == "Ya",
            ),
          ],
        ),
        isActive: _currentStep >= 4,
        state: _currentStep >= 4 ? StepState.complete : StepState.indexed,
      ),
    ];
  }


  // Seluruh widget build() di bawah ini tidak perlu diubah.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Deteksi Risiko Kesehatan Ibu'),
        backgroundColor: const Color(0xFF4DBAFF),
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepTapped: (step) => setState(() => _currentStep = step),
            onStepContinue: () {
              if (_currentStep < _buildSteps().length - 1) {
                setState(() {
                  _currentStep += 1;
                });
              } else {
                _submitData();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            steps: _buildSteps(),
            controlsBuilder: (context, details) {
              return Container(
                margin: const EdgeInsets.only(top: 24, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DBAFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _currentStep < _buildSteps().length - 1
                                    ? 'Lanjut'
                                    : 'Kirim Data',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    if (_currentStep > 0 && !_isLoading) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade400, width: 1.0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Kembali', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _currentStep == _buildSteps().length - 1 && !_isLoading
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1.0))
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF4DBAFF), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Color(0xFF4C617F), fontSize: 11.5, height: 1.4),
                        children: const [
                          TextSpan(
                            text: 'Privasi Data Anda Terjamin. ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Kami berkomitmen untuk menjaga kerahasiaan semua informasi yang Anda berikan sesuai dengan kebijakan privasi kami.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}