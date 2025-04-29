import 'package:flutter/material.dart';
// import 'package:Sehati/view/deteksipenyakit/index_penyakit.dart';
import 'package:Sehati/view/homeprofile/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehati App',
      home: SehatiApp(), // ← Ini halaman yang muncul pertama
      debugShowCheckedModeBanner: false,
    );
  }
}
