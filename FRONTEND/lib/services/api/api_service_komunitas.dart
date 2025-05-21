import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiServicePosts {
  // Base URL of your Railway API
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/api';
  
  
    
    static Future<List<CommentModel>> fetchComments(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('https://sehatiapp-production.up.railway.app/api/komunitas/komen/$postId'),
        headers: {
          'Content-Type': 'application/json',
          // Add any auth headers if required
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Check if the data field exists and is not null
        if (responseData['data'] != null) {
          List<dynamic> commentsList = responseData['data'];
          return commentsList.map((json) => CommentModel.fromJson(json)).toList();
        } else {
          // Return empty list if there's no data
          return [];
        }
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      throw Exception('Error fetching comments: $e');
    }
  }

  // Helper method to get token
  static Future<String?> _getToken() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }
    return token;
  }
  
  static Future<List<PostModel>> fetchPosts() async {
    try {
      // Get JWT token
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/komunitas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        print('Decoded data: $decodedData');

        // Check if the response has the 'Komunitas' key (capital K)
        if (decodedData.containsKey('Komunitas') && decodedData['Komunitas'] is List) {
          final List<dynamic> postsList = decodedData['Komunitas'];
          print('Found ${postsList.length} posts in Komunitas key');
          
          // Map each item in the list to a PostModel
          return postsList.map<PostModel>((postJson) {
            return PostModel(
              id: postJson['post_id'] ?? postJson['id'], // Try both possible id fields
              judul: postJson['judul'] ?? '',
              deskripsi: postJson['deskripsi'] ?? '',
              apresiasi: int.tryParse(postJson['apresiasi']?.toString() ?? '0') ?? 0,
              komentar: postJson['komen'] != null 
                  ? int.tryParse(postJson['komen'].toString()) ?? 0 
                  : 0,
              // You may need to adjust these based on what fields your API provides
              username: 'User', // Default
              userImage: 'assets/images/default_user.png', // Default
              timeAgo: postJson['created_at'] != null 
                  ? _formatTimeAgo(postJson['created_at'].toString())
                  : 'baru saja',
            );
          }).toList();
        } else {
          print('No Komunitas key found or it is not a list');
          // Try looking for 'data' key as a fallback
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            print('Found data key instead, using that');
            final List<dynamic> postsList = decodedData['data'];
            // Similar mapping logic here
            return postsList.map<PostModel>((postJson) => PostModel.fromJson(postJson)).toList();
          }
          return [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        // Try to parse error message from response if possible
        try {
          final errorData = json.decode(response.body);
          final errorMsg = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          throw Exception('Server error: $errorMsg');
        } catch (_) {
          throw Exception('Failed to load posts: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Exception in fetchPosts: $e');
      throw Exception('Failed to fetch posts: $e');
    }
  }

  // Helper function to format the API timestamp into a "time ago" format
  static String _formatTimeAgo(String dateString) {
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

  // Add a new post
  static Future<PostModel> createPost(PostModel post) async {
    try {
      // Get JWT token
      final token = await _getToken();
      
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'judul': post.judul,
        'deskripsi': post.deskripsi,
      };
      
      print('Creating post with data: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/komunitas/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Check if response contains the created post data
        if (responseData.containsKey('data')) {
          return PostModel.fromJson(responseData['data']);
        } else {
          // If there's no data key, create a model from the request with defaults
          return PostModel(
            judul: post.judul,
            deskripsi: post.deskripsi,
          );
        }
      } else {
        // Try to extract error message
        try {
          final errorData = json.decode(response.body);
          final errorMsg = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          throw Exception('Failed to create post: $errorMsg');
        } catch (_) {
          throw Exception('Failed to create post: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error in createPost: $e');
      throw Exception('Failed to create post: $e');
    }
  }
  
  // Update apresiasi count
  static Future<bool> updateLikes(int postId, int newapresiasiCount) async {
    try {
      // Get JWT token
      final token = await _getToken();
      
      print('Updating like for post ID: $postId');
      
      // Since backend expects a user_id for like tracking,
      // we need to modify our approach
      final Map<String, dynamic> requestBody = {
        // No need to pass apresiasi count, the backend will handle incrementing
        'user_id': 'current_user', // This would ideally come from user context
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/komunitas/like/add/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMsg = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          throw Exception('Failed to update likes: $errorMsg');
        } catch (_) {
          throw Exception('Failed to update likes: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error in updateLikes: $e');
      throw Exception('Failed to update likes: $e');
    }
  }
  
  // Add a comment to a post
  static Future<bool> addComment(int postId, String comment) async {
    try {
      // Get JWT token
      final token = await _getToken();
      
      // Debug info
      print('Attempting to add comment to post ID: $postId');
      
      // Prepare request - IMPORTANT: Match the backend expectations
      final requestBody = {
        'komentar': comment,
        // Don't include post_id in body since it's already in the URL
      };
      
      print('Request body: $requestBody');
      
      // Make request - Using POST not PATCH
      final response = await http.post(
        Uri.parse('$baseUrl/komunitas/komen/add/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMsg = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          if (response.statusCode == 404) {
            throw Exception('Post not found: $errorMsg');
          } else if (response.statusCode == 422) {
            throw Exception('Validation error: $errorMsg');
          } else {
            throw Exception('Server error: $errorMsg');
          }
        } catch (e) {
          if (e is Exception) {
            throw e;
          } else {
            throw Exception('Failed to add comment: HTTP ${response.statusCode}');
          }
        }
      }
    } catch (e) {
      print('Error in addComment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }
  
  // Alternative method if API expects different format
  static Future<bool> addCommentAlternative(int postId, String comment) async {
    try {
      // Get JWT token
      final token = await _getToken();
      
      // Try with the exact structure backend expects
      final response = await http.post(
        Uri.parse('$baseUrl/komunitas/komen/add/$postId'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'komentar': comment,
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error in addCommentAlternative: $e');
      throw Exception('Failed to add comment: $e');
    }
  }
}

// Post model representing data from API
class PostModel {
  final dynamic id; // Changed to dynamic to handle both string and int IDs
  final String judul;
  final String deskripsi;
  final int apresiasi;
  final int komentar;
  final String? userImage;
  final String? username;
  final String? timeAgo;

  PostModel({
    this.id,
    required this.judul,
    required this.deskripsi,
    this.username,
    this.userImage,
    this.timeAgo,
    this.apresiasi = 0,
    this.komentar = 0,
  });

  PostModel copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    String? username,
    String? userImage,
    String? timeAgo,
    int? apresiasi,
    int? komentar,
  }) {
    return PostModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      username: username ?? this.username,
      userImage: userImage ?? this.userImage,
      timeAgo: timeAgo ?? this.timeAgo,
      apresiasi: apresiasi ?? this.apresiasi,
      komentar: komentar ?? this.komentar,
    );
  }
  // Helper method to safely get post ID as string (for API calls)
  String? getIdAsString() {
    if (id == null) return null;
    return id.toString();
  }

  // Helper method to safely get post ID as int 
  int? getIdAsInt() {
    if (id == null) return null;
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  // Factory constructor to create a PostModel from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    print('Parsing post: $json'); // Debug
    
    // Helper function to safely extract integer values
    int? safeInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Extract ID - try multiple possible field names
    final postId = json['id'] ?? json['post_id'] ?? json['_id'];
    
    // Extract comment count - backend uses 'komen' but we map to 'komentar'
    final commentCount = safeInt(json['komen']) ?? safeInt(json['komentar']) ?? 
                         safeInt(json['comment_count']) ?? 0;
    
    return PostModel(
      id: postId, // Use the extracted ID
      judul: json['judul']?.toString() ?? json['title']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? json['description']?.toString() ?? json['content']?.toString() ?? '',
      apresiasi: safeInt(json['apresiasi']) ?? safeInt(json['like_count']) ?? 0,
      komentar: commentCount,
      username: json['username']?.toString() ?? json['user_name']?.toString() ?? json['name']?.toString() ?? 'User',
      userImage: json['userImage']?.toString() ?? json['user_image']?.toString() ?? json['avatar']?.toString() ?? 'assets/images/default_user.png',
      timeAgo: json['timeAgo']?.toString() ?? json['time_ago']?.toString() ?? json['created_at']?.toString() ?? 'baru saja',
    );
  }

  // Convert PostModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      // We don't send these values when creating a post
      // 'komen': komentar,
      // 'apresiasi': apresiasi,
      // Conditionally add id if it exists
      if (id != null) 'post_id': id.toString(),
    };
  }
}

class CommentModel {
  final int id;
  final int postId;
  final String userId; // Keeping as String since backend returns it as string "3"
  final String komentar;
  final String createdAt;
  final String updatedAt;
  final UserModel? user;
  
  // UI-specific properties
  String? username;
  String? userImage;
  String get content => komentar; // Map komentar to content for the UI

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.komentar,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.username,
    this.userImage,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Create the base comment model
    final comment = CommentModel(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'].toString(), // Converting to string to ensure consistency
      komentar: json['komentar'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
    
    // Add the UI-specific properties
    if (comment.user != null) {
      comment.username = comment.user!.name;
    } else {
      comment.username = 'User'; // Default username
    }
    
    // Default user image
    comment.userImage = 'assets/images/default_user.png';
    
    return comment;
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? role;
  // Add other user fields as needed

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
}