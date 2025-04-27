import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Ibu Hamil',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/input': (context) => InputPage(),
        '/data': (context) => ViewDataPage(),
        '/detail': (context) => DetailPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Ibu Hamil'),
        actions: [
          // Tombol di AppBar
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Logika notifikasi jika ada
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notifikasi belum diimplementasikan!')),
              );
            },
          ),
        ],
      ),
      // Menambahkan Drawer (Sidebar)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Menambahkan header Drawer
            UserAccountsDrawerHeader(
              accountName: Text('Ibu Hamil'),
              accountEmail: Text('ibu_hamil@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
            // Menu untuk navigasi
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Beranda'),
              onTap: () {
                Navigator.pop(context); // Menutup drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.input),
              title: Text('Input Data'),
              onTap: () {
                Navigator.pushNamed(context, '/input');
              },
            ),
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text('Lihat Data'),
              onTap: () {
                Navigator.pushNamed(context, '/data');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Keluar'),
              onTap: () {
                Navigator.pop(context); // Bisa diganti dengan logika logout
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gambar latar belakang (Opsional)
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 500,
                width: double.infinity,
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/input');
                },
                icon: Icon(Icons.add),
                label: Text('Input Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, // Menambahkan warna latar belakang tombol
                  minimumSize: Size(200, 50),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/data');
                },
                icon: Icon(Icons.list),
                label: Text('Lihat Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Menambahkan warna latar belakang tombol
                  minimumSize: Size(200, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputPage extends StatefulWidget {
  final Map<String, dynamic>? dataToEdit;

  InputPage({this.dataToEdit});

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.dataToEdit != null) {
      nameController.text = widget.dataToEdit!['name'] ?? '';
      bmiController.text = widget.dataToEdit!['bmi']?.toString() ?? '';
      bloodPressureController.text = widget.dataToEdit!['bloodPressure'] ?? '';
      bloodGroupController.text = widget.dataToEdit!['bloodGroup'] ?? '';
      ageController.text = widget.dataToEdit!['age']?.toString() ?? '';
    }
  }

  Future<void> submitData() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    isLoading = true;
  });

  final newData = {
    'name': nameController.text,
    'bmi': double.parse(bmiController.text),
    'bloodPressure': bloodPressureController.text,
    'bloodGroup': bloodGroupController.text,
    'age': int.parse(ageController.text),
  };

  try {
    final String apiUrl = widget.dataToEdit == null
        ? 'https://9bf9-114-122-73-112.ngrok-free.app/api/data/add' // Gantilah dengan URL endpoint API yang benar
        : 'https://9bf9-114-122-73-112.ngrok-free.app/api/data/update/${widget.dataToEdit!['id']}'; // Gantilah dengan URL endpoint API untuk update

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',  // Menambahkan header 'ngrok-skip-browser-warning'
      },
      body: json.encode(newData),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      throw Exception('Gagal menyimpan data');
    }
  } catch (e) {
    print("Error: $e");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dataToEdit == null ? 'Input Data Kesehatan' : 'Edit Data Kesehatan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Ibu Hamil',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: bmiController,
                decoration: InputDecoration(
                  labelText: 'BMI',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'BMI tidak boleh kosong';
                  if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: bloodPressureController,
                decoration: InputDecoration(
                  labelText: 'Tekanan Darah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Tekanan darah tidak boleh kosong' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: bloodGroupController,
                decoration: InputDecoration(
                  labelText: 'Golongan Darah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Golongan darah tidak boleh kosong' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Usia',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Usia tidak boleh kosong';
                  if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              SizedBox(height: 30),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: submitData,
                      child: Text('Simpan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewDataPage extends StatefulWidget {
  @override
  _ViewDataPageState createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<ViewDataPage> {
  List<Map<String, dynamic>> dataList = [];
  bool isLoading = false;

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://9bf9-114-122-73-112.ngrok-free.app/api/data/fetch'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic> && jsonData['data'] is List) {
          setState(() {
            dataList = List<Map<String, dynamic>>.from(jsonData['data']);
          });
        } else {
          throw Exception('Format data tidak sesuai');
        }
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lihat Data Kesehatan'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tombol untuk kembali
            },
            child: Text('Kembali'),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : dataList.isEmpty
              ? Center(child: Text('Belum ada data'))
              : ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    final data = dataList[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          data['name'] ?? 'Tidak ada nama',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BMI: ${data['bmi']}'),
                            Text('Tekanan Darah: ${data['bloodPressure']}'),
                            Text('Golongan Darah: ${data['bloodGroup']}'),
                            Text('Usia: ${data['age']}'),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/detail', arguments: data);
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/input');
          if (result == true) fetchData();
        },
        child: Text('Tambah Data'),
      ),
    );
  }
}


class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Data Kesehatan'),
        backgroundColor: Colors.pink,  // Menambahkan warna pada AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Membuat tampilan scrollable jika informasi panjang
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama
              Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nama:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        data['name'] ?? 'Tidak ada nama',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              // BMI
              Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BMI:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        data['bmi'].toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              // Tekanan Darah
              Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tekanan Darah:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        data['bloodPressure'] ?? 'Tidak ada data',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              // Golongan Darah
              Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Golongan Darah:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        data['bloodGroup'] ?? 'Tidak ada data',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              // Usia
              Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Usia:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        data['age'].toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

