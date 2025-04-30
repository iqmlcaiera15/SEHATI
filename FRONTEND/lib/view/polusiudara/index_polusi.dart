import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Sehati/models/air_quality_model.dart';
import 'package:Sehati/services/api/api_service_polusi.dart';

class IndexPolusi extends StatefulWidget {
  @override
  _IndexPolusiState createState() => _IndexPolusiState();
}

class _IndexPolusiState extends State<IndexPolusi> {
  Map<String, dynamic>? _airQualityData; // Untuk menyimpan data kualitas udara

  // Fungsi untuk mengambil data kualitas udara dari API
  Future<void> _fetchAirQualityData() async {
    try {
      final city = "Bandung"; // Kota Bandung
      final country = "Indonesia"; // Negara Indonesia
      final url = Uri.parse('https://sehatiapp-production.up.railway.app/kualitasudara?city=$city&country=$country');

      // Cek URL yang digunakan
      print('URL API: $url');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response Body: $data'); // Debug: Tampilkan response

        // Pengecekan untuk memastikan data yang diperlukan ada
        if (data != null && data['data'] != null && data['data']['current'] != null) {
          setState(() {
            _airQualityData = data['data'];  // Pastikan ini mengambil data yang benar
          });
        } else {
          setState(() {
            _airQualityData = {'error': 'Data kualitas udara tidak ditemukan.'};
          });
        }
      } else {
        setState(() {
          _airQualityData = {'error': 'Gagal mengambil data kualitas udara'};
        });
      }
    } catch (e) {
      print('Error fetching air quality: $e');
      setState(() {
        _airQualityData = {'error': 'Gagal mengambil data kualitas udara'};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAirQualityData(); // Panggil fungsi untuk mendapatkan data kualitas udara langsung untuk Bandung
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kualitas Udara Bandung'),
      ),
      body: Center(
        child: _airQualityData == null
            ? CircularProgressIndicator()
            : _airQualityData!['error'] != null
                ? Text(
                    _airQualityData!['error'],
                    style: TextStyle(color: Colors.red),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Air Quality (US AQI): ${_airQualityData!['current']['pollution']['aqius']}',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'City: ${_airQualityData!['city']}',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Country: ${_airQualityData!['country']}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IndexPolusi(),
  ));
}