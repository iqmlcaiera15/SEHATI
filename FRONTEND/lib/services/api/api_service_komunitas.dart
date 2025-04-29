import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServicePosts {
  // Base URL of your Railway API
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app';
  

  
  // Fetch all posts from API
  static Future<List<PostModel>> fetchPosts() async {
    final response = await http.get(Uri.parse('https://sehatiapp-production.up.railway.app/komunitas'));
    
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
      Uri.parse('$baseUrl/posts'),
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
      Uri.parse('$baseUrl/posts/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'likes': likes}),
    );
    
    return response.statusCode == 200;
  }
  
  // Add a comment to a post
  static Future<bool> addComment(int postId, String comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
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
  final int komen;
  final String? userImage; // Optional: for user profile image
  final String? username;   // Optional: for user name
  final String? timeAgo;    // Optional: for post timestamp

  PostModel({
    this.id,
    required this.judul,
    required this.deskripsi,
    this.likes = 0,
    this.komen = 0,
    this.userImage,
    this.username,
    this.timeAgo,
  });

  // Factory constructor to create a PostModel from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      likes: json['likes'] ?? 0,
      komen: json['komen'] ?? 0,
      // Optional fields with default placeholders
      username: json['username'] ?? 'User',
      userImage: json['userImage'] ?? 'assets/images/default_user.png',
      timeAgo: json['timeAgo'] ?? 'baru saja',
    );
  }

  // Convert PostModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'komen': komen,
      'likes': likes,
    };
  }
}