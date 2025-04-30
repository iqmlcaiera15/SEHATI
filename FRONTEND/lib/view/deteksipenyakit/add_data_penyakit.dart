import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_penyakit.dart'; // <<< Ini pastikan sudah import servicenya
import 'result_deteksi_page.dart'; // <<< Untuk halaman hasil

class AddDataPenyakit extends StatefulWidget {
  const AddDataPenyakit({super.key});

  @override
  State<AddDataPenyakit> createState() => _AddDataPenyakitState();
}

class _AddDataPenyakitState extends State<AddDataPenyakit> {
  final _formKey = GlobalKey<FormState>();

  // Controller
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

  bool _isLoading = false;

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
      "sex": int.tryParse(_sexController.text) ?? 0,
      "current_smoker": int.tryParse(_currentSmokerController.text) ?? 0,
      "cigs_per_day": int.tryParse(_cigsPerDayController.text) ?? 0,
      "bp_meds": int.tryParse(_bpMedsController.text) ?? 0,
      "systolic_bp": double.tryParse(_systolicBpController.text) ?? 0.0,
      "diastolic_bp": double.tryParse(_diastolicBpController.text) ?? 0.0,
      "heart_rate": int.tryParse(_heartRateController.text) ?? 0,
      "body_temp": double.tryParse(_bodyTempController.text) ?? 0.0,
    };

    try {
      // Panggil API Service yang sudah kamu buat
      final result = await ApiService.submitDeteksiData(formData);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultDeteksiPage(resultData: result),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Data Penyakit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Data Pribadi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(controller: _namaController, decoration: const InputDecoration(labelText: 'Nama')),
              TextFormField(controller: _ageController, decoration: const InputDecoration(labelText: 'Usia'), keyboardType: TextInputType.number),
            

              const SizedBox(height: 20),
              const Text('Data Kehamilan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(controller: _pregnanciesController, decoration: const InputDecoration(labelText: 'Jumlah Kehamilan'), keyboardType: TextInputType.number),

              const SizedBox(height: 20),
              const Text('Data Medis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(controller: _bmiController, decoration: const InputDecoration(labelText: 'BMI'), keyboardType: TextInputType.number),
              TextFormField(controller: _bloodPressureController, decoration: const InputDecoration(labelText: 'Blood Pressure'), keyboardType: TextInputType.number),
              TextFormField(controller: _bsController, decoration: const InputDecoration(labelText: 'Blood Sugar'), keyboardType: TextInputType.number),
              TextFormField(controller: _skinThicknessController, decoration: const InputDecoration(labelText: 'Skin Thickness'), keyboardType: TextInputType.number),
              TextFormField(controller: _systolicBpController, decoration: const InputDecoration(labelText: 'Systolic BP'), keyboardType: TextInputType.number),
              TextFormField(controller: _diastolicBpController, decoration: const InputDecoration(labelText: 'Diastolic BP'), keyboardType: TextInputType.number),
              TextFormField(controller: _heartRateController, decoration: const InputDecoration(labelText: 'Heart Rate'), keyboardType: TextInputType.number),
              TextFormField(controller: _bodyTempController, decoration: const InputDecoration(labelText: 'Body Temp'), keyboardType: TextInputType.number),

              const SizedBox(height: 20),
              const Text('Data Merokok', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(controller: _currentSmokerController, decoration: const InputDecoration(labelText: 'Apakah Perokok? (1/0)'), keyboardType: TextInputType.number),
              TextFormField(controller: _cigsPerDayController, decoration: const InputDecoration(labelText: 'Jumlah Rokok per Hari'), keyboardType: TextInputType.number),
              TextFormField(controller: _bpMedsController, decoration: const InputDecoration(labelText: 'Menggunakan Obat Tekanan Darah (1/0)'), keyboardType: TextInputType.number),

              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitData,
                      child: const Text('Submit Data'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
