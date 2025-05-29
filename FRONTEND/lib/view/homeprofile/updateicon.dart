import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_profile.dart'; // Sesuaikan path import
import 'package:Sehati/view/homeprofile/profile.dart'; 

class SelectProfilePage extends StatefulWidget {
  const SelectProfilePage({Key? key}) : super(key: key);

  @override
  State<SelectProfilePage> createState() => _SelectProfilePageState();
}

class _SelectProfilePageState extends State<SelectProfilePage> {
  late Future<List<dynamic>> _iconsFuture;
  int? _selectedIconId; // Untuk menyimpan ID icon yang dipilih
  bool _isLoading = false; // Untuk loading state saat menyimpan

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  void _loadIcons() {
    setState(() {
      _iconsFuture = ApiServiceProfile.fetchIcons();
    });
  }

  void _onIconSelected(int iconId) {
    setState(() {
      _selectedIconId = iconId;
    });
  }

  Future<void> _saveSelectedIcon() async {
    if (_selectedIconId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiServiceProfile.updateSelectedIcon(_selectedIconId!);
      
      // Navigasi ke HomePage setelah berhasil
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDataViewPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan pilihan: $e'),
            backgroundColor: const Color(0xFFFC5C9C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pilih Icon Profil',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _iconsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4DBAFF)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFFC5C9C), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _loadIcons,
                      icon: const Icon(Icons.refresh, color: Color(0xFF4DBAFF)),
                      label: const Text(
                        'Coba lagi',
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
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_outlined, color: Color(0xFF4C617F), size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada icon tersedia',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final icons = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                final icon = icons[index];
                final int iconId = icon['id'] ?? index;
                final String iconName = icon['name'] ?? 'Icon Tanpa Nama';
                final String iconImageUrl = icon['data'] ?? '';
                final bool isSelected = _selectedIconId == iconId;

                return GestureDetector(
                  onTap: () => _onIconSelected(iconId),
                  child: Card(
                    elevation: isSelected ? 8.0 : 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF4DBAFF) : Colors.transparent,
                        width: 3.0,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFF4DBAFF).withOpacity(0.15),
                                  Colors.white,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon check untuk pilihan yang dipilih
                            if (isSelected)
                              Container(
                                alignment: Alignment.topRight,
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF4DBAFF),
                                  size: 24.0,
                                ),
                              )
                            else
                              const SizedBox(height: 24.0),
                            
                            const SizedBox(height: 8.0),
                            
                            // Gambar icon
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: iconImageUrl.isNotEmpty
                                      ? Image.network(
                                          iconImageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              color: Colors.grey[100],
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  color: Color(0xFF4DBAFF),
                                                  strokeWidth: 2.0,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[100],
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Color(0xFF4C617F),
                                                size: 40,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey[100],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Color(0xFF4C617F),
                                            size: 40,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12.0),
                            
                            // Nama icon
                            Text(
                              iconName,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF1E293B),
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: _selectedIconId != null
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _saveSelectedIcon,
              label: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Lanjutkan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
              icon: _isLoading ? null : const Icon(Icons.arrow_forward, color: Colors.white),
              backgroundColor: _isLoading 
                  ? const Color(0xFF4DBAFF).withOpacity(0.6)
                  : const Color(0xFF4DBAFF),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}