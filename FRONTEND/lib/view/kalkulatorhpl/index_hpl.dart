import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Sehati/services/api/api_service_hpl.dart';

class AddDataHPL extends StatefulWidget {
  const AddDataHPL({super.key});

  @override
  State<AddDataHPL> createState() => _AddDataHPLState();
}

class _AddDataHPLState extends State<AddDataHPL> {
  DateTime? selectedDate;
  String? estimatedDate;
  int? week;
  bool isLoading = false;

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

      if (data == null || data['hpht'] == null || data['hpl'] == null || data['minggu_ke'] == null) {
        throw Exception('Data dari server tidak lengkap atau salah format.');
      }

      final hpht = DateTime.parse(data['hpht']);
      final hpl = data['hpl'] as String;
      final mingguKe = (data['minggu_ke'] as num).round();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_hpht', data['hpht']);
      await prefs.setString('last_hpl', hpl);
      await prefs.setInt('last_week', mingguKe);

      setState(() {
        estimatedDate = hpl;
        week = mingguKe;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hasil HPL berhasil dihitung!')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kalkulator HPL',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Perkirakan Hari Perkiraan Lahir (HPL)\nsi Kecil',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hitung perkiraan kelahiran bayi dengan memilih metode dan tanggal yang sesuai',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('Tanggal', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate == null
                                ? 'Pilih Tanggal'
                                : DateFormat('dd MMM yyyy').format(selectedDate!),
                            style: TextStyle(
                              color: selectedDate == null ? Colors.grey : Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const Icon(Icons.calendar_today_outlined, size: 18)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: estimatedDate == null
                        ? ElevatedButton(
                            onPressed: isLoading ? null : _calculateHPL,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLoading ? const Color(0xFFFC5C9C) : Colors.white,
                              foregroundColor: const Color(0xFFFC5C9C),
                              elevation: 2,
                              side: const BorderSide(color: Color(0xFFFC5C9C)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              isLoading ? 'Menghitung...' : 'Hitung',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: isLoading ? Colors.white : const Color(0xFFFC5C9C),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context, {
                                'hpl': estimatedDate,
                                'mingguKe': week,
                              });
                            },
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              'Kembali',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DBAFF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  if (estimatedDate != null && week != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7ECFF),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Hari Perkiraan Lahir : ',
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  formatDate(estimatedDate),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCD2DF),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))],
                            ),
                            child: Text(
                              'Minggu ke-${week.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFB1004B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 28),
                  const Text(
                    'Catatan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFC5D2)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.black54),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'HPHT (Hari Pertama Haid Terakhir) digunakan untuk menghitung HPL secara umum.',
                                style: TextStyle(fontSize: 12, fontFamily: 'Poppins', height: 1.5),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.black54),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'USG memberikan hasil yang lebih akurat berdasarkan perkembangan janin.',
                                style: TextStyle(fontSize: 12, fontFamily: 'Poppins', height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
