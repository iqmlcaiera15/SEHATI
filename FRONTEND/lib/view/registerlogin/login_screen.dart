import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Sehati/providers/auth_provider.dart';
import 'package:Sehati/view/registerlogin/register_screen.dart';
import 'package:Sehati/view/homeprofile/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Clear any previous errors when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).clearErrors();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email validation regex
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Method to show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Color(0xFFFC5C9C),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Color(0xFF4C617F),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF4DBAFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SafeArea(
            child: Stack(
              children: [
                // Background with gradient - matching register screen
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Color(0xFFAEE2FF).withOpacity(0.3),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
                
                // Main content
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo and Welcome Text
                        Center(
                          child: Column(
                            children: [
                              // App logo with heart icon
                                Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF4DBAFF).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect( // Untuk memastikan gambar juga memiliki border radius
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/sehati_logo.png', // 
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover, // Sesuaikan sesuai kebutuhan tampilan logo
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Selamat Datang Kembali',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Masuk untuk melanjutkan perjalanan kesehatan Anda bersama Sehati',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF4C617F),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 32),
                            ],
                          ),
                        ),
                        
                        // Error message
                        if (authProvider.error != null)
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            margin: const EdgeInsets.only(bottom: 16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFCEFEE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFFC5C9C).withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Color(0xFFFC5C9C)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.error!,
                                    style: TextStyle(color: Color(0xFFFC5C9C)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Login Information
                        Text(
                          'Informasi Akun',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Email field
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!_isValidEmail(value)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        
                        // Password field
                        _buildInputField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Color(0xFF4C617F),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        
                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Handle forgot password
                              // TODO: Implement forgot password functionality
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF4DBAFF),
                              padding: EdgeInsets.only(top: 4, bottom: 8),
                            ),
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 32),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () async {
                                    // Clear previous errors
                                    authProvider.clearErrors();
                                    
                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        final success = await authProvider.login(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                        
                                        if (success && mounted) {
                                          // Successfully logged in, navigate to home screen
                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (_) => const HomePage(),
                                            ),
                                            (route) => false, // Remove all routes from stack
                                          );
                                        } else if (!success && mounted) {
                                          // Login failed - show specific error dialog
                                          _showErrorDialog(
                                            'Login Gagal',
                                            'Email atau password yang Anda masukkan salah. Silakan periksa kembali kredensial Anda.',
                                          );
                                        }
                                      } catch (e) {
                                        // Handle unexpected errors
                                        if (mounted) {
                                          _showErrorDialog(
                                            'Terjadi Kesalahan',
                                            'Terjadi kesalahan saat mencoba masuk. Silakan coba lagi.',
                                          );
                                        }
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF4DBAFF),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 24, 
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        // Register link
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Belum punya akun?',
                                  style: TextStyle(
                                    color: Color(0xFF4C617F),
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Daftar',
                                    style: TextStyle(
                                      color: Color(0xFF4DBAFF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
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
        },
      ),
    );
  }
  
  // Reusing the same input field builder from RegisterScreen for consistency
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Color(0xFF4C617F),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Color(0xFF4DBAFF)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
        ),
        validator: validator,
      ),
    );
  }
}