  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:intl/intl.dart';
  import 'package:Sehati/services/api/api_service_prediksi.dart';
  import 'package:Sehati/view/homeprofile/home.dart';
  import 'package:Sehati/view/prediksipersalinan/add_data_prediksi.dart';
  import 'package:pdf/widgets.dart' as pw;
  import 'package:printing/printing.dart';
  import 'package:file_saver/file_saver.dart';
  import 'dart:typed_data';
  import 'package:pdf/pdf.dart' as pw;
  import 'package:intl/date_symbol_data_local.dart';
  import 'package:Sehati/services/api/api_service_hpl.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';

  class IndexPrediksi extends StatefulWidget {
    const IndexPrediksi({super.key}); 
    

    @override
    State<IndexPrediksi> createState() => _IndexPrediksiState();
    
  }


  class _IndexPrediksiState extends State<IndexPrediksi> with SingleTickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;

    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _fadeAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      );
      _animationController.forward();
    }
    @override
    void dispose() {
    _animationController.dispose();
    super.dispose();
  }

    String selectedMetode = 'Semua';
    bool _refreshing = false;
    bool _hasPredictionData = false;
    final ScrollController _scrollController = ScrollController();

    Future<void> _refreshData() async {
      setState(() => _refreshing = true);
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _refreshing = false);
    }

    void _scrollToTop() {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }

    double _parseConfidence(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 240, 243),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 30),
                _buildFilterButtons(),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: buildPredictionList(),
                  ),
                ),
              ],
            ),
          ),
          // FLOATING BUTTON HANYA MUNCUL JIKA ADA DATA!
          if (_hasPredictionData)
            ...[
              // Floating "Mulai Prediksi" Button
              Positioned(
                bottom: 25,
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
                child: AnimatedOpacity(
                  opacity: _hasPredictionData ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 6,
                    borderRadius: BorderRadius.circular(15),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddDataPrediksi()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 77, 174, 255),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          "Mulai Prediksi",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // FAB for scroll to top
              Positioned(
                bottom: 110,
                right: 45,
                child: FloatingActionButton(
                  heroTag: 'backToTop',
                  backgroundColor: const Color.fromARGB(255, 77, 174, 255),
                  foregroundColor: Colors.white,
                  mini: true,
                  onPressed: _scrollToTop,
                  child: const Icon(Icons.arrow_upward),
                ),
              ),
            ],
          // TIDAK ADA TOMBOL FLOATING JIKA DATA KOSONG, hanya tombol di card kosong!
        ],
      ),
    );
  }



  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x2034aaf4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button (left)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF2277b6)),
            ),
          ),
          // Title (center)
          Center(
            child: Text(
              'Prediksi Persalinan',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 17, // ukuran lebih kecil (mirip hidrasi)
                color: Colors.black87,
              ),
            ),
          ),
          // Refresh (right)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF2277b6)),
              onPressed: _refreshData,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35), // Sesuaikan dengan container putih utama
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStyledFilterButton('Normal', const Color(0xFFD1EAFB)),
          const SizedBox(width: 8),
          _buildStyledFilterButton('Caesar', const Color(0xFFFFC0D9)),
          const SizedBox(width: 8),
          _buildStyledFilterButton('Semua', Colors.grey.shade300),
        ],
      ),
    );
  }

    Widget _buildStyledFilterButton(String label, Color color) {
      final bool isSelected = selectedMetode == label;

      Color borderColor;
      Color pastelBackground;

      if (label == 'Caesar') {
        borderColor = const Color(0xFFFF69B4);
        pastelBackground = const Color.fromARGB(255, 255, 208, 222);
      } else if (label == 'Normal') {
        borderColor = const Color(0xFF4DAEFF);
        pastelBackground = const Color(0xFFD1EAFB);
      } else {
        borderColor = const Color(0xFF515151);
        pastelBackground = const Color(0xFFD8D8D8);
      }

      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          decoration: BoxDecoration(
            color: isSelected ? pastelBackground : Colors.white,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextButton(
            onPressed: () => setState(() => selectedMetode = label),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: borderColor,
              ),
            ),
          ),
        ),
      );
    }

  Widget _buildWhiteContainer({required Widget child}) {
    return Center(
      child: Container(
        width: double.infinity, // ini untuk ngisi selebar parent padding
        constraints: const BoxConstraints(
          maxWidth: 700,
          minHeight: 800, // biar selalu tinggi minimal
        ),
        margin: const EdgeInsets.only(top: 12, bottom: 100),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildEmptyState() {
    return _buildWhiteContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 80, color: Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(height: 20),
          const Text(
            "Yah, sepertinya data bunda masih kosong",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Isi data kehamilan bunda yuk, agar bisa mengetahui hasil prediksi metode persalinan",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDataPrediksi()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 101, 180, 255),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                "Mulai Prediksi",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }



    String _formatDate(String? rawDate) {
      try {
        final parsed = DateTime.parse(rawDate ?? "");
        return DateFormat("dd-MM-yyyy").format(parsed);
      } catch (_) {
        return "-";
      }
    }

  Widget buildPredictionList() {
    return FutureBuilder<List<dynamic>>(
      future: ApiServicePrediksi.getRiwayatPrediksi(),
      builder: (context, snapshot) {
        if (_refreshing || snapshot.connectionState == ConnectionState.waiting) {
          // Loading state
          return const Center(child: CircularProgressIndicator());
        }

        // Data tidak ada atau error
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          // Hanya update _hasPredictionData jika sebelumnya true
          if (_hasPredictionData) {
            // Update di luar build setelah selesai
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _hasPredictionData = false);
            });
          }
          return _buildEmptyState();
        }

        // Data tersedia
        final dataOriginal = snapshot.data!;
        final dataFiltered = selectedMetode == 'Semua'
            ? dataOriginal
            : dataOriginal.where((item) =>
                (item['metode_persalinan']?.toLowerCase() ?? '') ==
                selectedMetode.toLowerCase()).toList();

        final hasDataToShow = dataFiltered.isNotEmpty;

        // Update flag hanya jika berubah saja (menghindari flicker!)
        if (_hasPredictionData != hasDataToShow) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _hasPredictionData = hasDataToShow);
          });
        }

        if (!hasDataToShow) return _buildEmptyState();

        return _buildWhiteContainer(
          child: ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: dataFiltered.length,
            itemBuilder: (context, index) => _buildPredictionCard(dataFiltered[index]),
          ),
        );
      },
    );
  }


Widget _buildPredictionCard(Map<String, dynamic> item) {
  final metode = item['metode_persalinan']?.toString().toLowerCase();
  final isCaesar = metode == 'caesar';
  final tanggal = _formatDate(item['created_at']);
  final warna = isCaesar ? const Color(0xFFFFF1F5) : const Color(0xFFF0F9FF);
  final border = isCaesar ? const Color(0xFFFC5C9C) : const Color(0xFF4DAEFF);
  final confidence = _parseConfidence(item['confidence']).round();

  dynamic faktorRaw = item['faktor'];
  List faktorList = [];
  if (faktorRaw != null) {
    if (faktorRaw is String && faktorRaw.trim().isNotEmpty && faktorRaw.trim() != "-") {
      try {
        final decoded = json.decode(faktorRaw);
        if (decoded is List) faktorList = decoded;
      } catch (_) {
        faktorList = [faktorRaw];
      }
    } else if (faktorRaw is List) {
      faktorList = faktorRaw;
    }
  }
  List<String> faktorLabelList = [];
  if (faktorList.isNotEmpty) {
    for (var f in faktorList) {
      if (f is List && f.isNotEmpty) {
        faktorLabelList.add(f[0].toString().split(' <= ')[0]);
      } else if (f is String) {
        faktorLabelList.add(f);
      } else {
        faktorLabelList.add(f.toString());
      }
    }
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 13),
    decoration: BoxDecoration(
      color: warna,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: border.withOpacity(0.55), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: border.withOpacity(0.07),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris 1: Badge & Confidence
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Badge metode
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        metode == null ? "-" : metode[0].toUpperCase() + metode.substring(1),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // CONFIDENCE MODERN (hanya angka dan ikon, tanpa oval)
                    Icon(Icons.bar_chart_rounded, size: 17, color: border),
                    const SizedBox(width: 3),
                    Text(
                      "$confidence%",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: border,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                // Faktor utama (Chip)
                faktorLabelList.isNotEmpty
                    ? Wrap(
                        spacing: 4,
                        runSpacing: -8,
                        children: faktorLabelList
                            .map(
                              (label) => Chip(
                                label: Text(label, style: GoogleFonts.poppins(fontSize: 11)),
                                backgroundColor: border.withOpacity(0.09),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  side: BorderSide(color: border.withOpacity(0.4)),
                                ),
                                labelPadding: const EdgeInsets.symmetric(horizontal: 7),
                                padding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                      )
                    : Text(
                        "-",
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                      ),
                // Tanggal
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    tanggal,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          // Tombol Detail (kanan atas)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 2),
            child: SizedBox(
              height: 34,
              child: TextButton(
                onPressed: () => _showDetailDialog(item, tanggal, faktorList, confidence),
                style: TextButton.styleFrom(
                  minimumSize: const Size(54, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Detail",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2277b6),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


    void _showDetailDialog(Map<String, dynamic> item, String tanggal, List faktorList, int confidence) {
      final metode = item['metode_persalinan']?.toString().toLowerCase();
      final isCaesar = metode == 'caesar';
      final Color badgeText = isCaesar ? const Color(0xFFFC5C9C) : const Color(0xFF4DAEFF);
      final Color badgeBg = isCaesar ? const Color(0xFFFFCCE2) : const Color(0xFFD9F1FF);
      final String label = isCaesar ? "Caesar" : "Normal";

      List<String> faktorLabelList = [];
      if (faktorList.isNotEmpty) {
        for (var f in faktorList) {
          if (f is List && f.isNotEmpty) {
            faktorLabelList.add(f[0].toString().split(' <= ')[0]);
          } else if (f is String) {
            faktorLabelList.add(f);
          } else {
            faktorLabelList.add(f.toString());
          }
        }
      }

      showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.black12, width: 1.5),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Detail Prediksi",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: badgeText,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: badgeBg,
                          border: Border.all(color: badgeText),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            color: badgeText,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 22, color: Colors.black12),
                  if (confidence > 0)
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFF4DAEFF), size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "$confidence%",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (faktorLabelList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Faktor Utama:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        ...faktorLabelList.map((label) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text("• $label", style: GoogleFonts.poppins(fontSize: 13)),
                        )),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Text("Data Input:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• Usia : ${item['usia_ibu']} Tahun", style: GoogleFonts.poppins(fontSize: 13)),
                        Text("• Tekanan Darah : ${item['tekanan_darah']}", style: GoogleFonts.poppins(fontSize: 13)),
                        Text("• Riwayat Persalinan : ${item['riwayat_persalinan']}", style: GoogleFonts.poppins(fontSize: 13)),
                        Text("• Riwayat Kesehatan : ${item['riwayat_kesehatan_ibu']}", style: GoogleFonts.poppins(fontSize: 13)),
                        Text("• Posisi Janin : ${item['posisi_janin']}", style: GoogleFonts.poppins(fontSize: 13)),
                        Text("• Kondisi Janin : ${item['kondisi_kesehatan_janin']}", style: GoogleFonts.poppins(fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Rekomendasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    isCaesar
                        ? "Bunda, segera konsultasikan dengan dokter untuk persiapan persalinan Caesar yang aman. Tetap tenang dan jaga kondisi tubuh dengan baik."
                        : "Bunda, kondisi Anda mendukung untuk persalinan normal. Terus jaga kesehatan dan kontrol rutin ke dokter.",
                    style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF334155)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Tutup", style: GoogleFonts.poppins(color: Colors.black)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: badgeText,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text("Unduh Hasil"),
                        onPressed: () {
                          Navigator.pop(context);
                          _downloadPredictionPdf(item, tanggal, faktorList);
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Fungsi PDF Export (tidak berubah, bisa tambah tombol di detail dialog jika ingin)
Future<void> _downloadPredictionPdf(Map<String, dynamic> item, String tanggalStr, List faktorList) async {
  await initializeDateFormatting('id_ID', null);

  // 1. Ambil data user
  Map<String, dynamic> userData = {};
  try {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('https://sehatiapp-production.up.railway.app/api/user-data'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      userData = data['data'] ?? {};
    }
  } catch (e) {
    userData = {};
  }

  // 2. Ambil HPL user
  String hpl = '-';
  try {
    final hplList = await ApiServiceHPL.getDataHPL();
    final userId = userData['id']?.toString();
    final myHPL = hplList.cast<Map<String, dynamic>>().firstWhere(
      (hplItem) => hplItem['user_id'].toString() == userId,
      orElse: () => {},
    );
    if (myHPL.isNotEmpty && myHPL['hpl'] != null) {
      try {
        final hplDate = DateTime.parse(myHPL['hpl']);
        hpl = DateFormat("dd MMMM yyyy", "id_ID").format(hplDate);
      } catch (_) {
        hpl = myHPL['hpl'].toString();
      }
    }
  } catch (e) {
    hpl = '-';
  }

  final nama = userData['name'] ?? '-';
  final telp = userData['nomor_telepon'] ?? '-';
  final userId = userData['id']?.toString() ?? 'user';
  final metode = (item['metode_persalinan'] ?? '-').toString();

  // 3. Format tanggal
  DateTime? parsedTanggal;
  try {
    parsedTanggal = DateFormat("dd-MM-yyyy").parseStrict(tanggalStr);
  } catch (_) {
    parsedTanggal = DateTime.tryParse(tanggalStr);
  }
  final formattedTanggal = parsedTanggal != null
      ? DateFormat("dd MMMM yyyy", "id_ID").format(parsedTanggal)
      : tanggalStr;

  final rekomendasi = metode.toLowerCase() == 'caesar'
      ? "Bunda, segera konsultasikan dengan dokter untuk persiapan persalinan Caesar yang aman. Tetap tenang dan jaga kondisi tubuh dengan baik."
      : "Bunda, kondisi Anda mendukung untuk persalinan normal. Terus jaga kesehatan dan kontrol rutin ke dokter.";

  // 4. Siapkan faktor utama untuk PDF
  List<String> faktorLabelList = [];
  if (faktorList.isNotEmpty) {
    for (var f in faktorList) {
      if (f is List && f.isNotEmpty) {
        faktorLabelList.add(f[0].toString().split(' <= ')[0]);
      } else if (f is String) {
        faktorLabelList.add(f);
      } else {
        faktorLabelList.add(f.toString());
      }
    }
  }

  // 5. Generate PDF
final pdf = pw.Document();
pdf.addPage(
  pw.Page(
    pageFormat: pw.PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    build: (context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // --- HEADER Judul Hasil Prediksi ---
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Hasil Prediksi', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(
                  metode,
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: pw.PdfColors.blue),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('SEHATI', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('Sehat Bersama Buah Hati', style: pw.TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 18),
        pw.Divider(),
        pw.SizedBox(height: 12),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            formattedTanggal,
            style: pw.TextStyle(fontSize: 12),
          ),
        ),
        
        pw.Text("Nama : $nama", style: pw.TextStyle(fontSize: 13)),
        pw.SizedBox(height: 3),
        pw.Text("Nomor Telp : $telp", style: pw.TextStyle(fontSize: 13)),
        pw.SizedBox(height: 3),
        pw.Text("Hari Perkiraan Lahir : $hpl", style: pw.TextStyle(fontSize: 13)),

        // --- Faktor Utama (hasil model)
        pw.SizedBox(height: 22),
        pw.Text("Faktor", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        if (faktorLabelList.isNotEmpty)
          ...faktorLabelList.map((f) => pw.Bullet(text: f)).toList(),

        // --- Data Kehamilan
        pw.SizedBox(height: 22),
        pw.Text("Data Kehamilan", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Bullet(text: 'Usia Ibu : ${item['usia_ibu']} tahun'),
        pw.Bullet(text: 'Tekanan Darah : ${item['tekanan_darah']}'),
        pw.Bullet(text: 'Riwayat Persalinan : ${item['riwayat_persalinan']}'),
        pw.Bullet(text: 'Riwayat Kesehatan Ibu : ${item['riwayat_kesehatan_ibu']}'),
        pw.Bullet(text: 'Posisi Janin : ${item['posisi_janin']}'),
        pw.Bullet(text: 'Kondisi Kesehatan Janin : ${item['kondisi_kesehatan_janin']}'),

        // --- Rekomendasi dan Catatan
        pw.SizedBox(height: 24),
        pw.Text("Rekomendasi :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(rekomendasi, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 24),
        pw.Text("Catatan :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(
          "Hasil prediksi ini hanya bersifat informatif dan tidak menggantikan konsultasi medis langsung dengan dokter.",
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.Spacer(),
        pw.Divider(),
        pw.Center(
          child: pw.Text(
            "© 2025 SEHATI | www.sehati.id | Kontak Bantuan: 0800-123-456",
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    ),
  ),
);



  final Uint8List bytes = await pdf.save();

  final res = await FileSaver.instance.saveFile(
    name: "Sehati_Hasil_Prediksi_${userId}.pdf",
    bytes: bytes,
    ext: "pdf",
    mimeType: MimeType.pdf,
  );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res != null
            ? 'PDF berhasil disimpan/diunduh!'
            : 'Gagal menyimpan/mengunduh PDF.'),
      ),
    );
  }
}
  }
