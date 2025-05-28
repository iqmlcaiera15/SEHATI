import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Sehati/services/api/api_service_hpl.dart';
import 'package:shimmer/shimmer.dart';

class AddDataHPL extends StatefulWidget {
  const AddDataHPL({super.key});

  @override
  State<AddDataHPL> createState() => _AddDataHPLState();
}

class _AddDataHPLState extends State<AddDataHPL> with SingleTickerProviderStateMixin {
  DateTime? selectedDate;
  String? estimatedDate;
  int? week;
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

Future<void> _calculateHPL() async {
  if (selectedDate == null) return;
  setState(() => isLoading = true);

  try {
    final response = await ApiServiceHPL.calculateHPL(selectedDate!);
    final data = response['data'];
    final hpht = DateTime.parse(data['hpht']);
    final hpl = data['hpl'] as String;
    final mingguKe = (data['minggu_ke'] as num).round(); // pastikan dibulatkan

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_hpht', data['hpht']);
    await prefs.setString('last_hpl', hpl);
    await prefs.setInt('last_week', mingguKe);

    setState(() {
      estimatedDate = hpl;
      week = mingguKe;
    });

    _controller.forward();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('HPL berhasil dihitung!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menghitung HPL: $e')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}

  String formatDate(String? date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return 'Format salah';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Kalkulator HPL', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perkirakan Hari Perkiraan Lahir (HPL)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Masukkan Hari Pertama Haid Terakhir (HPHT) untuk menghitung estimasi kelahiran si Kecil.',
              style: TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),

            /// Tanggal Input
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, size: 20, color: Color(0xFF4DBAFF)),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null
                          ? 'Pilih Tanggal HPHT'
                          : DateFormat('dd MMM yyyy').format(selectedDate!),
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedDate == null ? Colors.grey : Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Button
            SizedBox(
              width: double.infinity,
              child: isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _calculateHPL,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4DBAFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Hitung HPL',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            /// Hasil
            if (estimatedDate != null && week != null)
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4DBAFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: Color(0xFF0288D1)),
                          SizedBox(width: 8),
                          Text(
                            'Hasil Estimasi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Color(0xFF0288D1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Hari Perkiraan Lahir: ',
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                          ),
                          Expanded(
                            child: Text(
                              formatDate(estimatedDate),
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Usia Kehamilan: Minggu ke-${week.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFFEF6C00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
