import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_penyakit.dart';
import 'result_deteksi_page.dart';

class AddDataPenyakit extends StatefulWidget {
  const AddDataPenyakit({super.key});

  @override
  State<AddDataPenyakit> createState() => _AddDataPenyakitState();
}

class _AddDataPenyakitState extends State<AddDataPenyakit> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _pregnanciesController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _bsController = TextEditingController();
  final TextEditingController _skinThicknessController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _currentSmokerController = TextEditingController();
  final TextEditingController _cigsPerDayController = TextEditingController();
  final TextEditingController _bpMedsController = TextEditingController();
  final TextEditingController _systolicBpController = TextEditingController();
  final TextEditingController _diastolicBpController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bodyTempController = TextEditingController();

  // Field info tooltips
  final Map<String, String> _fieldInfo = {
    'pregnancies': 'Jumlah kehamilan yang pernah dialami',
    'age': 'Usia Anda saat ini dalam tahun',
    'bmi': 'Body Mass Index (BMI) - indikator kegemukan. Normal: 18.5-24.9',
    'blood_pressure': 'Tekanan darah (mmHg). Normal: dibawah 120/80 mmHg',
    'bs': 'Kadar gula darah (mg/dL). Normal puasa: <100 mg/dL',
    'skin_thickness': 'Ketebalan lipatan kulit triceps (mm)',
    'sex': 'Jenis kelamin (1 untuk perempuan, 0 untuk laki-laki)',
    'current_smoker': 'Apakah Anda perokok aktif saat ini? (1: Ya, 0: Tidak)',
    'cigs_per_day': 'Jumlah rokok yang dihisap per hari',
    'bp_meds': 'Apakah mengonsumsi obat tekanan darah? (1: Ya, 0: Tidak)',
    'systolic_bp': 'Tekanan darah sistolik (mmHg). Normal: <120 mmHg',
    'diastolic_bp': 'Tekanan darah diastolik (mmHg). Normal: <80 mmHg',
    'heart_rate': 'Detak jantung per menit. Normal: 60-100 bpm',
    'body_temp': 'Suhu tubuh dalam Celcius. Normal: 36.1-37.2°C',
  };

  // Pre-fill with default values
  @override
  void initState() {
    super.initState();
    _sexController.text = "1"; // Default: Perempuan
    _currentSmokerController.text = "0"; // Default: Tidak merokok
    _bpMedsController.text = "0"; // Default: Tidak minum obat darah
    _bodyTempController.text = "36.5"; // Default normal temperature
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final formData = {
      "nama": _namaController.text,
      "pregnancies": int.tryParse(_pregnanciesController.text) ?? 0,
      "age": double.tryParse(_ageController.text) ?? 0.0,
      "bmi": double.tryParse(_bmiController.text) ?? 0.0,
      "blood_pressure": double.tryParse(_bloodPressureController.text) ?? 0.0,
      "bs": double.tryParse(_bsController.text) ?? 0.0,
      "skin_thickness": double.tryParse(_skinThicknessController.text) ?? 0.0,
      "sex": int.tryParse(_sexController.text) ?? 1,
      "current_smoker": int.tryParse(_currentSmokerController.text) ?? 0,
      "cigs_per_day": int.tryParse(_cigsPerDayController.text) ?? 0,
      "bp_meds": int.tryParse(_bpMedsController.text) ?? 0,
      "systolic_bp": double.tryParse(_systolicBpController.text) ?? 0.0,
      "diastolic_bp": double.tryParse(_diastolicBpController.text) ?? 0.0,
      "heart_rate": int.tryParse(_heartRateController.text) ?? 0,
      "body_temp": double.tryParse(_bodyTempController.text) ?? 36.5,
    };

    try {
      // Show a confirmation dialog before submitting
      final shouldContinue = await _showConfirmationDialog();
      if (!shouldContinue) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

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
          content: Text('Gagal mengirim data: $e'),
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
        title: const Text(
          'Konfirmasi Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pastikan data yang Anda masukkan sudah benar. Apakah Anda yakin ingin melanjutkan?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F7FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama: ${_namaController.text}'),
                    Text('Usia: ${_ageController.text} tahun'),
                    Text('BMI: ${_bmiController.text}'),
                    Text('Tekanan Darah: ${_systolicBpController.text}/${_diastolicBpController.text} mmHg'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Periksa Kembali',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DBAFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Lanjutkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
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
    _currentSmokerController.dispose();
    _cigsPerDayController.dispose();
    _bpMedsController.dispose();
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (fieldKey != null && _fieldInfo.containsKey(fieldKey))
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 16, color: Color(0xFF4DBAFF)),
                  onPressed: () => _showInfoPopup(context, label, _fieldInfo[fieldKey]!),
                ),
            ],
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4DBAFF)),
              ),
              suffix: suffix,
            ),
            validator: isRequired
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bagian ini harus diisi';
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
        title: Row(
          children: [
            const Icon(Icons.info, color: Color(0xFF4DBAFF)),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DBAFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Data Pribadi'),
        content: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF4DBAFF)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Kenapa data ini penting?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Data pribadi membantu kami untuk memberikan hasil yang lebih akurat sesuai dengan kondisi Anda. Semua data dijamin kerahasiaannya.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _namaController,
              label: 'Nama Lengkap',
            ),
            _buildTextField(
              controller: _ageController,
              label: 'Usia',
              keyboardType: TextInputType.number,
              fieldKey: 'age',
            ),
            _buildTextField(
              controller: _sexController,
              label: 'Jenis Kelamin',
              keyboardType: TextInputType.number,
              fieldKey: 'sex',
              enabled: false,
              suffix: const Text('1 = Perempuan', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Data Kehamilan'),
        content: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF4DBAFF)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Riwayat Kehamilan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Riwayat kehamilan Anda sebelumnya dapat mempengaruhi risiko terhadap berbagai kondisi kesehatan dalam kehamilan saat ini.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _pregnanciesController,
              label: 'Jumlah Kehamilan',
              keyboardType: TextInputType.number,
              fieldKey: 'pregnancies',
            ),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Data Indeks Tubuh'),
        content: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF4DBAFF)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Indeks dan Pengukuran Tubuh',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pengukuran-pengukuran berikut membantu menilai kondisi fisik Anda yang berkaitan dengan risiko kesehatan tertentu.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _bmiController,
              label: 'BMI (Body Mass Index)',
              keyboardType: TextInputType.number,
              fieldKey: 'bmi',
              suffix: const Text('kg/m²', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            _buildTextField(
              controller: _skinThicknessController,
              label: 'Ketebalan Lipatan Kulit',
              keyboardType: TextInputType.number,
              fieldKey: 'skin_thickness',
              suffix: const Text('mm', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            _buildTextField(
              controller: _bodyTempController,
              label: 'Suhu Tubuh',
              keyboardType: TextInputType.number,
              fieldKey: 'body_temp',
              suffix: const Text('°C', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: const Text('Data Tekanan Darah'),
        content: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF4DBAFF)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Kondisi Tekanan Darah',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tekanan darah yang sehat selama kehamilan sangat penting untuk mencegah komplikasi seperti preeklampsia.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _systolicBpController,
                    label: 'Sistolik',
                    keyboardType: TextInputType.number,
                    fieldKey: 'systolic_bp',
                    suffix: const Text('mmHg', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _diastolicBpController,
                    label: 'Diastolik',
                    keyboardType: TextInputType.number,
                    fieldKey: 'diastolic_bp',
                    suffix: const Text('mmHg', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                ),
              ],
            ),
            _buildTextField(
              controller: _bloodPressureController,
              label: 'Tekanan Darah (Rata-rata)',
              keyboardType: TextInputType.number,
              fieldKey: 'blood_pressure',
              suffix: const Text('mmHg', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            _buildTextField(
              controller: _heartRateController,
              label: 'Detak Jantung',
              keyboardType: TextInputType.number,
              fieldKey: 'heart_rate',
              suffix: const Text('bpm', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            _buildTextField(
              controller: _bpMedsController,
              label: 'Konsumsi Obat Tekanan Darah',
              keyboardType: TextInputType.number,
              fieldKey: 'bp_meds',
              suffix: const Text('1=Ya, 0=Tidak', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
        isActive: _currentStep >= 3,
      ),
      Step(
        title: const Text('Data Gula Darah & Lifestyle'),
        content: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF4DBAFF)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Kadar Gula & Gaya Hidup',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kadar gula darah dan kebiasaan merokok memiliki dampak signifikan terhadap kesehatan ibu dan janin.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _bsController,
              label: 'Kadar Gula Darah',
              keyboardType: TextInputType.number,
              fieldKey: 'bs',
              suffix: const Text('mg/dL', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            _buildTextField(
              controller: _currentSmokerController,
              label: 'Status Perokok',
              keyboardType: TextInputType.number,
              fieldKey: 'current_smoker',
              suffix: const Text('1=Ya, 0=Tidak', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            _buildTextField(
              controller: _cigsPerDayController,
              label: 'Jumlah Rokok/Hari',
              keyboardType: TextInputType.number,
              fieldKey: 'cigs_per_day',
              isRequired: false,
            ),
          ],
        ),
        isActive: _currentStep >= 4,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Risiko Kesehatan'),
        backgroundColor: const Color(0xFF4DBAFF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
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
                margin: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DBAFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _currentStep < _buildSteps().length - 1
                                    ? 'Lanjutkan'
                                    : 'Kirim Data',
                              ),
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Kembali'),
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
      bottomNavigationBar: _currentStep == _buildSteps().length - 1
          ? Container(
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
            )
          : null,
    );
  }
}