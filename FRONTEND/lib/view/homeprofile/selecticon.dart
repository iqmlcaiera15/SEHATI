import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // Import flutter_html
import 'package:Sehati/services/api/api_service_profile.dart'; // Sesuaikan path import


class SelectProfilePage extends StatefulWidget {
  const SelectProfilePage({Key? key}) : super(key: key);

  @override
  State<SelectProfilePage> createState() => _SelectProfilePageState();
}

class _SelectProfilePageState extends State<SelectProfilePage> {
  late Future<List<dynamic>> _profilesFuture;
  int? _selectedProfileId; // Untuk menyimpan ID profil yang dipilih

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    setState(() {
      _profilesFuture = ApiServiceProfile.fetchProfiles();
    });
  }

  void _onProfileSelected(int profileId) {
    setState(() {
      _selectedProfileId = profileId;
    });
    // Di sini Anda bisa melakukan navigasi atau tindakan lain dengan profileId yang dipilih
    // Contoh: Navigator.pop(context, profileId);
    // Atau: Provider.of<ProfileProvider>(context, listen: false).setSelectedProfile(profileId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile ID: $profileId selected! Implement action here.')),
    );
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
          'Pilih Profil',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _profilesFuture,
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
                      onPressed: _loadProfiles,
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
                    'Tidak ada profil tersedia',
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
            final profiles = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                // Pastikan field 'id', 'name', dan 'html_content' ada di data profil Anda
                final int profileId = profile['id'] ?? index; // Fallback ke index jika id null
                final String profileName = profile['name'] ?? 'Profil Tanpa Nama';
                final String profileHtmlContent = profile['html_content'] ?? '<p>Konten tidak tersedia.</p>';
                final bool isSelected = _selectedProfileId == profileId;

                return GestureDetector(
                  onTap: () => _onProfileSelected(profileId),
                  child: Card(
                    elevation: isSelected ? 6.0 : 2.0,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF4DBAFF) : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFF4DBAFF).withOpacity(0.1),
                                  Colors.white,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    profileName,
                                    style: TextStyle(
                                      color: const Color(0xFF1E293B),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      shadows: isSelected
                                          ? [
                                              Shadow(
                                                blurRadius: 1.0,
                                                color: const Color(0xFF4DBAFF).withOpacity(0.5),
                                                offset: const Offset(0, 0),
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4DBAFF),
                                    size: 24.0,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            const Divider(height: 1, color: Color(0xFFE0E0E0)),
                            const SizedBox(height: 12.0),
                            Html(
                              data: profileHtmlContent,
                              style: {
                                "body": Style(
                                  margin: Margins.zero, // Menghilangkan margin default dari tag body html
                                  padding: HtmlPaddings.zero,
                                  fontSize: FontSize(14.0),
                                  color: const Color(0xFF4C617F),
                                ),
                                "h1": Style(fontSize: FontSize(18.0), fontWeight: FontWeight.w600),
                                "p": Style(lineHeight: LineHeight.em(1.5)),
                                // Anda bisa menambahkan style kustom untuk tag HTML lainnya
                              },
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
      floatingActionButton: _selectedProfileId != null
          ? FloatingActionButton.extended(
              onPressed: () {
                // Aksi setelah profil dipilih dan tombol ditekan
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Melanjutkan dengan Profile ID: $_selectedProfileId')),
                );
              },
              label: const Text('Lanjutkan'),
              icon: const Icon(Icons.arrow_forward),
              backgroundColor: const Color(0xFF4DBAFF),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}