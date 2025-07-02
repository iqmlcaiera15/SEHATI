import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_penyakit.dart'; // Pastikan path ini benar
import 'result_deteksi_page.dart'; // Pastikan path ini benar
import 'dart:math'; // Diperlukan untuk perhitungan BMI

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
  // --- MODIFIKASI: Controller baru untuk berat dan tinggi ---
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController(); // Tetap ada untuk menampung hasil
  // --- AKHIR MODIFIKASI ---
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _bsController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _cigsPerDayController = TextEditingController();
  final TextEditingController _systolicBpController = TextEditingController();
  final TextEditingController _diastolicBpController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bodyTempController = TextEditingController();
  // Controller _skinThicknessController tidak lagi digunakan, diganti state dropdown

  // State untuk input Ya/Tidak
  String? _selectedCurrentSmoker;
  String? _selectedBpMeds;

  // --- MODIFIKASI: State baru untuk dropdown ketebalan kulit ---
  String? _selectedSkinThickness;
  final Map<String, int> _skinThicknessMap = {
    'Tidak Diketahui': 0,
    'Tipis': 10,
    'Sedang': 35,
    'Tebal': 40,
  };
  // --- AKHIR MODIFIKASI ---

  final List<String> _yesNoOptions = ['Ya', 'Tidak'];

  // Field info tooltips
  final Map<String, String> _fieldInfo = {
    'pregnancies': 'Jumlah kehamilan yang pernah dialami (angka, misal: 0, 1, 2)',
    'age': 'Usia Anda saat ini dalam tahun (angka, misal: 30)',
    // --- MODIFIKASI: Deskripsi BMI diubah ---
    'bmi': 'Body Mass Index (BMI) dihitung otomatis dari berat dan tinggi badan Anda. Normal: 18.5-24.9',
    'weight_height': 'Masukkan berat badan dalam kilogram (kg) dan tinggi badan dalam sentimeter (cm).',
    // --- AKHIR MODIFIKASI ---
    'blood_pressure': 'Mean Arterial Pressure (MAP) dihitung secara otomatis dari tekanan sistolik dan diastolik Anda.',
    'bs': 'Kadar gula darah (mg/dL). Normal puasa: <100 mg/dL, 2 jam setelah makan: <140 mg/dL',
    // --- MODIFIKASI: Deskripsi Skin Thickness diubah ---
    'skin_thickness': 'Perkiraan ketebalan lipatan kulit trisep. Pilih kategori yang paling sesuai atau "Tidak Diketahui" jika tidak yakin.',
    // --- MODIFIKASI: Key 'sex' dihapus karena field tidak lagi ditampilkan ---
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
    _sexController.text = "1"; // <-- PENTING: Nilai sex=1 tetap di-set di sini
    _selectedCurrentSmoker = "Tidak";
    _selectedBpMeds = "Tidak";
    // --- MODIFIKASI: Default value untuk dropdown kulit ---
    _selectedSkinThickness = 'Tidak Diketahui';
    _bodyTempController.text = "36.5";
    _updateCigsPerDayField();

    // Listener untuk perhitungan MAP (Otomatis)
    _systolicBpController.addListener(_calculateAndSetMAP);
    _diastolicBpController.addListener(_calculateAndSetMAP);

    // --- MODIFIKASI: Listener untuk perhitungan BMI (Otomatis) ---
    _weightController.addListener(_calculateAndSetBMI);
    _heightController.addListener(_calculateAndSetBMI);
  }

  // Fungsi untuk menghitung dan mengatur MAP (Mean Arterial Pressure)
  void _calculateAndSetMAP() {
    final double? systolic = double.tryParse(_systolicBpController.text);
    final double? diastolic = double.tryParse(_diastolicBpController.text);

    if (systolic != null && diastolic != null && systolic > 0 && diastolic > 0) {
      final double map = (systolic + (2 * diastolic)) / 3;
      if (mounted) {
        setState(() {
          _bloodPressureController.text = map.toStringAsFixed(2);
        });
      }
    } else {
       if (mounted) {
        setState(() {
          _bloodPressureController.text = "";
        });
      }
    }
  }

  // --- MODIFIKASI: Fungsi baru untuk menghitung BMI ---
  void _calculateAndSetBMI() {
    final double? weight = double.tryParse(_weightController.text);
    final double? heightCm = double.tryParse(_heightController.text);

    if (weight != null && heightCm != null && weight > 0 && heightCm > 0) {
      final double heightM = heightCm / 100;
      final double bmi = weight / (heightM * heightM);
       if (mounted) {
        setState(() {
          _bmiController.text = bmi.toStringAsFixed(2);
        });
      }
    } else {
       if (mounted) {
        setState(() {
          _bmiController.text = "";
        });
      }
    }
  }

  void _updateCigsPerDayField() {
    if (_selectedCurrentSmoker == "Tidak") {
      _cigsPerDayController.text = "0";
    }
  }

  Future<void> _submitData() async {
    // Validasi form sebelum menampilkan dialog konfirmasi
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
    if (shouldContinue == null || !shouldContinue) return;

    setState(() {
      _isLoading = true;
    });

    final formData = {
      "nama": _namaController.text,
      "pregnancies": int.tryParse(_pregnanciesController.text) ?? 0,
      "age": double.tryParse(_ageController.text) ?? 0.0,
      "bmi": double.tryParse(_bmiController.text) ?? 0.0,
      "blood_pressure": double.tryParse(_bloodPressureController.text),
      "bs": double.tryParse(_bsController.text) ?? 0.0,
      "skin_thickness": _skinThicknessMap[_selectedSkinThickness],
      "sex": int.tryParse(_sexController.text) ?? 1, // <-- PENTING: Nilai sex=1 tetap dikirim
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

  Future<bool?> _showConfirmationDialog() async {
    // Pastikan nilai MAP & BMI terupdate di dialog konfirmasi
    _calculateAndSetMAP();
    _calculateAndSetBMI();

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
                    _buildConfirmationRow('Berat / Tinggi', '${_weightController.text} kg / ${_heightController.text} cm'),
                    _buildConfirmationRow('BMI (Otomatis)', _bmiController.text),
                    _buildConfirmationRow('Ketebalan Kulit', _selectedSkinThickness ?? '-'),
                    _buildConfirmationRow('Tekanan Darah', '${_systolicBpController.text}/${_diastolicBpController.text} mmHg'),
                    _buildConfirmationRow('MAP (Otomatis)', '${_bloodPressureController.text} mmHg'),
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
    );
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
    // Hapus listener untuk mencegah memory leak
    _systolicBpController.removeListener(_calculateAndSetMAP);
    _diastolicBpController.removeListener(_calculateAndSetMAP);
    _weightController.removeListener(_calculateAndSetBMI);
    _heightController.removeListener(_calculateAndSetBMI);

    // Dispose semua controller
    _namaController.dispose();
    _pregnanciesController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bmiController.dispose();
    _bloodPressureController.dispose();
    _bsController.dispose();
    _sexController.dispose();
    _cigsPerDayController.dispose();
    _systolicBpController.dispose();
    _diastolicBpController.dispose();
    _heartRateController.dispose();
    _bodyTempController.dispose();
    super.dispose();
  }

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
              errorBorder: OutlineInputBorder( 
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red.shade700, width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
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
                      if (double.parse(value) < 0) {
                        return 'Nilai tidak boleh negatif';
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

  Widget _buildCustomDropdownField({
    required String? currentValue,
    required String label,
    required Map<String, int> items,
    required ValueChanged<String?> onChanged,
    String? fieldKey,
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
            items: items.keys.map((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key, style: const TextStyle(fontSize: 15)),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }
 
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
            // --- MODIFIKASI: Field Jenis Kelamin Dihapus dari UI ---
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _weightController,
                    label: 'Berat Badan',
                    hintText: 'Contoh: 60',
                    keyboardType: TextInputType.number,
                    fieldKey: 'weight_height',
                    suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('kg', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _heightController,
                    label: 'Tinggi Badan',
                    hintText: 'Contoh: 158',
                    keyboardType: TextInputType.number,
                    suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('cm', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
                  ),
                ),
              ],
            ),
             _buildTextField(
              controller: _bmiController,
              label: 'BMI (Body Mass Index)',
              hintText: 'Dihitung otomatis',
              keyboardType: TextInputType.number,
              fieldKey: 'bmi',
              enabled: false,
              isRequired: false,
              suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('kg/m²', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
            ),
            _buildCustomDropdownField(
              currentValue: _selectedSkinThickness,
              label: 'Ketebalan Lipatan Kulit',
              items: _skinThicknessMap,
              onChanged: (value) {
                setState(() {
                  _selectedSkinThickness = value;
                });
              },
              fieldKey: 'skin_thickness',
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
            _buildTextField(
              controller: _bloodPressureController,
              label: 'Tekanan Darah Rata-rata (MAP)',
              hintText: 'Dihitung otomatis',
              keyboardType: TextInputType.number,
              fieldKey: 'blood_pressure',
              isRequired: false,
              enabled: false,
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
                suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('mmol/l', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
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

  // ============== START: FUNGSI VALIDASI ==============

  // Method untuk validasi per step
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Data Pribadi
        return _validateStep0();
      case 1: // Riwayat Kehamilan
        return _validateStep1();
      case 2: // Indeks & Pengukuran Tubuh
        return _validateStep2();
      case 3: // Kondisi Kardiovaskular
        return _validateStep3();
      case 4: // Gula Darah & Gaya Hidup
        return _validateStep4();
      default:
        return true;
    }
  }

  bool _validateStep0() {
    // Validasi Data Pribadi
    if (_namaController.text.isEmpty) {
      _showValidationError('Nama lengkap wajib diisi');
      return false;
    }
    if (_ageController.text.isEmpty) {
      _showValidationError('Usia wajib diisi');
      return false;
    }
    if (double.tryParse(_ageController.text) == null) {
      _showValidationError('Usia harus berupa angka yang valid');
      return false;
    }
    if (double.parse(_ageController.text) < 0) {
      _showValidationError('Usia tidak boleh negatif');
      return false;
    }
    return true;
  }

  bool _validateStep1() {
    // Validasi Riwayat Kehamilan
    if (_pregnanciesController.text.isEmpty) {
      _showValidationError('Jumlah kehamilan sebelumnya wajib diisi');
      return false;
    }
    if (int.tryParse(_pregnanciesController.text) == null) {
      _showValidationError('Jumlah kehamilan harus berupa angka yang valid');
      return false;
    }
    if (int.parse(_pregnanciesController.text) < 0) {
      _showValidationError('Jumlah kehamilan tidak boleh negatif');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    // Validasi Indeks & Pengukuran Tubuh
    if (_weightController.text.isEmpty) {
      _showValidationError('Berat badan wajib diisi');
      return false;
    }
    if (_heightController.text.isEmpty) {
      _showValidationError('Tinggi badan wajib diisi');
      return false;
    }
    if (double.tryParse(_weightController.text) == null) {
      _showValidationError('Berat badan harus berupa angka yang valid');
      return false;
    }
    if (double.tryParse(_heightController.text) == null) {
      _showValidationError('Tinggi badan harus berupa angka yang valid');
      return false;
    }
    if (double.parse(_weightController.text) <= 0) {
      _showValidationError('Berat badan harus lebih dari 0');
      return false;
    }
    if (double.parse(_heightController.text) <= 0) {
      _showValidationError('Tinggi badan harus lebih dari 0');
      return false;
    }
    if (_bodyTempController.text.isEmpty) {
      _showValidationError('Suhu tubuh wajib diisi');
      return false;
    }
    if (double.tryParse(_bodyTempController.text) == null) {
      _showValidationError('Suhu tubuh harus berupa angka yang valid');
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    // Validasi Kondisi Kardiovaskular
    if (_systolicBpController.text.isEmpty) {
      _showValidationError('Tekanan darah sistolik wajib diisi');
      return false;
    }
    if (_diastolicBpController.text.isEmpty) {
      _showValidationError('Tekanan darah diastolik wajib diisi');
      return false;
    }
    if (double.tryParse(_systolicBpController.text) == null) {
      _showValidationError('Tekanan darah sistolik harus berupa angka yang valid');
      return false;
    }
    if (double.tryParse(_diastolicBpController.text) == null) {
      _showValidationError('Tekanan darah diastolik harus berupa angka yang valid');
      return false;
    }
    if (double.parse(_systolicBpController.text) <= 0) {
      _showValidationError('Tekanan darah sistolik harus lebih dari 0');
      return false;
    }
    if (double.parse(_diastolicBpController.text) <= 0) {
      _showValidationError('Tekanan darah diastolik harus lebih dari 0');
      return false;
    }
    if (_heartRateController.text.isEmpty) {
      _showValidationError('Detak jantung wajib diisi');
      return false;
    }
    if (int.tryParse(_heartRateController.text) == null) {
      _showValidationError('Detak jantung harus berupa angka yang valid');
      return false;
    }
    if (int.parse(_heartRateController.text) <= 0) {
      _showValidationError('Detak jantung harus lebih dari 0');
      return false;
    }
    if (_selectedBpMeds == null) {
      _showValidationError('Status konsumsi obat tekanan darah wajib dipilih');
      return false;
    }
    return true;
  }

  bool _validateStep4() {
    // Validasi Gula Darah & Gaya Hidup
    if (_bsController.text.isEmpty) {
      _showValidationError('Kadar gula darah wajib diisi');
      return false;
    }
    if (double.tryParse(_bsController.text) == null) {
      _showValidationError('Kadar gula darah harus berupa angka yang valid');
      return false;
    }
    if (double.parse(_bsController.text) < 0) {
      _showValidationError('Kadar gula darah tidak boleh negatif');
      return false;
    }
    if (_selectedCurrentSmoker == null) {
      _showValidationError('Status perokok aktif wajib dipilih');
      return false;
    }
    if (_selectedCurrentSmoker == "Ya") {
      if (_cigsPerDayController.text.isEmpty) {
        _showValidationError('Jumlah rokok per hari wajib diisi untuk perokok aktif');
        return false;
      }
      if (int.tryParse(_cigsPerDayController.text) == null) {
        _showValidationError('Jumlah rokok per hari harus berupa angka yang valid');
        return false;
      }
      if (int.parse(_cigsPerDayController.text) < 0) {
        _showValidationError('Jumlah rokok per hari tidak boleh negatif');
        return false;
      }
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============== END: FUNGSI VALIDASI ==============

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
            steps: _buildSteps(),
            // ============== START: `controlsBuilder` DIMODIFIKASI ==============
            controlsBuilder: (context, details) {
              return Container(
                margin: const EdgeInsets.only(top: 24, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          final isLastStep = _currentStep == _buildSteps().length - 1;
                         
                          if (isLastStep) {
                            // Untuk step terakhir, validasi seluruh form
                            if (_formKey.currentState!.validate()) {
                              _submitData();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Harap periksa kembali semua input yang wajib diisi pada setiap langkah.'),
                                  backgroundColor: Colors.orange.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          } else {
                            // Untuk step sebelumnya, hanya validasi step saat ini
                            if (_validateCurrentStep()) {
                              setState(() {
                                _currentStep += 1;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DBAFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading && (_currentStep == _buildSteps().length -1)
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
                                    : 'Kirim & Lihat Hasil',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    // Blok 'if' untuk tombol kembali dihapus dari sini
                  ],
                ),
              );
            },
            // ============== END: `controlsBuilder` DIMODIFIKASI ==============
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
                  const Icon(Icons.shield_outlined, color: Color(0xFF4DBAFF), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Color(0xFF4C617F), fontSize: 11.5, height: 1.4),
                        children: [
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