import 'package:flutter/material.dart';
import 'package:Sehati/view/deteksipenyakit/index_penyakit.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehati App',
      home: IndexPenyakit(), // ← Ini halaman yang muncul pertama
      debugShowCheckedModeBanner: false,
    );
  }
}
