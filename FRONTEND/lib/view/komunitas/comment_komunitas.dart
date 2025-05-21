import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_komunitas.dart';

class CommentPage extends StatefulWidget {
  final PostModel post;

  const CommentPage({Key? key, required this.post}) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  late PostModel _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final comments = await ApiServicePosts.fetchComments(_currentPost.id!);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Error loading comments: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    if (!mounted) return;
    
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) {
      _showSnackBar('Comment cannot be empty', backgroundColor: Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiServicePosts.addComment(_currentPost.id!, _commentController.text);
      _commentController.clear();
      
      // Update the post with incremented comment count
      final updatedPost = _currentPost.copyWith(
        komentar: _currentPost.komentar + 1
      );
      
      setState(() {
        _currentPost = updatedPost;
      });
      
      await _loadComments(); // Reload comments after adding a new one
      _showSnackBar('Comment added successfully', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackBar('Error adding comment: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTimeAgo(String dateString) {
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Detail Postingan',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Post card
            Container(
              margin: const EdgeInsets.all(16),
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
                              backgroundImage: AssetImage(_currentPost.userImage ?? 'assets/images/default_user.png'),
                              radius: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentPost.username ?? 'User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  _currentPost.timeAgo ?? 'baru saja',
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
                      _currentPost.judul,
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
                      _currentPost.deskripsi,
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
                          "apresiasi (${_currentPost.apresiasi})",
                          () async {
                            if (_currentPost.id != null) {
                              setState(() {
                                _isLoading = true;
                              });
                              
                              try {
                                // Call the API to update likes
                                await ApiServicePosts.updateLikes(_currentPost.id!, _currentPost.apresiasi + 1);
                                
                                // Create a new PostModel with updated apresiasi count
                                final updatedPost = _currentPost.copyWith(
                                  apresiasi: _currentPost.apresiasi + 1
                                );
                                
                                // Update the state with the new post
                                setState(() {
                                  _currentPost = updatedPost;
                                  _isLoading = false;
                                });
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });
                                _showSnackBar('Error updating apresiasi: $e');
                              }
                            }
                          },
                        ),
                        _buildActionButton(
                          Icons.comment_outlined, 
                          "Komentar (${_comments.length})",
                          () {},
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
            ),
            
            // Comments header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.comment, color: Color(0xFF4DBAFF)),
                  const SizedBox(width: 8),
                  Text(
                    'Komentar (${_comments.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            
            // Comments list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4DBAFF)))
                  : _comments.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada komentar',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _comments.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage(comment.userImage ?? 'assets/images/default_user.png'),
                                        radius: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        comment.username ?? 'User',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatTimeAgo(comment.createdAt ?? DateTime.now().toString()),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    comment.content,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            
            // Comment input field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F4F4),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _addComment,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4DBAFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
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