import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Sehati/models/kick_counter_model.dart';
import 'package:Sehati/services/api/api_service_kickcounter.dart';
import 'package:Sehati/view/kickcounter/kick_counter_session.dart';

class IndexKickCounter extends StatefulWidget {
  const IndexKickCounter({Key? key}) : super(key: key);

  @override
  State<IndexKickCounter> createState() => _IndexKickCounterState();
}

class _IndexKickCounterState extends State<IndexKickCounter> {
  late Future<List<KickCounter>> _kickCounterData;
  
  @override
  void initState() {
    super.initState();
    _loadKickCounterData();
  }
  
  void _loadKickCounterData() {
    setState(() {
      _kickCounterData = ApiServiceKickCounter.fetchKickCounterData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Kick Counter',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Information Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD1EDFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF4DBAFF),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Panduan Kick Counter',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mulai menghitung tendangan bayi sejak usia 28 minggu kandungan. Idealnya, catat 10 gerakan dalam waktu 2 jam. Jika kurang dari 10 gerakan dalam 2 jam, segera konsultasikan ke dokter.',
                        style: TextStyle(
                          color: Color(0xFF4C617F),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => _buildInfoDialog(context),
                          );
                        },
                        child: Text(
                          'Pelajari lebih lanjut',
                          style: TextStyle(
                            color: const Color(0xFF4DBAFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Kick Counter Data
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<List<KickCounter>>(
                future: _kickCounterData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4DBAFF)),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFFC5C9C), size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada data tendangan bayi',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mulai pantau tendangan bayi Anda',
                            style: TextStyle(
                              color: Color(0xFF4C617F),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final kickData = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Riwayat Tendangan Bayi',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: kickData.length,
                            itemBuilder: (context, index) {
                              final item = kickData[index];
                              return _buildKickCounterItem(item);
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KickCounterSession()),
          );
          
          if (result == true) {
            _loadKickCounterData();
          }
        },
        backgroundColor: const Color(0xFF4DBAFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildKickCounterItem(KickCounter item) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    String kickStatusText = '';
    Color statusColor = Colors.green;
    
    if (item.duration != null) {
      // Calculate kicks per hour
      double kicksPerHour = (item.kickCount / item.duration!) * 60;
      if (kicksPerHour < 5) {
        kickStatusText = 'Perlu Perhatian';
        statusColor = const Color(0xFFFC5C9C);
      } else if (kicksPerHour >= 5 && kicksPerHour < 10) {
        kickStatusText = 'Normal';
        statusColor = Colors.amber;
      } else {
        kickStatusText = 'Sangat Aktif';
        statusColor = const Color(0xFF4DBAFF);
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(item.recordedAt),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    kickStatusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildKickCounterInfo(
                  'Jumlah Tendangan',
                  '${item.kickCount} tendangan',
                  Icons.baby_changing_station,
                ),
                const SizedBox(width: 16),
                _buildKickCounterInfo(
                  'Durasi',
                  '${item.duration ?? "N/A"} menit',
                  Icons.timer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKickCounterInfo(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4DBAFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4DBAFF),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF4C617F),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoDialog(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Panduan Kick Counter',
        style: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoSection(
              'Kapan mulai menghitung?',
              'Mulai menghitung tendangan bayi sejak usia 28 minggu kandungan. Pada fase ini, bayi sudah memiliki pola gerakan teratur.',
            ),
            _buildInfoSection(
              'Berapa kali sehari?',
              'Lakukan penghitungan setidaknya 1 kali sehari, pada waktu yang sama setiap hari. Pilih waktu di mana bayi Anda biasanya aktif.',
            ),
            _buildInfoSection(
              'Target tendangan',
              'Idealnya, Anda akan merasakan 10 gerakan bayi dalam waktu 2 jam. Jika mencapai 10 gerakan sebelum 2 jam, Anda dapat menghentikan penghitungan.',
            ),
            _buildInfoSection(
              'Kapan harus waspada?',
              'Jika Anda merasakan kurang dari 10 gerakan dalam 2 jam, atau gerakan terasa berkurang secara signifikan dari biasanya, segera konsultasikan dengan dokter atau bidan Anda.',
            ),
            _buildInfoSection(
              'Posisi terbaik',
              'Berbaring miring ke kiri saat menghitung tendangan bayi akan meningkatkan aliran darah ke plasenta, membantu bayi lebih aktif.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Tutup',
            style: TextStyle(
              color: const Color(0xFF4DBAFF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
  
  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              color: const Color(0xFF4C617F),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}