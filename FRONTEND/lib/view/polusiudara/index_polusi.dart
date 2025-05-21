import 'package:flutter/material.dart';
import 'package:Sehati/models/air_quality_model.dart';
import 'package:Sehati/services/api/api_service_polusi.dart';
import 'dart:math' as math;

class IndexPolusi extends StatefulWidget {
  const IndexPolusi({Key? key}) : super(key: key);

  @override
  _IndexPolusiState createState() => _IndexPolusiState();
}

class _IndexPolusiState extends State<IndexPolusi> {
  Future<AirQualityModel>? _airQualityFuture;
  
  @override
  void initState() {
    super.initState();
    _fetchAirQualityData();
  }

  void _fetchAirQualityData() {
    setState(() {
      _airQualityFuture = ApiServicePolusi.getAirQualityData();
    });
  }

  String _getAqiCategory(int aqi) {
    if (aqi <= 50) {
      return 'Baik';
    } else if (aqi <= 100) {
      return 'Sedang';
    } else if (aqi <= 150) {
      return 'Tidak Sehat untuk Kelompok Sensitif';
    } else if (aqi <= 200) {
      return 'Tidak Sehat';
    } else if (aqi <= 300) {
      return 'Sangat Tidak Sehat';
    } else {
      return 'Berbahaya';
    }
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) {
      return const Color(0xFF00E400); // Hijau
    } else if (aqi <= 100) {
      return const Color(0xFFFFFF00); // Kuning
    } else if (aqi <= 150) {
      return const Color(0xFFFF7E00); // Oranye
    } else if (aqi <= 200) {
      return const Color(0xFFFF0000); // Merah
    } else if (aqi <= 300) {
      return const Color(0xFF8F3F97); // Ungu
    } else {
      return const Color(0xFF7E0023); // Merah tua
    }
  }

  List<String> _getHealthTips(int aqi) {
    if (aqi <= 50) {
      return [
        'Kualitas udara baik untuk ibu hamil',
        'Aman untuk beraktivitas di luar ruangan',
        'Tetap jaga kesehatan dengan minum air putih cukup'
      ];
    } else if (aqi <= 100) {
      return [
        'Kurangi aktivitas luar ruangan yang terlalu lama',
        'Gunakan masker saat keluar rumah',
        'Minum air putih yang cukup untuk detoksifikasi'
      ];
    } else if (aqi <= 150) {
      return [
        'Hindari aktivitas luar ruangan yang berat',
        'Gunakan masker N95 jika harus keluar rumah',
        'Perhatikan gejala gangguan pernapasan pada ibu hamil'
      ];
    } else {
      return [
        'Hindari aktivitas di luar ruangan',
        'Gunakan air purifier di dalam rumah',
        'Konsultasikan dengan dokter jika mengalami gejala gangguan pernapasan'
      ];
    }
  }

  String _getWeatherIcon(String iconCode) {
    // Mapping kode ikon cuaca ke ikon Material
    if (iconCode.contains('01')) {
      return '☀️'; // Cerah
    } else if (iconCode.contains('02')) {
      return '⛅'; // Berawan sebagian
    } else if (iconCode.contains('03') || iconCode.contains('04')) {
      return '☁️'; // Berawan
    } else if (iconCode.contains('09')) {
      return '🌧️'; // Hujan
    } else if (iconCode.contains('10')) {
      return '🌦️'; // Hujan dan cerah
    } else if (iconCode.contains('11')) {
      return '⛈️'; // Badai petir
    } else if (iconCode.contains('13')) {
      return '❄️'; // Salju
    } else if (iconCode.contains('50')) {
      return '🌫️'; // Kabut
    } else {
      return '🌡️'; // Default
    }
  }

  String _getWindDirection(int degree) {
    const List<String> directions = [
      'Utara', 'Timur Laut', 'Timur', 'Tenggara', 
      'Selatan', 'Barat Daya', 'Barat', 'Barat Laut'
    ];
    return directions[(((degree + 22.5) % 360) ~/ 45) % 8];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Kualitas Udara',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF4DBAFF),
        onRefresh: () async {
          _fetchAirQualityData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<AirQualityModel>(
              future: _airQualityFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4DBAFF)),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Color(0xFFFC5C9C)),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal memuat data: ${snapshot.error}',
                            style: const TextStyle(color: Color(0xFF1E293B)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _fetchAirQualityData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DBAFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Coba Lagi',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final airQualityData = snapshot.data!;
                  final pollution = airQualityData.data.current.pollution;
                  final weather = airQualityData.data.current.weather;
                  final aqiUS = pollution.aqius;
                  final aqiCategory = _getAqiCategory(aqiUS);
                  final aqiColor = _getAqiColor(aqiUS);
                  final healthTips = _getHealthTips(aqiUS);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lokasi dan Waktu
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFF4DBAFF), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${airQualityData.data.city}, ${airQualityData.data.state}, ${airQualityData.data.country}',
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Color(0xFF4C617F), size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Pembaruan terakhir: ${DateTime.parse(pollution.ts).toLocal().toString().substring(0, 16)}',
                                  style: const TextStyle(
                                    color: Color(0xFF4C617F),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // AQI Gauge Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [aqiColor.withOpacity(0.7), aqiColor],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: aqiColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Indeks Kualitas Udara (AQI)',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 180,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // AQI Gauge Background
                                  CustomPaint(
                                    size: const Size(180, 180),
                                    painter: AqiGaugePainter(aqiUS),
                                  ),
                                  // AQI Value
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        aqiUS.toString(),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        aqiCategory,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Berdasarkan US EPA Air Quality Index',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Weather Information
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Cuaca',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildWeatherItem(
                                  _getWeatherIcon(weather.ic),
                                  '${weather.tp}°C',
                                  'Suhu',
                                ),
                                _buildWeatherItem(
                                  '💧',
                                  '${weather.hu}%',
                                  'Kelembaban',
                                ),
                                _buildWeatherItem(
                                  '🧭',
                                  '${_getWindDirection(weather.wd)}',
                                  'Arah Angin',
                                ),
                                _buildWeatherItem(
                                  '💨',
                                  '${weather.ws} m/s',
                                  'Kec. Angin',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Health Tips
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tips Kesehatan untuk Ibu Hamil',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...healthTips.map((tip) => _buildTipItem(tip)).toList(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Explanation Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4DBAFF), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline, color: Color(0xFF4DBAFF), size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Apa itu AQI?',
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Air Quality Index (AQI) adalah ukuran yang digunakan untuk menunjukkan seberapa tercemar udara di suatu area. Semakin tinggi nilai AQI, semakin berbahaya bagi kesehatan Anda.\n\nBagi ibu hamil, kualitas udara yang buruk dapat berdampak pada kesehatan ibu dan perkembangan janin.',
                              style: TextStyle(
                                color: Color(0xFF4C617F),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // AQI Levels Explanation
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tingkat AQI dan Arti',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildAqiLevelItem('0-50', 'Baik', const Color(0xFF00E400)),
                            const SizedBox(height: 8),
                            _buildAqiLevelItem('51-100', 'Sedang', const Color(0xFFFFFF00)),
                            const SizedBox(height: 8),
                            _buildAqiLevelItem('101-150', 'Tidak Sehat untuk Kelompok Sensitif', const Color(0xFFFF7E00)),
                            const SizedBox(height: 8),
                            _buildAqiLevelItem('151-200', 'Tidak Sehat', const Color(0xFFFF0000)),
                            const SizedBox(height: 8),
                            _buildAqiLevelItem('201-300', 'Sangat Tidak Sehat', const Color(0xFF8F3F97)),
                            const SizedBox(height: 8),
                            _buildAqiLevelItem('301+', 'Berbahaya', const Color(0xFF7E0023)),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  );
                } else {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Center(
                      child: Text('Tidak ada data tersedia'),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4C617F),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4DBAFF), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAqiLevelItem(String range, String category, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          range,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '-',
          style: TextStyle(
            color: const Color(0xFF4C617F),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            category,
            style: TextStyle(
              color: const Color(0xFF4C617F),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class AqiGaugePainter extends CustomPainter {
  final int aqiValue;
  
  AqiGaugePainter(this.aqiValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );
    
    // Draw color segments
    final double startAngle = math.pi;
    final double sweepAngle = math.pi;
    final double segmentAngle = sweepAngle / 6;
    
    final List<Color> colors = [
      const Color(0xFF00E400), // Baik (0-50)
      const Color(0xFFFFFF00), // Sedang (51-100)
      const Color(0xFFFF7E00), // Tidak sehat untuk kelompok sensitif (101-150)
      const Color(0xFFFF0000), // Tidak sehat (151-200)
      const Color(0xFF8F3F97), // Sangat tidak sehat (201-300)
      const Color(0xFF7E0023), // Berbahaya (301+)
    ];
    
    for (int i = 0; i < 6; i++) {
      final segmentPaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 15),
        startAngle + (i * segmentAngle),
        segmentAngle,
        false,
        segmentPaint,
      );
    }
    
    // Convert AQI to angle
    double aqiAngle;
    if (aqiValue <= 50) {
      aqiAngle = startAngle + (aqiValue / 50) * segmentAngle;
    } else if (aqiValue <= 100) {
      aqiAngle = startAngle + segmentAngle + ((aqiValue - 50) / 50) * segmentAngle;
    } else if (aqiValue <= 150) {
      aqiAngle = startAngle + (2 * segmentAngle) + ((aqiValue - 100) / 50) * segmentAngle;
    } else if (aqiValue <= 200) {
      aqiAngle = startAngle + (3 * segmentAngle) + ((aqiValue - 150) / 50) * segmentAngle;
    } else if (aqiValue <= 300) {
      aqiAngle = startAngle + (4 * segmentAngle) + ((aqiValue - 200) / 100) * segmentAngle;
    } else {
      aqiAngle = startAngle + (5 * segmentAngle);
    }
    
    // Draw AQI needle
    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final needleLength = radius - 40;
    final needleWidth = 4.0;
    
    // Calculate end point of needle
    final needleEndX = center.dx + needleLength * math.cos(aqiAngle);
    final needleEndY = center.dy + needleLength * math.sin(aqiAngle);
    final needleEnd = Offset(needleEndX, needleEndY);
    
    // Calculate points for needle triangle
    final perpAngle = aqiAngle + (math.pi / 2);
    final point1X = center.dx + needleWidth * math.cos(perpAngle);
    final point1Y = center.dy + needleWidth * math.sin(perpAngle);
    final point1 = Offset(point1X, point1Y);
    
    final point2X = center.dx - needleWidth * math.cos(perpAngle);
    final point2Y = center.dy - needleWidth * math.sin(perpAngle);
    final point2 = Offset(point2X, point2Y);
    
    // Draw needle
    final path = Path()
      ..moveTo(point1.dx, point1.dy)
      ..lineTo(needleEnd.dx, needleEnd.dy)
      ..lineTo(point2.dx, point2.dy)
      ..close();
    
    canvas.drawPath(path, needlePaint);
    
    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 8, centerPaint);
  }
  
  @override
  bool shouldRepaint(AqiGaugePainter oldDelegate) {
    return oldDelegate.aqiValue != aqiValue;
  }
}