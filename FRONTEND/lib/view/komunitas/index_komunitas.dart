import 'package:Sehati/view/shop/shop_index.dart';
import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_komunitas.dart'; 
import 'package:Sehati/view/homeprofile/home.dart';
import 'package:Sehati/view/komunitas/comment_komunitas.dart';
import 'package:Sehati/view/homeprofile/profile.dart'; 

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  Future<List<PostModel>> _posts = Future.value([]);
  bool isLoading = false;
  int _currentIndex = 1;
  
  // Global key for scaffold to show SnackBar properly
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();
  
  @override
  void initState() {
    super.initState();
    // Load posts in a slightly delayed manner to ensure the widget is fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      final posts = await ApiServicePosts.fetchPosts();
      if (mounted) {
        setState(() {
          _posts = Future.value(posts);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnackBar('Error: ${e.toString()}');
        _posts = Future.value([]);
      }
    }
  }

  // Helper function to safely show SnackBar
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    if (!mounted) return;
    
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // FIXED: Bottom Navigation - Prevent duplicate navigation
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        // Prevent navigation to the same page
        if (index == _currentIndex) return;
        
        setState(() {
          _currentIndex = index;
        });
        
        // Navigate based on index with proper route management
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
            break;
          case 1:
            // Already on Community page, do nothing
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ShopPage()),
            );
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserDataViewPage()),
            );
            break;
        }
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
          icon: SizedBox(), // Empty space for FAB
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  // FIXED: Create Post Dialog with better state management
  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isSubmitting = false; // Add loading state
    
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) {
        return StatefulBuilder( // Use StatefulBuilder for dialog state
          builder: (context, setDialogState) {
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
                    enabled: !isSubmitting, // Disable when submitting
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      labelStyle: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    enabled: !isSubmitting, // Disable when submitting
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      labelStyle: TextStyle(fontFamily: 'Poppins'),
                    ),
                    maxLines: 3,
                  ),
                  if (isSubmitting) // Show loading indicator
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () {
                    titleController.dispose();
                    descriptionController.dispose();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    // Validate inputs
                    if (titleController.text.trim().isEmpty || 
                        descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Judul dan deskripsi tidak boleh kosong'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // Set loading state
                    setDialogState(() {
                      isSubmitting = true;
                    });
                    
                    try {
                      // Create post model
                      final newPost = PostModel(
                        judul: titleController.text.trim(),
                        deskripsi: descriptionController.text.trim(),
                      );
                      
                      // Call API service
                      await ApiServicePosts.createPost(newPost);
                      
                      // Close dialog first
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                      
                      // Then reload posts
                      if (mounted) {
                        await _loadPosts();
                      }
                      
                      // Show success message
                      if (mounted) {
                        _showSnackBar(
                          'Postingan berhasil dibuat',
                          backgroundColor: Colors.green,
                        );
                      }
                    } catch (e) {
                      // Reset loading state on error
                      setDialogState(() {
                        isSubmitting = false;
                      });
                      
                      // Show error message
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error membuat postingan: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      // Always dispose controllers
                      titleController.dispose();
                      descriptionController.dispose();
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
      },
    );
  }

  // FIXED: Like handler with duplicate prevention
  void _handleLikePost(PostModel post) async {
    print('[CommunityPage] _handleLikePost DIPANGGIL untuk post ID: ${post.id}');
    
    if (post.id != null && !isLoading) { // Prevent multiple simultaneous calls
      setState(() {
        isLoading = true;
      });
      
      try {
        await ApiServicePosts.updateLikes(post.id!, post.apresiasi + 1);
        
        // Only reload if still mounted
        if (mounted) {
          await _loadPosts();
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Error updating apresiasi: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  // FIXED: Build method with ListView key for better performance
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // App Bar with Back Button (unchanged)
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
                      'Timeline MamaShare',
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
                    // Community Header (unchanged)
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
                              "Postingan Terbaru dari Komunitas Ibu Hamil",
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // FIXED: Posts List with proper key management
                    Positioned(
                      left: 29,
                      top: 90,
                      right: 29,
                      bottom: 20,
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await _loadPosts();
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
                            // Remove duplicates based on post ID
                            final uniquePosts = <PostModel>[];
                            final seenIds = <int?>{};
                            
                            for (final post in posts) {
                              if (!seenIds.contains(post.id)) {
                                seenIds.add(post.id);
                                uniquePosts.add(post);
                              }
                            }
                            
                            return ListView.builder(
                              key: ValueKey('posts_${uniquePosts.length}'), // Add key for better rebuilds
                              itemCount: uniquePosts.length,
                              itemBuilder: (context, index) {
                                return _buildPostCard(uniquePosts[index]);
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
            _showCreatePostDialog();
          },
          backgroundColor: const Color(0xFF4DBAFF),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // Rest of the methods remain the same...
  static String _formatTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'baru saja';
    
    try {
      final DateTime date = DateTime.parse(dateString);
      final Duration difference = DateTime.now().difference(date);
      
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} tahun yang lalu';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} bulan yang lalu';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'baru saja';
      }
    } catch (e) {
      print('Error formatting date: $e');
      return 'baru saja';
    }
  }

  Widget _buildUserAvatar(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty || imageUrl == 'assets/images/default_user.png') {
      return const Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      );
    } else {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            );
          },
        ),
      );
    }
  }

  Widget _buildPostCard(PostModel post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommentPage(post: post),
          ),
        ).then((_) {
          _loadPosts();
        });
      },
      child: Container(
        key: ValueKey('post_${post.id}'), // Add unique key for each post
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
                        radius: 20,
                        backgroundColor: const Color(0xFF4DBAFF),
                        child: _buildUserAvatar(post.userImage),
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
                            _formatTimeAgo(post.timeAgo),
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
            
            // Like and comment buttons
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    Icons.thumb_up_outlined, 
                    "apresiasi (${post.apresiasi})",
                    () => _handleLikePost(post),
                  ),
                  _buildActionButton(
                    Icons.comment_outlined, 
                    "Komentar",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentPage(post: post),
                        ),
                      ).then((_) {
                        _loadPosts();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
}