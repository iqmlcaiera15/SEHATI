import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_penyakit.dart';
import 'package:Sehati/view/deteksipenyakit/add_data_penyakit.dart'; // Import the new screen
import 'package:Sehati/view/homeprofile/home.dart'; // Import disease index page

void main() {
  runApp(const IndexPenyakit());
}

class IndexPenyakit extends StatelessWidget {
  const IndexPenyakit({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehati App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePenyakit(),
    );
  }
}

class HomePenyakit extends StatefulWidget {
  const HomePenyakit({Key? key}) : super(key: key);

  @override
  State<HomePenyakit> createState() => _HomePenyakitState();
}

class _HomePenyakitState extends State<HomePenyakit> {
  late Future<List<dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _data = ApiService.fetchDeteksiData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Status Bar Space
          Container(
            width: double.infinity,
            height: 44,
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  left: 21,
                  top: 10.50,
                  child: SizedBox(
                    width: 54,
                    child: Text(
                      '9:41',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ),
                ),
                // Battery icon
                Positioned(
                  left: 389.33,
                  top: 17.33,
                  child: Opacity(
                    opacity: 0.35,
                    child: Container(
                      width: 22,
                      height: 11.33,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFF1E293B),
                          ),
                          borderRadius: BorderRadius.circular(2.67),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 391.33,
                  top: 19.33,
                  child: Container(
                    width: 18,
                    height: 7.33,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.33),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // App Bar with Back Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back arrow button
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
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
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1E293B),
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Index Penyakit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
                // Empty container to balance the layout
                SizedBox(width: 36),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(4, 0),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Header Text
                  Positioned(
                    left: 59,
                    top: 45,
                    child: SizedBox(
                      width: 318,
                      child: const Text(
                        'Prediksi Dini Resiko Kesehatan Bunda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ),
                  ),
                  
                  // Add New Data Button
                  Positioned(
                    left: 29,
                    top: 85,
                    right: 29,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddDataPenyakit(),
                          ),
                        );
                        
                        // Refresh data if needed
                        if (result == true) {
                          _loadData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4DBAFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Tambah Data Baru',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Data List with Card Style
                  Positioned(
                    left: 29,
                    top: 145, // Adjusted to make room for the button
                    right: 29,
                    bottom: 100,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF9F9F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: FutureBuilder(
                          future: _data,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final data = snapshot.data as List<dynamic>;
                              return ListView.separated(
                                itemCount: data.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: const Color(0xFFD9D9D9),
                                  thickness: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final item = data[index];
                                  return _buildPredictionItem(item);
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error, color: Color(0xFFFC5C9C), size: 64),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Error: ${snapshot.error}",
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(color: Color(0xFF4DBAFF)),
                            );
                          },
                        ),
                      ),
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

  Widget _buildPredictionItem(dynamic item) {
    final hasdiabetes = item['diabetes_prediction'] == '1' || item['diabetes_prediction'] == 1;
    final hashypertension = item['hypertension_prediction'] == '1' || item['hypertension_prediction'] == 1;
    final hasmaternalrisk = item['maternal_health_prediction'] == 'high risk' || 
                            item['maternal_health_prediction'] == 'High Risk';
    
    Color cardColor = const Color(0xFFFDEFEE);
    if (hasdiabetes || hashypertension || hasmaternalrisk) {
      cardColor = const Color(0xFFFCEFEE);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['nama'] ?? 'No Name',
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: hasdiabetes || hashypertension || hasmaternalrisk
                      ? const Color(0xFFFC5C9C)
                      : const Color(0xFF4DBAFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  hasdiabetes || hashypertension || hasmaternalrisk ? 'Berisiko' : 'Sehat',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDataRow("Umur", item['age']?.toString() ?? 'N/A'),
          _buildDataRow("BMI", item['bmi']?.toString() ?? 'N/A'),
          _buildDataRow("Tekanan Darah", "${item['systolic_bp'] ?? 'N/A'}/${item['diastolic_bp'] ?? 'N/A'} mmHg"),
          _buildDataRow("Gula Darah", item['bs']?.toString() ?? 'N/A'),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildPredictionBadge("Diabetes", hasdiabetes),
              const SizedBox(width: 8),
              _buildPredictionBadge("Hipertensi", hashypertension),
              const SizedBox(width: 8),
              _buildPredictionBadge("Risiko Maternal", hasmaternalrisk),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionBadge(String label, bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPositive ? const Color(0xFFFCCCE2) : const Color(0xFFAEE2FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPositive ? const Color(0xFFFC5C9C) : const Color(0xFF4DBAFF),
          fontSize: 12,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
