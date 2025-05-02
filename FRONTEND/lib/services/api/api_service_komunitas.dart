import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServicePosts {
  // Base URL of your Railway API
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app';
  

  
static Future<List<PostModel>> fetchPosts() async {
  try {
    final response = await http.get(
      Uri.parse('https://sehatiapp-production.up.railway.app/komunitas'),
      headers: {'Content-Type': 'application/json'},
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
            id: postJson['post_id'], // Use post_id instead of id
            judul: postJson['judul'] ?? '',
            deskripsi: postJson['deskripsi'] ?? '',
            likes: int.tryParse(postJson['likes']?.toString() ?? '0') ?? 0,
            komentar: postJson['komentar'] != null 
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
        return [];
      }
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
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

    static Future<List<PostModel>> fetchPostsLates() async {
    final response = await http.get(Uri.parse('https://sehatiapp-production.up.railway.app/komunitas/latest'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      final List<dynamic> jsonData = jsonResponse['data'] ?? [];

      return jsonData.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  // Add a new post
  static Future<PostModel> createPost(PostModel post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/komunitas/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(post.toJson()),
    );
    
    if (response.statusCode == 201) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }
  
  // Update likes count
  static Future<bool> updateLikes(int postId, int likes) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/komunitas/like/add/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'likes': likes}),
    );
    
    return response.statusCode == 200;
  }
  
  // Add a comment to a post
  static Future<bool> addComment(int postId, String comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/komunitas/komen/add/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'comment': comment}),
    );
    
    return response.statusCode == 201;
  }
}

// Post model representing data from API
class PostModel {
  final int? id;
  final String judul;
  final String deskripsi;
  final int likes;
  final int komentar;
  final String? userImage; // Optional: for user profile image
  final String? username;   // Optional: for user name
  final String? timeAgo;    // Optional: for post timestamp

  PostModel({
    this.id,
    required this.judul,
    required this.deskripsi,
    this.likes = 0,
    this.komentar = 0,
    this.userImage,
    this.username,
    this.timeAgo,
  });

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

  return PostModel(
    id: safeInt(json['id']),
    judul: json['judul']?.toString() ?? json['title']?.toString() ?? '',
    deskripsi: json['deskripsi']?.toString() ?? json['description']?.toString() ?? json['content']?.toString() ?? '',
    likes: safeInt(json['likes']) ?? safeInt(json['like_count']) ?? 0,
    komentar: safeInt(json['komen']) ?? safeInt(json['comment_count']) ?? 0,
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
      'komen': komentar,
      'likes': likes,
    };
  }
}