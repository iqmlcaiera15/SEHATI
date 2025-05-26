import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Sehati/view/homeprofile/selecticon.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DataFormPage extends StatefulWidget {
  @override
  _DataFormPageState createState() => _DataFormPageState();
}

class _DataFormPageState extends State<DataFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = FlutterSecureStorage(); // Secure storage instance
  bool _isLoading = false;
  
  // Controller untuk setiap field
  TextEditingController tanggalLahirController = TextEditingController();
  TextEditingController usiaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController nomorTeleponController = TextEditingController();
  TextEditingController pendidikanTerakhirController = TextEditingController();
  TextEditingController pekerjaanController = TextEditingController();
  TextEditingController golonganDarahController = TextEditingController();
  TextEditingController namaSuamiController = TextEditingController();
  TextEditingController teleponSuamiController = TextEditingController();
  TextEditingController usiaSuamiController = TextEditingController();
  TextEditingController pekerjaanSuamiController = TextEditingController();

  // Method to get JWT token from secure storage
  Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  // Fungsi untuk submit data ke API
  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the JWT token from secure storage
        final token = await getJwtToken();
        
        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Anda belum login. Silakan login terlebih dahulu.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        final response = await http.post(
          Uri.parse('https://sehatiapp-production.up.railway.app/api/isidata'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'tanggal_lahir': tanggalLahirController.text,
            'usia': usiaController.text,
            'alamat': alamatController.text,
            'nomor_telepon': nomorTeleponController.text,
            'pendidikan_terakhir': pendidikanTerakhirController.text,
            'pekerjaan': pekerjaanController.text,
            'golongan_darah': golonganDarahController.text,
            'nama_suami': namaSuamiController.text,
            'telepon_suami': teleponSuamiController.text,
            'usia_suami': usiaSuamiController.text,
            'pekerjaan_suami': pekerjaanSuamiController.text,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          // Jika submit berhasil, navigasi ke HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SelectProfilePage()),
          );
          
          // Tampilkan pesan sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data berhasil disimpan')),
          );
        } else if (response.statusCode == 422) {
          // Handle validation errors
          try {
            Map<String, dynamic> responseBody = json.decode(response.body);
            Map<String, dynamic> errors = responseBody['errors'] ?? {};
            
            // Create a formatted error message
            String errorMessage = 'Validasi gagal:\n';
            errors.forEach((field, messages) {
              if (messages is List) {
                errorMessage += '- ${messages.join(', ')}\n';
              } else {
                errorMessage += '- $messages\n';
              }
            });
            
            // Show validation errors
            _showValidationErrorDialog(errorMessage);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error parsing validation errors: $e')),
            );
          }
        } else {
          // Handle other errors
          String errorMsg = 'Gagal mengirim data';
          try {
            Map<String, dynamic> responseData = json.decode(response.body);
            errorMsg = responseData['message'] ?? errorMsg;
          } catch (e) {
            errorMsg = 'Server error: ${response.statusCode}';
            print('Response body: ${response.body}');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Helper method to show validation errors in a dialog
  void _showValidationErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Validasi Gagal'),
          content: SingleChildScrollView(
            child: Text(errorMessage),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Data Pribadi'),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: tanggalLahirController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi tanggal lahir';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: usiaController,
                    decoration: InputDecoration(
                      labelText: 'Usia',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi usia';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: alamatController,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi alamat';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: nomorTeleponController,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi nomor telepon';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: pendidikanTerakhirController,
                    decoration: InputDecoration(
                      labelText: 'Pendidikan Terakhir',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi pendidikan terakhir';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: pekerjaanController,
                    decoration: InputDecoration(
                      labelText: 'Pekerjaan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi pekerjaan';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: golonganDarahController,
                    decoration: InputDecoration(
                      labelText: 'Golongan Darah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi golongan darah';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Data Suami',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: namaSuamiController,
                    decoration: InputDecoration(
                      labelText: 'Nama Suami',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi nama suami';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: teleponSuamiController,
                    decoration: InputDecoration(
                      labelText: 'Telepon Suami',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi telepon suami';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: usiaSuamiController,
                    decoration: InputDecoration(
                      labelText: 'Usia Suami',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi usia suami';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: pekerjaanSuamiController,
                    decoration: InputDecoration(
                      labelText: 'Pekerjaan Suami',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap isi pekerjaan suami';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : submitForm,
                    child: _isLoading 
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    tanggalLahirController.dispose();
    usiaController.dispose();
    alamatController.dispose();
    nomorTeleponController.dispose();
    pendidikanTerakhirController.dispose();
    pekerjaanController.dispose();
    golonganDarahController.dispose();
    namaSuamiController.dispose();
    teleponSuamiController.dispose();
    usiaSuamiController.dispose();
    pekerjaanSuamiController.dispose();
    super.dispose();
  }
}