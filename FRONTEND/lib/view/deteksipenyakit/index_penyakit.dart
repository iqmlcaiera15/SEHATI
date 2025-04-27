// lib/main.dart
import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_penyakit.dart';

void main() {
  runApp(const IndexPenyakit());
}

class IndexPenyakit extends StatelessWidget {
  const IndexPenyakit({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehati App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = ApiService.fetchDeteksiData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Deteksi')),
      body: FutureBuilder(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data as List<dynamic>;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return ListTile(
                  title: Text(item['nama'] ?? 'No Name'),
                  subtitle: Text("Prediksi Diabetes: ${item['diabetes_prediction'] ?? 'N/A'}"),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitDummyData,
        child: const Icon(Icons.send),
      ),
    );
  }

  void _submitDummyData() async {
    final result = await ApiService.submitDeteksiData({
      "nama": "Uji Coba",
      "pregnancies": 2,
      "age": 28,
      "bmi": 22.5,
      "blood_pressure": 70,
      "bs": 130,
      "skin_thickness": 20,
      "sex": 1,
      "current_smoker": 0,
      "cigs_per_day": 0,
      "bp_meds": 0,
      "systolic_bp": 120,
      "diastolic_bp": 80,
      "heart_rate": 85,
      "body_temp": 36.6,
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hasil Prediksi"),
        content: Text(result['prediction'].toString()),
      ),
    );
  }
}
