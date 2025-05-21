import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'package:Sehati/view/homeprofile/home.dart'; 
import 'package:Sehati/view/registerlogin/login_screen.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // WAJIB untuk inisialisasi plugin
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'JWT Auth Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            home: authProvider.isAuthenticated
                ? const HomePage()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}