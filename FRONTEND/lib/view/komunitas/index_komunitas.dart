import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_komunitas.dart'; 

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late Future<List<PostModel>> _posts;
  bool isLoading = false;
  int _currentIndex = 1; // Inisialisasi dengan 1 karena ini halaman Komunitas
  
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _posts = ApiServicePosts.fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Status Bar Space
          Container(
            width: double.infinity,
            height: 44,
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  left: 21,
                  top: 10.50,
                  child: SizedBox(
                    width: 54,
                    child: Text(
                      '9:41',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ),
                ),
                // Battery icon
                Positioned(
                  left: 389.33,
                  top: 17.33,
                  child: Opacity(
                    opacity: 0.35,
                    child: Container(
                      width: 22,
                      height: 11.33,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFF1E293B),
                          ),
                          borderRadius: BorderRadius.circular(2.67),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 391.33,
                  top: 19.33,
                  child: Container(
                    width: 18,
                    height: 7.33,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.33),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // App Bar with Back Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back arrow button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1E293B),
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Timeline',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
                // User profile button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(4, 0),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Community Header
                  Positioned(
                    left: 29,
                    top: 20,
                    right: 29,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF9F9F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Postingan pilihan oleh Telkom University",
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: const Color(0xFFF44336),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Posts List
                  Positioned(
                    left: 29,
                    top: 90,
                    right: 29,
                    bottom: 20,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _loadPosts();
                      },
                      color: const Color(0xFF4DBAFF),
                      child: FutureBuilder<List<PostModel>>(
                        future: _posts,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: Color(0xFF4DBAFF)),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, color: Color(0xFFFC5C9C), size: 64),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Error: ${snapshot.error}",
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _loadPosts,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4DBAFF),
                                    ),
                                    child: const Text('Refresh'),
                                  ),
                                ],
                              ),
                            );
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.post_add, color: Color(0xFF4DBAFF), size: 64),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Belum ada postingan",
                                    style: TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          final posts = snapshot.data!;
                          return ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              return _buildPostCard(posts[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement the create post functionality
          _showCreatePostDialog();
        },
        backgroundColor: const Color(0xFF4DBAFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

   Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          // Tambahkan logika navigasi di sini
          if (index == 1) { // Indeks untuk item 'Komunitas' (dimulai dari 0)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CommunityPage()),
            );
          } else if (index == 0) {
            // Navigasi ke halaman Beranda (jika Anda punya halaman Beranda terpisah)
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const BerandaPage()),
            // );
          } else if (index == 3) {
            // Navigasi ke halaman Tersimpan
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const TersimpanPage()),
            // );
          } else if (index == 4) {
            // Navigasi ke halaman Profil
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const ProfilPage()),
            // );
          }
        });
      },
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4DBAFF),
      unselectedItemColor: const Color(0xFF4C617F),
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Komunitas',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(), // Ruang kosong untuk FAB
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Tersimpan', 
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and timestamp
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(post.userImage ?? 'assets/images/default_user.png'),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.username ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          post.timeAgo ?? 'baru saja',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),
          
          // Post title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.judul,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Post description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.deskripsi,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          
          const Divider(height: 32),
          
          // Like, comment, share buttons
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  Icons.thumb_up_outlined, 
                  "Suka (${post.likes})",
                  () => _handleLikePost(post),
                ),
                _buildActionButton(
                  Icons.comment_outlined, 
                  "Komentar (${post.komen})",
                  () => _showCommentSheet(post),
                ),
                _buildActionButton(
                  Icons.share_outlined, 
                  "Bagikan",
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4DBAFF), size: 18),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontFamily: 'Poppins',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleLikePost(PostModel post) async {
    if (post.id != null) {
      setState(() {
        isLoading = true;
      });
      
      try {
        await ApiServicePosts.updateLikes(post.id!, post.likes + 1);
        _loadPosts(); // Reload posts to get updated data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating likes: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  void _showCommentSheet(PostModel post) {
    final commentController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambahkan Komentar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4DBAFF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4DBAFF), width: 2),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (commentController.text.isNotEmpty && post.id != null) {
                        try {
                          await ApiServicePosts.addComment(post.id!, commentController.text);
                          _loadPosts(); // Reload posts to update comments count
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error adding comment: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DBAFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kirim',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Buat Postingan Baru',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                  final newPost = PostModel(
                    judul: titleController.text,
                    deskripsi: descriptionController.text,
                  );
                  
                  try {
                    await ApiServicePosts.createPost(newPost);
                    _loadPosts(); // Reload posts
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Postingan berhasil dibuat')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating post: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DBAFF),
              ),
              child: const Text(
                'Posting',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Entry point for the community feature
class CommunityFeature extends StatelessWidget {
  const CommunityFeature({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehati Community',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF4DBAFF),
        fontFamily: 'Poppins',
      ),
      home: const CommunityPage(),
    );
  }
}