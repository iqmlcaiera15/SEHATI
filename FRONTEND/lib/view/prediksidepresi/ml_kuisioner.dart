import 'package:flutter/material.dart';
import 'package:Sehati/view/prediksidepresi/depression_result.dart';
import 'package:Sehati/view/prediksidepresi/kuisioner_epds.dart';
import 'package:Sehati/services/api/api_service_depresi.dart';

class DepressionQuestionnaire extends StatefulWidget {
  const DepressionQuestionnaire({Key? key}) : super(key: key);

  @override
  State<DepressionQuestionnaire> createState() => _DepressionQuestionnaireState();
}

class _DepressionQuestionnaireState extends State<DepressionQuestionnaire> {
  final DepressionService _service = DepressionService();
  bool _isLoading = false;
  
  // Track the current question index
  int _currentQuestionIndex = 0;
  
  // Age input controller
  final TextEditingController _ageController = TextEditingController();
  
  // Define answers for each question
  final Map<String, String?> _answers = {
    'umur': null,
    'merasa_sedih': null,
    'mudah_tersinggung': null,
    'masalah_tidur': null,
    'masalah_fokus': null,
    'pola_makan': null,
    'merasa_bersalah': null,
    'suicide_attempt': null,
  };
  
  // Define question texts
  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'Umur Anda',
      'type': 'age',
      'key': 'umur',
    },
    {
      'title': 'Dalam 7 hari terakhir, apakah Anda merasa sedih atau murung?',
      'key': 'merasa_sedih',
      'options': [
        {'value': 'Tidak', 'text': 'Tidak'},
        {'value': 'Kadang-kadang', 'text': 'Kadang-kadang'},
        {'value': 'Ya', 'text': 'Ya'},
      ],
    },
    {
      'title': 'Dalam 7 hari terakhir, apakah Anda mudah tersinggung atau marah terhadap pasangan atau keluarga?',
      'key': 'mudah_tersinggung',
      'options': [
        {'value': 'Tidak', 'text': 'Tidak'},
        {'value': 'Kadang-kadang', 'text': 'Kadang-kadang'},
        {'value': 'Ya', 'text': 'Ya'},
      ],
    },
    {
      'title': 'Dalam 7 hari terakhir, apakah Anda mengalami masalah tidur (sulit tidur, sering terbangun, atau terlalu banyak tidur)?',
      'key': 'masalah_tidur',
      'options': [
        {'value': 'Tidak', 'text': 'Tidak'},
        {'value': 'Dua hari dalam seminggu/lebih', 'text': 'Dua hari dalam seminggu/lebih'},
        {'value': 'Ya', 'text': 'Ya, hampir setiap hari'},
      ],
    },
    {
      'title': 'Dalam 7 hari terakhir, apakah Anda kesulitan berkonsentrasi atau fokus?',
      'key': 'masalah_fokus',
      'options': [
        {'value': 'Tidak', 'text': 'Tidak'},
        {'value': 'Ya', 'text': 'Ya'},
        {'value': 'Sering', 'text': 'Sangat Sering'},
      ],
    },
    {
      'title': 'Dalam 7 hari terakhir, apakah pola makan Anda berubah (tidak nafsu makan atau makan berlebihan)?',
      'key': 'pola_makan',
      'options': [
        {'value': 'Tidak sama sekali', 'text': 'Tidak sama sekali'},
        {'value': 'Kadang-kadang', 'text': 'Kadang-kadang'},
        {'value': 'Ya', 'text': 'Ya, hampir setiap hari'},
      ],
    },
    {
      'title': 'Dalam 7 hari terakhir, apakah Anda merasa bersalah atau tidak berharga?',
      'key': 'merasa_bersalah',
      'options': [
        {'value': 'Tidak', 'text': 'Tidak'},
        {'value': 'Mungkin', 'text': 'Mungkin, sesekali'},
        {'value': 'Ya', 'text': 'Ya, sering'},
      ],
    },
    {
      'title': 'Dalam 7 hari terakhir, apakah Anda memiliki pikiran untuk menyakiti diri sendiri?',
      'key': 'suicide_attempt',
      'options': [
        {'value': 'Tidak', 'text': 'Tidak sama sekali'},
        {'value': 'Tidak ingin menjawab', 'text': 'Tidak ingin menjawab'},
        {'value': 'Ya', 'text': 'Ya'},
      ],
    },
  ];

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _handleNextQuestion() {
    // Validate if the current question is answered
    String currentKey = _questions[_currentQuestionIndex]['key'];
    
    if (_currentQuestionIndex == 0) {
      // For age question
      if (_ageController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silahkan masukkan umur Anda')),
        );
        return;
      }
      int age = int.parse(_ageController.text);
      if (age < 1 || age > 120) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silahkan masukkan umur yang valid (1-120)')),
        );
        return;
      }
      _answers[currentKey] = _ageController.text;
    } else {
      // For option-based questions
      if (_answers[currentKey] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silahkan pilih salah satu jawaban')),
        );
        return;
      }
    }
    
    // If we're at the last question, submit the answers
    if (_currentQuestionIndex == _questions.length - 1) {
      _submitQuestionnaire();
    } else {
      // Otherwise, move to the next question
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _handlePreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  // Fungsi untuk mengevaluasi rule-based risk assessment
  bool _isHighRisk() {
    // Rule 1: Jika pengguna memiliki pikiran menyakiti diri sendiri (suicide_attempt = Ya)
    if (_answers['suicide_attempt'] == 'Ya') {
      return true;
    }
    
    // Rule 2: Jika semua jawaban adalah "Ya" atau nilai tertinggi
    int highRiskAnswerCount = 0;
    
    // Hitung berapa pertanyaan yang dijawab dengan risiko tinggi
    if (_answers['merasa_sedih'] == 'Ya') highRiskAnswerCount++;
    if (_answers['mudah_tersinggung'] == 'Ya') highRiskAnswerCount++;
    if (_answers['masalah_tidur'] == 'Ya') highRiskAnswerCount++;
    if (_answers['masalah_fokus'] == 'Ya') highRiskAnswerCount++;
    if (_answers['pola_makan'] == 'Ya') highRiskAnswerCount++;
    if (_answers['merasa_bersalah'] == 'Ya') highRiskAnswerCount++;
    
    // Jika 5 atau lebih jawaban menunjukkan risiko tinggi (dari 6 pertanyaan mood)
    if (highRiskAnswerCount >= 5) {
      return true;
    }
    
    return false;
  }

  Future<void> _submitQuestionnaire() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    // Prepare the data for the API
    final data = {
      'umur': int.parse(_answers['umur']!),
      'merasa_sedih': _answers['merasa_sedih'],
      'mudah_tersinggung': _answers['mudah_tersinggung'],
      'masalah_tidur': _answers['masalah_tidur'],
      'masalah_fokus': _answers['masalah_fokus'],
      'pola_makan': _answers['pola_makan'],
      'merasa_bersalah': _answers['merasa_bersalah'],
      'suicide_attempt': _answers['suicide_attempt'],
    };
    
    // Check if high risk based on answers before submitting to API
    bool highRisk = _isHighRisk();
    
    // Submit the data
    final response = await _service.submitDepressionQuestionnaire(data);
    
    // Handle the response based on the prediction result
    if (response['status'] == 'success') {
      final prediksi = response['data']['hasil_prediksi'];
      
      // Simpan ID hasil prediksi (untuk foreign key)
      final int prediksiDepresiId = response['data']['id'] ?? 0; // ID dari hasil kuesioner depresi
      
      // If depression is detected by ML or high risk rules are triggered
      if (prediksi == 1 || highRisk) {
        // Go to EPDS questionnaire
        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EpdsQuestionnaire(
              prediksiDepresiId: prediksiDepresiId, // Meneruskan ID sebagai foreign key
            ),
          ),
        );
      } else {
        // If no depression detected, show the result
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DepressionResult(
              isDepressed: false,
              data: response['data'],
            ),
          ),
        );
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response["message"] ?? "Terjadi kesalahan"}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  Widget _buildAgeInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: TextFormField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Umur',
          hintText: 'Masukkan umur Anda',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4DBAFF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildOptions(List<Map<String, dynamic>> options, String questionKey) {
    return Column(
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: InkWell(
            onTap: () {
              setState(() {
                _answers[questionKey] = option['value'] as String;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _answers[questionKey] == option['value']
                    ? const Color(0xFF4DBAFF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                option['text'].toString(),
                style: TextStyle(
                  color: _answers[questionKey] == option['value']
                      ? Colors.white
                      : const Color(0xFF1E293B),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () {
            if (_currentQuestionIndex > 0) {
              _handlePreviousQuestion();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Skrining Depresi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4DBAFF),
              ),
            )
          : Column(
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pertanyaan ${_currentQuestionIndex + 1}/${_questions.length}',
                            style: const TextStyle(
                              color: Color(0xFF4C617F),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${((_currentQuestionIndex + 1) / _questions.length * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFF4DBAFF),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / _questions.length,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4DBAFF)),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                
                // Question card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      currentQuestion['title'],
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                
                // Input or options depending on question type
                Expanded(
                  child: SingleChildScrollView(
                    child: currentQuestion['type'] == 'age'
                        ? _buildAgeInput()
                        : _buildOptions(
                            List<Map<String, dynamic>>.from(currentQuestion['options']),
                            currentQuestion['key'],
                          ),
                  ),
                ),
                
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Back button (only show if not the first question)
                      if (_currentQuestionIndex > 0)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handlePreviousQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE5E7EB),
                              foregroundColor: const Color(0xFF4C617F),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Kembali',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      
                      // Space between buttons if both are shown
                      if (_currentQuestionIndex > 0)
                        const SizedBox(width: 16),
                      
                      // Next or Submit button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleNextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DBAFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? 'Selesai'
                                : 'Lanjut',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}