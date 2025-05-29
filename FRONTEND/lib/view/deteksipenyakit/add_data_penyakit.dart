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
  final TextEditingController _bloodPressureController = TextEditingController(); // Rata-rata
  final TextEditingController _bsController = TextEditingController();
  final TextEditingController _skinThicknessController = TextEditingController();
  final TextEditingController _sexController = TextEditingController(); // Tetap pakai controller krn disabled
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
    'blood_pressure': 'Tekanan darah rata-rata keseluruhan (mmHg). Contoh: 80. Jika ragu, bisa dikosongkan jika sistolik & diastolik diisi.',
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
    _sexController.text = "1"; // Default: Perempuan (disabled field)
    _selectedCurrentSmoker = "Tidak"; // Default: Tidak merokok
    _selectedBpMeds = "Tidak"; // Default: Tidak minum obat darah
    _bodyTempController.text = "36.5"; // Default normal temperature
    _updateCigsPerDayField();
  }

  void _updateCigsPerDayField() {
    if (_selectedCurrentSmoker == "Tidak") {
      _cigsPerDayController.text = "0";
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
       // Jika form tidak valid, tampilkan pesan atau arahkan ke step yang error
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

    final formData = {
      "nama": _namaController.text,
      "pregnancies": int.tryParse(_pregnanciesController.text) ?? 0,
      "age": double.tryParse(_ageController.text) ?? 0.0,
      "bmi": double.tryParse(_bmiController.text) ?? 0.0,
      "blood_pressure": double.tryParse(_bloodPressureController.text), // Bisa null jika tidak diisi
      "bs": double.tryParse(_bsController.text) ?? 0.0,
      "skin_thickness": double.tryParse(_skinThicknessController.text), // Bisa null jika tidak diisi
      "sex": int.tryParse(_sexController.text) ?? 1, // Default perempuan
      "current_smoker": _selectedCurrentSmoker == "Ya" ? 1 : 0,
      "cigs_per_day": _selectedCurrentSmoker == "Ya" ? (int.tryParse(_cigsPerDayController.text) ?? 0) : 0,
      "bp_meds": _selectedBpMeds == "Ya" ? 1 : 0,
      "systolic_bp": double.tryParse(_systolicBpController.text) ?? 0.0,
      "diastolic_bp": double.tryParse(_diastolicBpController.text) ?? 0.0,
      "heart_rate": int.tryParse(_heartRateController.text) ?? 0,
      "body_temp": double.tryParse(_bodyTempController.text) ?? 36.5,
    };

    // Menghapus field yang null dari formData agar tidak dikirim ke API jika tidak diisi
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
      padding: const EdgeInsets.only(bottom: 18), // Sedikit tambah padding
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
                    color: Colors.redAccent, // Lebih soft dari Colors.red
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (fieldKey != null && _fieldInfo.containsKey(fieldKey))
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: InkWell( // InkWell agar area tap lebih besar
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Sesuaikan padding
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), // Border radius lebih besar
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
              disabledBorder: OutlineInputBorder( // Style untuk disabled field
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
              ),
              suffixIcon: suffix, // Menggunakan suffixIcon agar paddingnya pas
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
      margin: const EdgeInsets.only(bottom: 20), // Margin antar info box dan field pertama
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7FF), // Warna biru muda yang sudah ada
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDEBFF), width: 1) // Border yang lebih soft
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
                    fontSize: 14.5, // Sedikit lebih besar
                    color: Color(0xFF005A8C) // Warna biru tua untuk kontras
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF27709B), height: 1.4), // Kontras
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
              enabled: false, // Field ini tidak bisa diubah, default Perempuan
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
              'Tekanan darah yang sehat selama kehamilan sangat penting. Jika Anda memiliki alat ukur pribadi, masukkan datanya. Jika tidak, data ini bisa didapatkan dari pemeriksaan rutin.'
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _systolicBpController,
                    label: 'Sistolik',
                    hintText: 'Atas, cth: 110',
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
                    hintText: 'Bawah, cth: 70',
                    keyboardType: TextInputType.number,
                    fieldKey: 'diastolic_bp',
                    suffix: Container( padding: const EdgeInsets.all(12.0), child: Text('mmHg', style: TextStyle(fontSize: 14, color: Colors.grey.shade600))),
                  ),
                ),
              ],
            ),
            _buildTextField(
              controller: _bloodPressureController,
              label: 'Tekanan Darah Rata-rata (Opsional)',
              hintText: 'Contoh: 80 (Jika ada)',
              keyboardType: TextInputType.number,
              fieldKey: 'blood_pressure',
              isRequired: false,
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
                  _updateCigsPerDayField(); // Update field rokok/hari
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
              isRequired: _selectedCurrentSmoker == "Ya", // Wajib jika perokok
              enabled: _selectedCurrentSmoker == "Ya", // Hanya enable jika perokok
            ),
          ],
        ),
        isActive: _currentStep >= 4,
        state: _currentStep >= 4 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background utama putih
      appBar: AppBar(
        title: const Text('Deteksi Risiko Kesehatan Ibu'),
        backgroundColor: const Color(0xFF4DBAFF),
        foregroundColor: Colors.white,
        elevation: 1, // Sedikit shadow
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
              // Validasi form untuk step saat ini sebelum melanjutkan
              // Ini memerlukan cara untuk memvalidasi per step jika diinginkan,
              // atau validasi keseluruhan saat submit.
              // Untuk sekarang, validasi keseluruhan saat submit.
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
                margin: const EdgeInsets.only(top: 24, bottom: 8), // Margin lebih
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DBAFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14), // Padding lebih
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Border radius lebih
                          ),
                          elevation: 2, // Sedikit shadow
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5, // Stroke lebih tebal
                                ),
                              )
                            : Text(
                                _currentStep < _buildSteps().length - 1
                                    ? 'Lanjut' // Diubah dari 'Lanjutkan'
                                    : 'Kirim Data',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), // Font lebih tebal
                              ),
                      ),
                    ),
                    if (_currentStep > 0 && !_isLoading) ...[ // Hanya tampil jika bukan step pertama & tidak loading
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700, // Warna teks
                            side: BorderSide(color: Colors.grey.shade400, width: 1.0), // Border lebih jelas
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
                 color: Colors.white, // Atau Color(0xFFF9F9F9)
                 border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1.0))
              ),
              child: Row( // Menggunakan Row agar ikon dan teks sejajar
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