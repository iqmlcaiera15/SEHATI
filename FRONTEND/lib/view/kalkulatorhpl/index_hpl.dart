import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Sehati/services/api/api_service_hpl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Sehati/view/homeprofile/home.dart';
import 'package:google_fonts/google_fonts.dart';

class AddDataHPL extends StatefulWidget {
  const AddDataHPL({super.key});
  @override
  State<AddDataHPL> createState() => _AddDataHPLState();
}

class _AddDataHPLState extends State<AddDataHPL> with SingleTickerProviderStateMixin {
  bool isManualInput = false;         // ⬅️ Tambahan: toggle untuk input manual
  DateTime? selectedDate;             // Untuk input HPHT
  DateTime? selectedHPLDate;          // Untuk input manual HPL
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
      duration: const Duration(milliseconds: 450),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.17),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _loadLatestHPL();
  }

  // Ambil data HPL terbaru user dari backend
  Future<void> _loadLatestHPL() async {
    setState(() { isLoading = true; });
    try {
      final dataList = await ApiServiceHPL.getDataHPL();
      if (dataList.isNotEmpty) {
        final latest = dataList.first;
        setState(() {
          estimatedDate = latest['hpl']?.toString() ?? latest['due_date']?.toString();
          week = latest['minggu_ke'] is int
              ? latest['minggu_ke']
              : int.tryParse(latest['minggu_ke']?.toString() ?? latest['pregnancy_week']?.toString() ?? '0');
        });
        _controller.forward();
      } else {
        setState(() {
          estimatedDate = null;
          week = null;
        });
      }
    } catch (e) {
      setState(() {
        estimatedDate = null;
        week = null;
      });
    } finally {
      if (mounted) setState(() { isLoading = false; });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4DBAFF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
            dialogTheme: const DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isManualInput) {
          selectedHPLDate = picked;
        } else {
          selectedDate = picked;
        }
      });
    }
  }

  // Fungsi submit
  Future<void> _onSubmit() async {
    setState(() => isLoading = true);

    try {
      if (!isManualInput) {
        // Hitung HPL dari HPHT
        if (selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Pilih tanggal HPHT terlebih dahulu!"),
            backgroundColor: Colors.redAccent,
          ));
          setState(() => isLoading = false);
          return;
        }
        final response = await ApiServiceHPL.calculateHPL(selectedDate!);
        final data = response['data'];
        final hpl = data['hpl']?.toString() ?? data['due_date']?.toString();
        final mingguKe = (data['minggu_ke'] is int)
            ? data['minggu_ke']
            : int.tryParse(data['minggu_ke']?.toString() ?? data['pregnancy_week']?.toString() ?? '0');

        setState(() {
          estimatedDate = hpl;
          week = mingguKe;
        });
      } else {
        // Input HPL manual
        if (selectedHPLDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Pilih tanggal HPL terlebih dahulu!"),
            backgroundColor: Colors.redAccent,
          ));
          setState(() => isLoading = false);
          return;
        }
        final response = await ApiServiceHPL.inputManualHPL(selectedHPLDate!);
        final data = response['data'];
        setState(() {
          estimatedDate = data['hpl']?.toString() ?? data['due_date']?.toString();
          week = data['minggu_ke'] is int
              ? data['minggu_ke']
              : int.tryParse(data['minggu_ke']?.toString() ?? data['pregnancy_week']?.toString() ?? '0');
        });
      }

      _controller.forward();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF4DBAFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Data HPL berhasil disimpan!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gagal menyimpan data: $e',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      setState(() => isLoading = false);
      _loadLatestHPL();
    }
  }

  String formatDateHPL(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(date));
    } catch (_) {
      try {
        final parts = date.split('-');
        if (parts.length == 3 && parts[0].length == 2) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final dt = DateTime(year, month, day);
          return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
        }
      } catch (_) {}
      return date;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFancyAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 44, left: 18, right: 18, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1E293B),
                  size: 18,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Kalkulator HPL',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.14,
              shadows: [
                const Shadow(
                  blurRadius: 4,
                  color: Colors.white,
                  offset: Offset(1, 1),
                )
              ],
            ),
          ),
          const Spacer(),
          Opacity(opacity: 0, child: Icon(Icons.refresh)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F7FF), Color(0xFFF8FCFF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFancyAppBar(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                children: [
                  const SizedBox(height: 10),
                  // Toggle Input Mode
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Hitung dari HPHT", style: GoogleFonts.poppins(fontSize: 13.7, color: isManualInput ? Colors.grey[500] : Color(0xFF1A87E3))),
                        Switch(
                          value: isManualInput,
                          onChanged: (val) {
                            setState(() {
                              isManualInput = val;
                              selectedDate = null;
                              selectedHPLDate = null;
                            });
                          },
                          activeColor: const Color(0xFF4DBAFF),
                        ),
                        Text("Input HPL Langsung", style: GoogleFonts.poppins(fontSize: 13.7, color: isManualInput ? Color(0xFF1A87E3) : Colors.grey[500])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Input Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 22, top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.09),
                          blurRadius: 32,
                          offset: const Offset(0, 7),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4DBAFF), Color(0xFF1A87E3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4DBAFF).withOpacity(0.24),
                                blurRadius: 24,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isManualInput ? 'Input Hari Perkiraan Lahir (HPL)' : 'Hari Perkiraan Lahir (HPL)',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          isManualInput
                              ? 'Masukkan tanggal HPL jika sudah diketahui dari dokter.'
                              : 'Masukkan tanggal HPHT untuk estimasi HPL.',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            color: Colors.blueGrey[400]!,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _pickDate,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                            decoration: BoxDecoration(
                              color: (isManualInput ? selectedHPLDate : selectedDate) != null
                                  ? const Color(0xFFDEF7FF)
                                  : const Color(0xFFF4F9FE),
                              border: Border.all(
                                color: (isManualInput ? selectedHPLDate : selectedDate) == null
                                    ? const Color(0xFFE3E8F0)
                                    : const Color(0xFF4DBAFF),
                                width: (isManualInput ? selectedHPLDate : selectedDate) == null ? 1 : 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                if ((isManualInput ? selectedHPLDate : selectedDate) != null)
                                  BoxShadow(
                                    color: const Color(0xFF4DBAFF).withOpacity(0.07),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.date_range,
                                  size: 26,
                                  color: (isManualInput ? selectedHPLDate : selectedDate) == null
                                      ? const Color(0xFFA0AEC0)
                                      : const Color(0xFF1A87E3),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    (isManualInput
                                            ? (selectedHPLDate == null ? 'Pilih Tanggal HPL' : DateFormat('dd MMM yyyy', 'id_ID').format(selectedHPLDate!))
                                            : (selectedDate == null ? 'Pilih Tanggal HPHT' : DateFormat('dd MMM yyyy', 'id_ID').format(selectedDate!))),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: (isManualInput ? selectedHPLDate : selectedDate) == null
                                          ? Colors.grey[500]
                                          : const Color(0xFF1A87E3),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                AnimatedOpacity(
                                  opacity: (isManualInput ? selectedHPLDate : selectedDate) != null ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 220),
                                  child: (isManualInput ? selectedHPLDate : selectedDate) != null
                                      ? const Icon(Icons.check_circle, color: Color(0xFF4DBAFF), size: 22)
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedScale(
                            scale: isLoading ? 0.96 : 1,
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeInOut,
                            child: isLoading
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: isLoading ? null : _onSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4DBAFF),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Text(
                                      isManualInput ? 'Simpan HPL' : 'Hitung HPL',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 16.5,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (estimatedDate != null && week != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 150,
                            maxWidth: 370,
                          ),
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFDDF7FF),
                                    Color(0xFFC4E0FF),
                                    Color(0xFFF2F7FF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.withOpacity(0.11),
                                    blurRadius: 20,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Ikon bayi dengan efek glass
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.22),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.23),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.12),
                                          blurRadius: 12,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.child_care_rounded,
                                      size: 28,
                                      color: Colors.blue[300],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Hari Perkiraan Lahir",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.08,
                                      color: Colors.blueGrey[900]?.withOpacity(0.92),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatDateHPL(estimatedDate),
                                    style: GoogleFonts.poppins(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.7,
                                      color: const Color(0xFF2260A3),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.21),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "Usia Kehamilan: Minggu ke-${week.toString().padLeft(2, '0')}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2260A3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: 120,
                                    height: 36,
                                    child: ElevatedButton.icon(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              Navigator.of(context).pushAndRemoveUntil(
                                                MaterialPageRoute(builder: (context) => const HomePage()),
                                                (route) => false,
                                              );
                                            },
                                      icon: const Icon(
                                        Icons.home_outlined,
                                        size: 17,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        "Beranda",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4DBAFF),
                                        elevation: 4,
                                        shadowColor: Colors.blue.withOpacity(0.15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(13),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        minimumSize: const Size(40, 34),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
