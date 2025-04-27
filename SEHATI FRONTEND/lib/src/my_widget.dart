import 'package:flutter/material.dart';

class PrimaryLargeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  // Tambahkan parameter untuk menerima style dinamis
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double width;
  final double height;

  const PrimaryLargeButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.purple, // Warna default
    this.textColor = Colors.white,       // Warna default
    this.fontSize = 18.0,                // Font size default
    this.width = 144.0,                  // Lebar default
    this.height = 60.0,                  // Tinggi default
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height), // Ukuran dinamis
        backgroundColor: backgroundColor, // Warna dinamis
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Sudut melengkung tetap
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,              // Warna teks dinamis
          fontSize: fontSize,            // Ukuran font dinamis
          fontWeight: FontWeight.bold,   // Tetap bold
        ),
      ),
    );
  }
}

class PrimaryMediumButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  // Tambahkan parameter untuk menerima style dinamis
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double width;
  final double height;

  const PrimaryMediumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.purple, // Warna default
    this.textColor = Colors.white,       // Warna default
    this.fontSize = 16.0,                // Font size default
    this.width = 180.0,                  // Lebar default
    this.height = 50.0,                  // Tinggi default
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height), // Ukuran dinamis
        backgroundColor: backgroundColor, // Warna dinamis
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Sudut melengkung tetap
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,              // Warna teks dinamis
          fontSize: fontSize,            // Ukuran font dinamis
          fontWeight: FontWeight.bold,   // Tetap bold
        ),
      ),
    );
  }
}

class PrimarySmallButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  // Tambahkan parameter untuk menerima style dinamis
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double width;
  final double height;

  const PrimarySmallButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.purple, // Warna default
    this.textColor = Colors.white,       // Warna default
    this.fontSize = 14.0,                // Font size default
    this.width = 140.0,                  // Lebar default
    this.height = 40.0,                  // Tinggi default
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height), // Ukuran dinamis
        backgroundColor: backgroundColor, // Warna dinamis
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Sudut melengkung tetap
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,              // Warna teks dinamis
          fontSize: fontSize,            // Ukuran font dinamis
          fontWeight: FontWeight.bold,   // Tetap bold
        ),
      ),
    );
  }
}
