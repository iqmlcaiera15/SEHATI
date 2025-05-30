import 'package:flutter/material.dart';
import 'package:Sehati/view/prediksidepresi/depression_result.dart';
import 'package:Sehati/services/api/api_service_depresi.dart';

class EpdsQuestionnaire extends StatefulWidget {
  final int prediksiDepresiId; // Add this field to receive the ID
  
  const EpdsQuestionnaire({
    Key? key, 
    required this.prediksiDepresiId, // Make it required
  }) : super(key: key);

  @override
  State<EpdsQuestionnaire> createState() => _EpdsQuestionnaireState();
}

class _EpdsQuestionnaireState extends State<EpdsQuestionnaire> {
  final DepressionService _service = DepressionService();
  bool _isLoading = false;
  
  // Track the current question index
  int _currentQuestionIndex = 0;
  
  // Store answers for all questions (0-3 scale)
  final List<int?> _answers = List.filled(10, null);
  
  // EPDS questions
  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'Saya dapat tertawa dan melihat sisi terang dari segala hal',
      'options': [
        {'value': 0, 'text': 'Sebanyak yang selalu saya lakukan'},
        {'value': 1, 'text': 'Tidak terlalu banyak sekarang'},
        {'value': 2, 'text': 'Sangat jarang sekarang'},
        {'value': 3, 'text': 'Tidak sama sekali'},
      ],
    },
    {
      'title': 'Saya menantikan segala hal dengan senang',
      'options': [
        {'value': 0, 'text': 'Sebanyak yang selalu saya lakukan'},
        {'value': 1, 'text': 'Agak berkurang dari yang biasanya saya lakukan'},
        {'value': 2, 'text': 'Jauh lebih sedikit dari yang biasanya saya lakukan'},
        {'value': 3, 'text': 'Hampir tidak pernah'},
      ],
    },
    {
      'title': 'Saya menyalahkan diri sendiri secara berlebihan jika ada hal yang tidak beres',
      'options': [
        {'value': 0, 'text': 'Tidak, sama sekali tidak'},
        {'value': 1, 'text': 'Tidak terlalu sering'},
        {'value': 2, 'text': 'Ya, kadang-kadang'},
        {'value': 3, 'text': 'Ya, sangat sering'},
      ],
    },
    {
      'title': 'Saya merasa cemas atau khawatir tanpa alasan yang jelas',
      'options': [
        {'value': 0, 'text': 'Tidak, sama sekali tidak'},
        {'value': 1, 'text': 'Hampir tidak pernah'},
        {'value': 2, 'text': 'Ya, kadang-kadang'},
        {'value': 3, 'text': 'Ya, sangat sering'},
      ],
    },
    {
      'title': 'Saya merasa takut atau panik tanpa alasan yang jelas',
      'options': [
        {'value': 0, 'text': 'Tidak, sama sekali tidak'},
        {'value': 1, 'text': 'Hampir tidak pernah'},
        {'value': 2, 'text': 'Ya, kadang-kadang'},
        {'value': 3, 'text': 'Ya, cukup sering'},
      ],
    },
    {
      'title': 'Banyak hal membuat saya kewalahan',
      'options': [
        {'value': 0, 'text': 'Tidak, saya mengatasi semuanya dengan baik seperti biasa'},
        {'value': 1, 'text': 'Tidak, biasanya saya bisa mengatasi semuanya dengan baik'},
        {'value': 2, 'text': 'Ya, kadang-kadang saya tidak bisa mengatasi semuanya seperti biasa'},
        {'value': 3, 'text': 'Ya, sering kali saya tidak dapat mengatasi apapun'},
      ],
    },
    {
      'title': 'Saya merasa sedih hingga sulit tidur',
      'options': [
        {'value': 0, 'text': 'Tidak, sama sekali tidak'},
        {'value': 1, 'text': 'Tidak terlalu sering'},
        {'value': 2, 'text': 'Ya, kadang-kadang'},
        {'value': 3, 'text': 'Ya, sangat sering'},
      ],
    },
    {
      'title': 'Saya merasa sedih atau menyedihkan',
      'options': [
        {'value': 0, 'text': 'Tidak, sama sekali tidak'},
        {'value': 1, 'text': 'Tidak terlalu sering'},
        {'value': 2, 'text': 'Ya, cukup sering'},
        {'value': 3, 'text': 'Ya, hampir sepanjang waktu'},
      ],
    },
    {
      'title': 'Saya merasa sangat sedih hingga menangis',
      'options': [
        {'value': 0, 'text': 'Tidak, sama sekali tidak'},
        {'value': 1, 'text': 'Hanya sesekali'},
        {'value': 2, 'text': 'Ya, cukup sering'},
        {'value': 3, 'text': 'Ya, hampir sepanjang waktu'},
      ],
    },
    {
      'title': 'Pikiran untuk menyakiti diri sendiri pernah terlintas dalam pikiran saya',
      'options': [
        {'value': 0, 'text': 'Sama sekali tidak pernah'},
        {'value': 1, 'text': 'Hampir tidak pernah'},
        {'value': 2, 'text': 'Ya, kadang-kadang'},
        {'value': 3, 'text': 'Ya, cukup sering'},
      ],
    },
  ];

  void _handleNextQuestion() {
    // Validate if the current question is answered
    if (_answers[_currentQuestionIndex] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silahkan pilih salah satu jawaban')),
      );
      return;
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

  Future<void> _submitQuestionnaire() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Memproses jawaban untuk dikirim ke API
    final Map<String, dynamic> finalAnswers = {
      'prediksi_depresi_id': widget.prediksiDepresiId,
    };
    
    // Menambahkan semua jawaban ke dalam map
    for (int i = 0; i < _answers.length; i++) {
      finalAnswers['q${i + 1}'] = _answers[i];
    }
    
    // Panggil API dengan jawaban EPDS dan ID prediksi depresi
    final response = await _service.submitEpdsQuestionnaire(finalAnswers);
    
    if (response['status'] == 'success') {
      // Extract the data more safely
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final prediksi = data['hasil_prediksi'];
      final skorEpds = data['score'] ?? 0;
      
      if (!mounted) return;
      
      // Navigasi ke halaman hasil dengan explicitly passing the score
      Navigator.push(
        context,
        MaterialPageRoute(
             builder: (context) {
              print('Data being sent to DepressionResult: isDepressed=$prediksi, score=$skorEpds, data=$data');
              return DepressionResult(
                isDepressed: prediksi == 1,
                data: data,
                score: skorEpds is int ? skorEpds : int.tryParse(skorEpds.toString()) ?? 0,
              );
             }
        ),
      );
    } else {
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

  Widget _buildOptions(List<Map<String, dynamic>> options, int questionIndex) {
    return Column(
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: InkWell(
            onTap: () {
              setState(() {
                _answers[questionIndex] = option['value'] as int;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _answers[questionIndex] == option['value']
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
                  color: _answers[questionIndex] == option['value']
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
          'Kuesioner EPDS',
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
                // Information text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Kuesioner ini digunakan untuk mengidentifikasi tingkat depresi postpartum. Silahkan jawab dengan jujur sesuai dengan kondisi Anda dalam 7 hari terakhir.',
                    style: TextStyle(
                      color: Color(0xFF4C617F),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                
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
                
                // Options
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildOptions(
                      List<Map<String, dynamic>>.from(currentQuestion['options']),
                      _currentQuestionIndex,
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