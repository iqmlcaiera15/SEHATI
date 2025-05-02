import 'package:flutter/material.dart';
import 'dart:async';
import 'package:Sehati/models/kick_counter_model.dart';
import 'package:Sehati/services/api/api_service_kickcounter.dart';

class KickCounterSession extends StatefulWidget {
  const KickCounterSession({Key? key}) : super(key: key);

  @override
  State<KickCounterSession> createState() => _KickCounterSessionState();
}

class _KickCounterSessionState extends State<KickCounterSession> {
  int _kickCount = 0;
  int _elapsedSeconds = 0;
  bool _isActive = false;
  Timer? _timer;
  DateTime? _startTime;
  
  void _startTimer() {
    setState(() {
      _isActive = true;
      _startTime = DateTime.now();
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }
  
  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _isActive = false;
      });
    }
  }
  
  void _resetSession() {
    _stopTimer();
    setState(() {
      _kickCount = 0;
      _elapsedSeconds = 0;
      _startTime = null;
    });
  }
  
  void _recordKick() {
    if (!_isActive) {
      _startTimer();
    }
    
    setState(() {
      _kickCount++;
    });
    
    // If 10 kicks are recorded, show a completion dialog
    if (_kickCount == 10) {
      _stopTimer();
      _showCompletionDialog();
    }
  }
  
  Future<void> _saveSession() async {
    try {
      if (_startTime == null) return;
      
      final kickCounter = KickCounter(
        kickCount: _kickCount,
        recordedAt: _startTime!,
        duration: (_elapsedSeconds ~/ 60) > 0 ? (_elapsedSeconds ~/ 60) : 1,
      );
      
      await ApiServiceKickCounter.saveKickCounterData(kickCounter);
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving session: $e')),
      );
    }
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Selamat!'),
        content: Text(
          'Anda telah mencatat 10 tendangan bayi dalam ${_formatDuration(_elapsedSeconds)}. Ini menunjukkan bayi Anda aktif dan sehat!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveSession();
            },
            child: const Text('Simpan & Keluar'),
          ),
        ],
      ),
    );
  }
  
  void _showExitConfirmationDialog() {
    if (_kickCount > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Simpan sesi ini?'),
          content: const Text(
            'Anda memiliki data tendangan yang belum disimpan. Apakah Anda ingin menyimpannya?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(false);
              },
              child: const Text('Buang'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveSession();
              },
              child: const Text('Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DBAFF),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop(false);
    }
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes menit ${remainingSeconds} detik';
  }
  
  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_kickCount > 0) {
          _showExitConfirmationDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text(
            'Hitung Tendangan Bayi',
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
            icon: const Icon(Icons.close, color: Color(0xFF1E293B)),
            onPressed: () {
              if (_kickCount > 0) {
                _showExitConfirmationDialog();
              } else {
                Navigator.of(context).pop(false);
              }
            },
          ),
          actions: [
            if (_kickCount > 0)
              IconButton(
                icon: const Icon(Icons.check, color: Color(0xFF4DBAFF)),
                onPressed: _saveSession,
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Timer Display
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    children: [
                      const Text(
                        'Durasi',
                        style: TextStyle(
                          color: Color(0xFF4C617F),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(_elapsedSeconds),
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _elapsedSeconds < 7200 ? _elapsedSeconds / 7200 : 1.0, // 2 hours = 7200 seconds
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4DBAFF)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: 10 tendangan dalam 2 jam',
                        style: TextStyle(
                          color: const Color(0xFF4C617F),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (_elapsedSeconds >= 7200)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC5C9C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFC5C9C)),
                          ),
                          child: const Text(
                            'Waktu 2 jam telah berlalu. Jika tendangan kurang dari 10, konsultasikan dengan dokter.',
                            style: TextStyle(
                              color: Color(0xFFFC5C9C),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Kick Count Display
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    children: [
                      const Text(
                        'Jumlah Tendangan',
                        style: TextStyle(
                          color: Color(0xFF4C617F),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_kickCount',
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: List.generate(
                          10,
                          (index) => Expanded(
                            child: Container(
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: index < _kickCount
                                    ? const Color(0xFF4DBAFF)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Kick Button
                Container(
                  margin: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _recordKick,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4DBAFF), Color(0xFF2D9CFF)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4DBAFF).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.touch_app,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ketuk setiap kali bayi menendang',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Reset Button
                if (_kickCount > 0 || _elapsedSeconds > 0)
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Mulai Ulang?'),
                          content: const Text(
                            'Apakah Anda ingin memulai sesi baru? Data saat ini akan hilang.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _resetSession();
                              },
                              child: const Text('Mulai Ulang'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4DBAFF),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, color: Color(0xFF4C617F)),
                    label: const Text(
                      'Mulai Ulang Sesi',
                      style: TextStyle(color: Color(0xFF4C617F)),
                    ),
                  ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}