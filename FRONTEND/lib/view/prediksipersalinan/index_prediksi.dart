import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Sehati/services/api/api_service_prediksi.dart';
import 'package:Sehati/view/homeprofile/home.dart';
import 'package:Sehati/view/prediksipersalinan/add_data_prediksi.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:html' as html show AnchorElement, Blob, Url; // khusus Web
import 'package:pdf/pdf.dart' as pw;
import 'package:intl/date_symbol_data_local.dart';




class IndexPrediksi extends StatefulWidget {
  const IndexPrediksi({super.key});

  @override
  State<IndexPrediksi> createState() => _IndexPrediksiState();
}

class _IndexPrediksiState extends State<IndexPrediksi> with SingleTickerProviderStateMixin {
  String selectedMetode = 'Semua';
  bool _refreshing = false;
  bool _hasPredictionData = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _refreshing = false);
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 500 ? 16.0 : 48.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color.fromARGB(255, 235, 240, 243),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 30), // Jarak AppBar ke Filter Buttons
                _buildFilterButtons(),
                const SizedBox(height: 20), // jarak Filter Buttons ke Container Putih
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: buildPredictionList(),
                  ),
                ),
              ],
            ),
          ),


          if (_hasPredictionData)
            ...[
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
                        child: const Text("Mulai Prediksi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ),
              ),
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
        ],
      ),
    );
  }


  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            ),
            child: _buildBackButton(),
          ),
          const Spacer(),
          const Text('Prediksi Persalinan', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E293B)),
            onPressed: _refreshData,
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: const Center(
        child: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 16),
      ),
    );
  }
Widget _buildFilterButtons() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal:35),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = (constraints.maxWidth - 16) / 3; // 16 = total 2 x 8px spacing
        return Row(
          children: [
            SizedBox(width: buttonWidth, child: _buildStyledFilterButton('Normal', const Color(0xFFAEE0FF))),
            const SizedBox(width: 8),
            SizedBox(width: buttonWidth, child: _buildStyledFilterButton('Caesar', const Color(0xFFFFC0D9))),
            const SizedBox(width: 8),
            SizedBox(width: buttonWidth, child: _buildStyledFilterButton('Semua', Colors.grey)),
          ],
        );
      },
    ),
  );
}


Widget _buildBadge(String metode) {
  final isCaesar = metode == 'caesar';
  final Color textColor = isCaesar ? const Color(0xFFFC5C9C) : const Color(0xFF4DAEFF);
  final Color bgColor = isCaesar ? const Color(0xFFFFCCE2) : const Color(0xFFD9F1FF);
  final String label = isCaesar ? 'Caesar' : 'Normal';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      border: Border.all(color: textColor),
      borderRadius: BorderRadius.circular(50), // bentuk oval
    ),
    child: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
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

  return AnimatedContainer(
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
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
          color: borderColor,
        ),
      ),
    ),
  );
}
Widget _buildWhiteContainer({required Widget child}) {
  const double containerWidth = 800; // lebar 
  const double containerHeight = 800; // tinggi 

  return Center(
    child: Container(
      width: containerWidth,
      height: containerHeight,
      // height: otomatis, jadi tidak diatur di sini
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
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        return _buildEmptyState();
      }

      final dataOriginal = snapshot.data!;
      final dataFiltered = selectedMetode == 'Semua'
          ? dataOriginal
          : dataOriginal.where((item) =>
              (item['metode_persalinan']?.toLowerCase() ?? '') ==
              selectedMetode.toLowerCase()).toList();

      final hasDataToShow = dataFiltered.isNotEmpty;

      // Update state (sekali) jika nilai hasData berubah
      if (_hasPredictionData != hasDataToShow) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasPredictionData = hasDataToShow;
            });
          }
        });
      }

      if (!hasDataToShow) return _buildEmptyState();

      // Container Putih
      return _buildWhiteContainer(
        child: ListView.builder(
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
  final warna = isCaesar ? const Color(0xFFFFE4EC) : const Color(0xFFE0F4FF);
  final border = isCaesar ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: warna,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bagian Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hasil Prediksi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(tanggal, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),

        const SizedBox(height: 8), // Jarak antar blok

        // Faktor
        Text(
          "Faktor: ${item['faktor'] ?? '-'}",
          style: const TextStyle(fontSize: 14),
        ),

        const SizedBox(height: 8), // Jarak antar blok

        // Badge + Detail Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBadge(metode ?? '-'),
            TextButton(
              onPressed: () => _showDetailDialog(item, tanggal),
              child: const Text("Detail", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ],
    ),
  );
}


void _showDetailDialog(Map<String, dynamic> item, String tanggal) {
  final isCaesar = (item['metode_persalinan']?.toString().toLowerCase() == 'caesar');
  final Color badgeText = isCaesar ? const Color(0xFFFC5C9C) : const Color(0xFF4DAEFF);
  final Color badgeBg = isCaesar ? const Color(0xFFFFCCE2) : const Color(0xFFD9F1FF);
  final String label = isCaesar ? "Caesar" : "Normal";

  showDialog(
    context: context,
    builder: (BuildContext context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.black, width: 1.5), // ⬛ Border hitam tebal
      ),
      backgroundColor: Colors.white, // Background putih
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
                  const Text(
                    "Detail Prediksi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    tanggal,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Badge metode
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  border: Border.all(color: badgeText),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: badgeText,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Faktor
              Text(
                "Faktor: ${item['faktor'] ?? '-'}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // 🔹 Detail poin-poin
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• Usia : ${item['usia_ibu']} Tahun"),
                    Text("• Tekanan Darah : ${item['tekanan_darah']}"),
                    Text("• Riwayat Persalinan : ${item['riwayat_persalinan']}"),
                    Text("• Riwayat Kesehatan : ${item['riwayat_kesehatan_ibu']}"),
                    Text("• Posisi Janin : ${item['posisi_janin']}"),
                    Text("• Kondisi Janin : ${item['kondisi_kesehatan_janin']}"),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rekomendasi
              const Text("Rekomendasi", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                isCaesar
                    ? "Bunda, segera konsultasikan dengan dokter untuk persiapan persalinan Caesar yang aman. Tetap tenang dan jaga kondisi tubuh dengan baik."
                    : "Bunda, kondisi Anda mendukung untuk persalinan normal. Terus jaga kesehatan dan kontrol rutin ke dokter.",
                style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 20),

              // Aksi Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _downloadPredictionPdf(item, tanggal),
                    icon: const Icon(Icons.download, size: 12),
                    label: const Text("Unduh Hasil"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF4D9EFF), // biru netral
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tutup", style: TextStyle(color: Colors.black)),
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


Future<void> _downloadPredictionPdf(Map<String, dynamic> item, String tanggalStr) async {
  await initializeDateFormatting('id_ID', null);

  final metode = (item['metode_persalinan'] ?? '-').toString();
  final faktor = item['faktor'] ?? '-';
  final nama = item['nama'] ?? '-';
  final telp = item['telp'] ?? '-';
  final hpl = item['hpl'] ?? '-';

  // Format tanggal (support dd-MM-yyyy dan yyyy-MM-dd)
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
      ? "Bunda, segera konsultasikan dengan dokter untuk persiapan persalinan Caesar yang aman. "
          "Tetap tenang dan jaga kondisi tubuh dengan baik."
      : "Bunda, kondisi Anda mendukung untuk persalinan normal. "
          "Terus jaga kesehatan dan kontrol rutin ke dokter.";

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: pw.PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header (judul kiri, brand kanan)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Hasil', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Prediksi', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
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

          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              formattedTanggal,
              style: pw.TextStyle(fontSize: 12),
            ),
          ),

          // Data Ibu
          pw.SizedBox(height: 20),
          pw.Text("Nama : $nama"),
          pw.SizedBox(height: 8),
          pw.Text("Nomor Telp : $telp"),
          pw.SizedBox(height: 8),
          pw.Text("Hari Perkiraan Lahir : $hpl"),

          // Hasil Prediksi
          pw.SizedBox(height: 24),
          pw.Text("Hasil Prediksi Metode Persalinan : $metode", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Text("Faktor :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Usia Ibu : ${item['usia_ibu']} tahun'),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Tekanan Darah : ${item['tekanan_darah']}'),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Riwayat Persalinan : ${item['riwayat_persalinan']}'),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Riwayat Kesehatan Ibu : ${item['riwayat_kesehatan_ibu']}'),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Posisi Janin : ${item['posisi_janin']}'),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Kondisi Kesehatan Janin : ${item['kondisi_kesehatan_janin']}'),

          // Rekomendasi
          pw.SizedBox(height: 24),
          pw.Text("Rekomendasi :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text(rekomendasi, style: const pw.TextStyle(fontSize: 12)),

          // Catatan
          pw.SizedBox(height: 24),
          pw.Text("Catatan :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text(
            "Hasil prediksi ini hanya bersifat informatif dan tidak menggantikan konsultasi medis langsung dengan dokter.",
            style: const pw.TextStyle(fontSize: 12),
          ),

          // Footer
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

  try {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "Sehati_Hasil_Prediksi.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);
  } catch (_) {
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }
}


  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
