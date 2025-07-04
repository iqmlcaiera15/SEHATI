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
      'title': ' Saya mampu tertawa dan merasakan hal-hal yang menyenangkan',
      'options': [
        {'value': 0, 'text': 'Sebanyak yang saya bisa'},
        {'value': 1, 'text': 'Tidak terlalu banyak'},
        {'value': 2, 'text': 'Tidak banyak'},
        {'value': 3, 'text': 'Tidak sama sekali'},
      ],
    },
    {
      'title': 'Saya melihat segala sesuatunya ke depan sangat menyenangkan',
      'options': [
        {'value': 0, 'text': 'Sebanyak sebelumnya'},
        {'value': 1, 'text': 'Agak sedikit kurang dibandingkan dengan sebelumnya'},
        {'value': 2, 'text': 'Kurang dibandingkan dengan sebelumnya'},
        {'value': 3, 'text': 'Tidak pernah sama sekali'},
      ],
    },
    {
      'title': 'Saya menyalahkan diri saya sendiri saat sesuatu terjadi tidak sebagaimana mestinya',
      'options': [
        {'value': 0, 'text': 'Tidak pernah sama sekali'},
        {'value': 1, 'text': 'Tidak terlalu sering'},
        {'value': 2, 'text': 'Ya, kadang-kadang'},
        {'value': 3, 'text': 'Ya, setiap saat'},
      ],
    },
    {
      'title': 'Saya merasa cemas atau merasa khawatir tanpa alasan yang jelas',
      'options': [
        {'value': 0, 'text': 'Tidak pernah sama sekali'},
        {'value': 1, 'text': 'Hampir tidak pernah'},
        {'value': 2, 'text': 'Ya, kadang-kadang'},
        {'value': 3, 'text': 'Ya, sangat sering'},
      ],
    },
    {
      'title': 'Saya merasa takut atau panik tanpa alasan yang jelas',
      'options': [
        {'value': 0, 'text': 'Tidak pernah sama sekali'},
        {'value': 1, 'text': 'Tidak terlalu sering'},
        {'value': 2, 'text': 'Ya, kadang-kadang'},
        {'value': 3, 'text': 'Ya, cukup sering'},
      ],
    },
    {
      'title': 'Segala sesuatunya terasa sulit untuk dikerjakan',
      'options': [
        {'value': 0, 'text': 'Tidak pernah, saya mampu mengerjakan segala sesuatu dengan baik'},
        {'value': 1, 'text': 'Tidak terlalu, sebagian besar berhasil saya tangani'},
        {'value': 2, 'text': 'Ya, kadang-kadang saya tidak mampu menangani seperti biasanya'},
        {'value': 3, 'text': 'Ya, hampir setiap saat saya tidak mampu menanganinya'},
      ],
    },
    {
      'title': 'Saya merasa tidak bahagia sehingga mengalami kesulitan untuk tidur',
      'options': [
        {'value': 0, 'text': 'Tidak pernah sama sekali'},
        {'value': 1, 'text': 'Tidak terlalu sering'},
        {'value': 2, 'text': 'Ya, kadang-kadang'},
        {'value': 3, 'text': 'Ya, setiap saat'},
      ],
    },
    {
      'title': 'Saya merasa sedih dan merasa diri saya menyedihkan',
      'options': [
        {'value': 0, 'text': 'Tidak pernah sama sekali'},
        {'value': 1, 'text': 'Tidak terlalu sering'},
        {'value': 2, 'text': 'Ya, cukup sering'},
        {'value': 3, 'text': 'Ya, setiap saat'},
      ],
    },
    {
      'title': ' Saya merasa tidak bahagia sehingga menyebabkan saya menangis',
      'options': [
        {'value': 0, 'text': 'Tidak pernah sama sekali'},
        {'value': 1, 'text': 'Di saat tertentu saja'},
        {'value': 2, 'text': 'Ya, cukup sering'},
        {'value': 3, 'text': 'Ya, setiap saat'},
      ],
    },
    {
      'title': 'Muncul pikiran untuk menyakiti diri saya sendiri',
      'options': [
        {'value': 0, 'text': 'Tidak pernah sama sekali'},
        {'value': 1, 'text': 'Jarang sekali'},
        {'value': 2, 'text': 'Kadang-kadang'},
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
