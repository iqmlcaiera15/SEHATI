import 'package:flutter/material.dart';

class ResultDeteksiPage extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultDeteksiPage({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Prediksi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hasil Prediksi:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Prediksi Diabetes: ${resultData['diabetes_prediction']}'),
            Text('Prediksi Hipertensi: ${resultData['hypertension_prediction']}'),
            Text('Prediksi Kesehatan Maternal: ${resultData['maternal_health_prediction']}'),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Balik ke home
                },
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
