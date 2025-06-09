import 'package:Sehati/view/homeprofile/dataprep.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Sehati/providers/auth_provider.dart';
import 'package:Sehati/view/registerlogin/login_screen.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).clearErrors();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  // Email validation regex
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SafeArea(
            child: Stack(
              children: [
                // Background with gradient
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
                                'Selamat Datang di Sehati',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Buat akun untuk memantau kesehatan kehamilan Anda',
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

                        // Registration form fields
                        Text(
                          'Informasi Personal',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Name field (dari main)
                        _buildInputField(
                          controller: _nameController,
                          label: 'Nama Lengkap',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Email field (dari main)
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
                        SizedBox(height: 24),

                        Text(
                          'Keamanan',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Password field (dari main)
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
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Confirm Password field (dari main)
                        _buildInputField(
                          controller: _passwordConfirmationController,
                          label: 'Konfirmasi Password',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Color(0xFF4C617F),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password tidak boleh kosong';
                            }
                            if (value != _passwordController.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32),

                        // Register Button (logika navigasi dari iqmal2, styling dari main)
                        SizedBox(
                          width: double.infinity,
                          height: 55, // Menggunakan tinggi dari main branch
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () async {
                                    // Clear previous errors
                                    authProvider.clearErrors();

                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        final success = await authProvider.register(
                                          _nameController.text,
                                          _emailController.text,
                                          _passwordController.text,
                                          _passwordConfirmationController.text,
                                        );

                                        if (success && mounted) {
                                          // Successfully registered, navigate to DataFormPage (dari iqmal2)
                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (_) => DataFormPage(), // Tujuan navigasi dari iqmal2
                                            ),
                                            (route) => false, // Remove all routes from stack
                                          );
                                        }
                                      } catch (e) {
                                        // Error handling is managed by the provider
                                        // AuthProvider will set the error property
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom( // Styling dari main
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF4DBAFF),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: authProvider.isLoading // Indikator loading dari main
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        // Login link (dari main)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sudah punya akun?',
                                  style: TextStyle(
                                    color: Color(0xFF4C617F),
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Replace current screen with login screen
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Masuk',
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

                        SizedBox(height: 30),
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

  // Helper method _buildInputField (dari main)
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