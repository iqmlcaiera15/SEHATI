import 'package:flutter/material.dart';

class NotificationAsupanAir {
  static void showReminderSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("💧 Pengingat: 5 menit lagi waktunya minum air, Bunda!"),
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 5),
      ),
    );
  }

  static void showErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal mencatat minum ke server'),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void showTargetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.emoji_emotions_rounded, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text('Yeay! 🎉',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 8),
              Text(
                'Bunda telah mencapai target 8 gelas hari ini 😊',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
