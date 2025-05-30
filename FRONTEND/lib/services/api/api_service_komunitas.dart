import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Pastikan CommentModel dan PostModel (jika digunakan di sini) diimpor atau didefinisikan
// Anda sudah mendefinisikannya di bawah, jadi ini seharusnya OK.

class ApiServicePosts {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/api';
   static final FlutterSecureStorage _storage =  const FlutterSecureStorage();

  static Future<List<CommentModel>> fetchComments(String postId) async { // Pastikan postId adalah String
   final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }
    print('[ApiServicePosts] fetchComments: Memulai untuk postId: $postId');
    try {
      final response = await http.get(
        Uri.parse('https://sehatiapp-production.up.railway.app/api/komunitas/komen/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[ApiServicePosts] fetchComments: Status Code untuk postId $postId: ${response.statusCode}');
      // DEBUG PRINT 1: Raw response body
      print('[ApiServicePosts] fetchComments: RAW RESPONSE untuk postId $postId: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData.containsKey('data') && responseData['data'] != null) {
          if (responseData['data'] is List) {
            List<dynamic> commentsList = responseData['data'];
            // DEBUG PRINT 2: Extracted commentsList
            print('[ApiServicePosts] fetchComments: commentsList (sebelum map) untuk postId $postId: $commentsList');

            if (commentsList.isEmpty) {
              print('[ApiServicePosts] fetchComments: API mengembalikan list "data" kosong untuk postId $postId.');
              return [];
            }

            List<CommentModel> parsedComments = [];
            for (var i = 0; i < commentsList.length; i++) {
              var jsonItem = commentsList[i];
              if (jsonItem is Map<String, dynamic>) {
                try {
                  // DEBUG PRINT 3: JSON item yang sedang diparsing
                  print('[ApiServicePosts] fetchComments: Memparsing item $i: $jsonItem');
                  parsedComments.add(CommentModel.fromJson(jsonItem));
                } catch (e, s) {
                  // DEBUG PRINT 4: Error saat memparsing komentar individual
                  print('[ApiServicePosts] fetchComments: ERROR memparsing item komentar $i untuk postId $postId: $jsonItem');
                  print('[ApiServicePosts] fetchComments: Parsing ERROR: $e');
                  print('[ApiServicePosts] fetchComments: Parsing STACKTRACE: $s');
                  // Anda bisa memutuskan untuk melanjutkan (skip komentar ini) atau menghentikan semua parsing
                  // Untuk sekarang, kita biarkan error ini menghentikan parsing komentar berikutnya di loop ini
                  // dan akan ditangkap oleh catch luar jika tidak ada komentar yang berhasil diparsing.
                }
              } else {
                  print('[ApiServicePosts] fetchComments: Item $i dalam list "data" bukan Map<String, dynamic>: $jsonItem');
              }
            }
            // DEBUG PRINT 5: Jumlah komentar yang berhasil diparsing
            print('[ApiServicePosts] fetchComments: Berhasil memparsing ${parsedComments.length} komentar untuk postId $postId.');
            return parsedComments;
          } else {
            print('[ApiServicePosts] fetchComments: ERROR - Field "data" bukan List untuk postId $postId. Tipe aktual: ${responseData['data'].runtimeType}');
            return []; // Kembalikan list kosong jika 'data' bukan list
          }
        } else {
          print('[ApiServicePosts] fetchComments: ERROR - Field "data" tidak ada atau null dalam respons untuk postId $postId. Keys respons: ${responseData.keys}');
          return []; // Kembalikan list kosong jika 'data' tidak ada atau null
        }
      } else {
        print('[ApiServicePosts] fetchComments: HTTP ERROR untuk postId $postId: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Gagal memuat komentar: ${response.statusCode}');
      }
    } catch (e, s) {
      print('[ApiServicePosts] fetchComments: CATCH ERROR Umum untuk postId $postId: $e');
      print('[ApiServicePosts] fetchComments: CATCH STACKTRACE: $s');
      // Melempar ulang error agar bisa ditangani di CommentPage
      throw Exception('Error mengambil komentar: $e'); 
    }
  }

  // Helper method to get token
  static Future<String?> _getToken() async {
    const storage = FlutterSecureStorage(); // Jadikan const jika memungkinkan
    final token = await storage.read(key: 'jwt_token');
    // Hapus throw Exception di sini, biarkan pemanggil yang menangani token null jika diperlukan
    // if (token == null || token.isEmpty) {
    //   print('[ApiServicePosts] _getToken: No token found.');
    //   // throw Exception('No token found. User might not be logged in.');
    // }
    return token;
  }

  static Future<List<PostModel>> fetchPosts() async {
    print('[ApiServicePosts] fetchPosts: Memulai...');
    try {
      final token = await _getToken();
      if (token == null) {
        print('[ApiServicePosts] fetchPosts: Token tidak ditemukan, request dibatalkan.');
        throw Exception('Unauthorized: Token tidak ditemukan. Silakan login kembali.');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/komunitas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[ApiServicePosts] fetchPosts: Response status: ${response.statusCode}');
      // print('[ApiServicePosts] fetchPosts: Response body: ${response.body}'); // Bisa sangat panjang

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        // print('[ApiServicePosts] fetchPosts: Decoded data: $decodedData'); // Bisa sangat panjang

        List<dynamic>? postsListFromApi;

        if (decodedData.containsKey('Komunitas') && decodedData['Komunitas'] is List) {
          postsListFromApi = decodedData['Komunitas'];
          print('[ApiServicePosts] fetchPosts: Ditemukan ${postsListFromApi!.length} posts di key "Komunitas"');
        } else if (decodedData.containsKey('data') && decodedData['data'] is List) {
          postsListFromApi = decodedData['data'];
          print('[ApiServicePosts] fetchPosts: Ditemukan ${postsListFromApi!.length} posts di key "data" (fallback)');
        } else {
          print('[ApiServicePosts] fetchPosts: Tidak ditemukan key "Komunitas" atau "data" yang berisi list postingan.');
          return [];
        }
        
        List<PostModel> posts = [];
        for (var postJson in postsListFromApi) {
            if (postJson is Map<String, dynamic>) {
                try {
                    for (var postJson in postsListFromApi) {
                        if (postJson is Map<String, dynamic>) {
                          print('[ApiServicePosts] fetchPosts: Memproses postJson: $postJson'); // CETAK JSON MENTAH UNTUK POST
                          print('[ApiServicePosts] fetchPosts: Ekstraksi id dari JSON -> id: ${postJson['id']}, post_id: ${postJson['post_id']}, _id: ${postJson['_id']}'); // PERIKSA FIELD ID POTENSIAL
                          try {
                            posts.add(PostModel.fromJson(postJson));
                          } catch (e,s) {
                            print('[ApiServicePosts] fetchPosts: Error parsing post: $postJson, Error: $e, Stack: $s');
                          }
                        } else {
                          print('[ApiServicePosts] fetchPosts: Item postingan bukan Map: $postJson');
                        }
                      }
                } catch (e,s) {
                    print('[ApiServicePosts] fetchPosts: Error parsing post: $postJson, Error: $e, Stack: $s');
                }
            } else {
                print('[ApiServicePosts] fetchPosts: Item postingan bukan Map: $postJson');
            }
        }
        print('[ApiServicePosts] fetchPosts: Berhasil memparsing ${posts.length} postingan.');
        return posts;

      } else if (response.statusCode == 401) {
        print('[ApiServicePosts] fetchPosts: Unauthorized (401).');
        throw Exception('Unauthorized: Silakan login kembali');
      } else {
        print('[ApiServicePosts] fetchPosts: Server error ${response.statusCode}. Body: ${response.body}');
        try {
          final errorData = json.decode(response.body);
          final errorMsg = errorData['message'] ?? errorData['error'] ?? 'Unknown server error';
          throw Exception('Server error: $errorMsg');
        } catch (_) {
          throw Exception('Gagal memuat postingan: HTTP ${response.statusCode}');
        }
      }
    } catch (e,s) {
      print('[ApiServicePosts] fetchPosts: Exception: $e');
      print('[ApiServicePosts] fetchPosts: Stacktrace: $s');
      // Melempar ulang error agar bisa ditangani di UI
      if (e is Exception) throw e;
      throw Exception('Gagal mengambil postingan: $e');
    }
  }

  // static String _formatTimeAgo(String dateString) { ... } // Method ini duplikat dengan yang di CommentPage. Sebaiknya hanya ada di satu tempat atau sebagai utilitas.

  static Future<PostModel> createPost(PostModel post) async {
    print('[ApiServicePosts] createPost: Memulai dengan judul: ${post.judul}');
    try {
      final token = await _getToken();
      if (token == null) {
        print('[ApiServicePosts] createPost: Token tidak ditemukan.');
        throw Exception('Unauthorized: Token tidak ditemukan.');
      }
      
      final Map<String, dynamic> requestBody = {
        'judul': post.judul,
        'deskripsi': post.deskripsi,
      };
      
      print('[ApiServicePosts] createPost: Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/komunitas/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      
      print('[ApiServicePosts] createPost: Response status: ${response.statusCode}');
      print('[ApiServicePosts] createPost: Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          print('[ApiServicePosts] createPost: Post berhasil dibuat, data dari API: ${responseData['data']}');
          return PostModel.fromJson(responseData['data'] as Map<String, dynamic>);
        } else {
          print('[ApiServicePosts] createPost: Post berhasil dibuat (status 201) namun tidak ada key "data" yang valid di respons. Mengembalikan data lokal.');
          // Jika API tidak mengembalikan post yang baru dibuat, kembalikan saja post yang dikirim dengan ID null atau default.
          // Ini mungkin perlu penyesuaian tergantung bagaimana Anda ingin menanganinya.
          return PostModel(
            id: null, // Atau coba parse dari respons jika ada field ID terpisah
            judul: post.judul,
            deskripsi: post.deskripsi,
            // Atur default lain jika perlu
          );
        }
      } else {
        print('[ApiServicePosts] createPost: Gagal membuat post, status: ${response.statusCode}');
        try {
          final errorData = json.decode(response.body);
          final errorMsg = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          throw Exception('Gagal membuat post: $errorMsg');
        } catch (_) {
          throw Exception('Gagal membuat post: HTTP ${response.statusCode}');
        }
      }
    } catch (e,s) {
      print('[ApiServicePosts] createPost: Error: $e');
      print('[ApiServicePosts] createPost: Stacktrace: $s');
      if (e is Exception) throw e;
      throw Exception('Gagal membuat post: $e');
    }
  }
  
  static Future<bool> updateLikes(dynamic postId, int newapresiasiCount) async { // postId bisa int atau String
    final String postIdStr = postId.toString();
    print('[ApiServicePosts] updateLikes: Memulai untuk postId: $postIdStr');
    try {
      final token = await _getToken();
      if (token == null) {
        print('[ApiServicePosts] updateLikes: Token tidak ditemukan.');
        throw Exception('Unauthorized: Token tidak ditemukan.');
      }
      
      // Backend mungkin hanya perlu trigger, bukan jumlah apresiasi baru atau user_id di body.
      // Sesuaikan body jika API Anda memerlukannya.
      // final Map<String, dynamic> requestBody = {}; // Kosong jika backend hanya butuh trigger dari endpoint
      
      final response = await http.post(
        Uri.parse('$baseUrl/komunitas/like/add/$postIdStr'),
        headers: {
          'Content-Type': 'application/json', // Atau biarkan kosong jika body kosong
          'Authorization': 'Bearer $token',
        },
        // body: json.encode(requestBody), // Hanya jika API memerlukan body
      );
      
      print('[ApiServicePosts] updateLikes: Response status: ${response.statusCode}');
      print('[ApiServicePosts] updateLikes: Response body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[ApiServicePosts] updateLikes: Berhasil untuk postId: $postIdStr');
        return true;
      } else {
        print('[ApiServicePosts] updateLikes: Gagal untuk postId: $postIdStr, status: ${response.statusCode}');
        try {
          final errorData = json.decode(response.body);
          final errorMsg = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          throw Exception('Gagal memperbarui apresiasi: $errorMsg');
        } catch (_) {
          throw Exception('Gagal memperbarui apresiasi: HTTP ${response.statusCode}');
        }
      }
    } catch (e,s) {
      print('[ApiServicePosts] updateLikes: Error: $e');
      print('[ApiServicePosts] updateLikes: Stacktrace: $s');
      if (e is Exception) throw e;
      throw Exception('Gagal memperbarui apresiasi: $e');
    }
  }
  
  static Future<bool> addComment(dynamic postId, String comment) async { // postId bisa int atau String
    final String postIdStr = postId.toString();
    print('[ApiServicePosts] addComment: Memulai untuk postId: $postIdStr');
    try {
      final token = await _getToken();
      if (token == null) {
        print('[ApiServicePosts] addComment: Token tidak ditemukan.');
        throw Exception('Unauthorized: Token tidak ditemukan.');
      }
      
      final requestBody = {
        'komentar': comment,
      };
      
      print('[ApiServicePosts] addComment: Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/komunitas/komen/add/$postIdStr'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      
      print('[ApiServicePosts] addComment: Response status: ${response.statusCode}');
      print('[ApiServicePosts] addComment: Response body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
         print('[ApiServicePosts] addComment: Komentar berhasil ditambahkan untuk postId: $postIdStr');
        return true;
      } else {
        print('[ApiServicePosts] addComment: Gagal menambahkan komentar untuk postId: $postIdStr, status: ${response.statusCode}');
        try {
          final errorData = json.decode(response.body);
          final errorMsg = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          throw Exception('Gagal menambahkan komentar: $errorMsg (Status: ${response.statusCode})');
        } catch (jsonErr) { // Catch error jika body bukan JSON atau parsing gagal
          throw Exception('Gagal menambahkan komentar: HTTP ${response.statusCode}, Body: ${response.body}');
        }
      }
    } catch (e,s) {
      print('[ApiServicePosts] addComment: Error: $e');
      print('[ApiServicePosts] addComment: Stacktrace: $s');
      if (e is Exception) throw e; // Lempar ulang exception yang sudah Exception
      throw Exception('Gagal menambahkan komentar: $e'); // Bungkus error lain sebagai Exception
    }
  }
  
  // addCommentAlternative tidak saya sertakan print karena addComment yang utama
}


// MODEL DEFINITIONS (ANDA SUDAH MENYEDIAKAN INI, SAYA HANYA MEMASTIKAN ADA DI SINI UNTUK KONTEKS)
// Pastikan definisi ini konsisten dengan yang Anda gunakan di CommentPage.dart
class UserModel {
  final dynamic id; // Bisa int atau String
  final String name;
  final String? profileImage;
  final String? email;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.name,
    this.profileImage,
    this.email,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['user_id'],
      name: json['name'] ?? json['username'] ?? 'Unknown User',
      profileImage: json['profile_image'] ?? json['photo_profile'] ?? json['avatar'],
      email: json['email'],
      phoneNumber: json['phone'] ?? json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'email': email,
      'phone_number': phoneNumber,
    };
  }

  // Helper method untuk mendapatkan gambar profil dengan fallback
  String getProfileImageUrl() {
    if (profileImage == null || 
        profileImage!.isEmpty || 
        profileImage == 'assets/images/default_user.png') {
      return 'assets/images/default_user.png';
    }
    return profileImage!;
  }

  // Helper method untuk cek apakah menggunakan default avatar
  bool get hasCustomProfileImage {
    return profileImage != null && 
           profileImage!.isNotEmpty && 
           profileImage != 'assets/images/default_user.png';
  }
}

// ===== POST MODEL =====
class PostModel {
  final dynamic id;
  final String judul;
  final String deskripsi;
  final int apresiasi; // Jumlah likes/apresiasi
  final int komentar; // Jumlah komentar
  final UserModel? user; // Data user yang posting
  final String? createdAt; // Timestamp untuk format "time ago"
  final String? updatedAt;
  final bool isLiked; // Apakah user sudah like post ini
  final List<String>? tags; // Tags opsional untuk kategorisasi
  final String? imageUrl; // URL gambar post jika ada

  PostModel({
    this.id,
    required this.judul,
    required this.deskripsi,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.apresiasi = 0,
    this.komentar = 0,
    this.isLiked = false,
    this.tags,
    this.imageUrl,
  });

  // Helper getters untuk compatibility dengan view yang ada
  String? get username => user?.name ?? 'User';
  String? get userImage => user?.profileImage;
  String? get timeAgo => createdAt; // Will be formatted in UI

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Helper function untuk parsing int yang aman
    int safeParseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Parse user data
    UserModel? userData;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      try {
        userData = UserModel.fromJson(json['user'] as Map<String, dynamic>);
      } catch (e) {
        print('[PostModel] Error parsing user data: $e');
      }
    }

    // Parse tags jika ada
    List<String>? postTags;
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        postTags = (json['tags'] as List).map((tag) => tag.toString()).toList();
      } else if (json['tags'] is String) {
        // Jika tags berupa string yang dipisah koma
        postTags = json['tags'].toString().split(',').map((tag) => tag.trim()).toList();
      }
    }

    return PostModel(
      id: json['id'] ?? json['post_id'] ?? json['_id'],
      judul: json['judul']?.toString() ?? json['title']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? 
                json['description']?.toString() ?? 
                json['content']?.toString() ?? '',
      apresiasi: safeParseInt(json['apresiasi']) ?? 
                safeParseInt(json['like_count']) ?? 
                safeParseInt(json['likes']),
      komentar: safeParseInt(json['komen']) ?? 
               safeParseInt(json['komentar']) ?? 
               safeParseInt(json['comment_count']) ?? 
               safeParseInt(json['comments']),
      user: userData,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      isLiked: json['is_liked'] == true || json['isLiked'] == true,
      tags: postTags,
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'apresiasi': apresiasi,
      'komentar': komentar,
      if (user != null) 'user': user!.toJson(),
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      'is_liked': isLiked,
      if (tags != null) 'tags': tags,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  // Method untuk update apresiasi
  PostModel copyWith({
    dynamic id,
    String? judul,
    String? deskripsi,
    int? apresiasi,
    int? komentar,
    UserModel? user,
    String? createdAt,
    String? updatedAt,
    bool? isLiked,
    List<String>? tags,
    String? imageUrl,
  }) {
    return PostModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      apresiasi: apresiasi ?? this.apresiasi,
      komentar: komentar ?? this.komentar,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Helper methods untuk ID handling
  String? getIdAsString() {
    if (id == null) return null;
    return id.toString();
  }

  int? getIdAsInt() {
    if (id == null) return null;
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  // Helper method untuk validasi post
  bool get isValid {
    return judul.isNotEmpty && deskripsi.isNotEmpty;
  }

  // Helper method untuk preview deskripsi
  String getPreviewDescription({int maxLength = 100}) {
    if (deskripsi.length <= maxLength) return deskripsi;
    return '${deskripsi.substring(0, maxLength)}...';
  }
}

// ===== COMMENT MODEL =====
class CommentModel {
  final dynamic id;
  final dynamic postId;
  final String komentar; // Isi komentar
  final UserModel? user; // Data user yang komen
  final String? createdAt;
  final String? updatedAt;
  final int likes; // Jumlah likes pada komentar
  final bool isLiked; // Apakah user sudah like komentar ini
  final List<CommentModel>? replies; // Replies/balasan komentar

  CommentModel({
    required this.id,
    required this.postId,
    required this.komentar,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.likes = 0,
    this.isLiked = false,
    this.replies,
  });

  // Helper getters untuk compatibility
  String get content => komentar;
  String? get username => user?.name ?? 'User';
  String? get userImage => user?.profileImage;
  String get userId => user?.id?.toString() ?? '';

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Parse user data
    UserModel? userData;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      try {
        userData = UserModel.fromJson(json['user'] as Map<String, dynamic>);
      } catch (e) {
        print('[CommentModel] Error parsing user data: $e');
      }
    }

    // Parse replies jika ada
    List<CommentModel>? commentReplies;
    if (json['replies'] != null && json['replies'] is List) {
      try {
        commentReplies = (json['replies'] as List)
            .map((reply) => CommentModel.fromJson(reply as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('[CommentModel] Error parsing replies: $e');
      }
    }

    return CommentModel(
      id: json['id'] ?? json['comment_id'],
      postId: json['post_id'] ?? json['postId'],
      komentar: json['komentar']?.toString() ?? 
               json['comment']?.toString() ?? 
               json['content']?.toString() ?? '',
      user: userData,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      likes: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] == true || json['isLiked'] == true,
      replies: commentReplies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'komentar': komentar,
      if (user != null) 'user': user!.toJson(),
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      'likes': likes,
      'is_liked': isLiked,
      if (replies != null) 'replies': replies!.map((reply) => reply.toJson()).toList(),
    };
  }

  CommentModel copyWith({
    dynamic id,
    dynamic postId,
    String? komentar,
    UserModel? user,
    String? createdAt,
    String? updatedAt,
    int? likes,
    bool? isLiked,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      komentar: komentar ?? this.komentar,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }

  // Helper method untuk validasi komentar
  bool get isValid {
    return komentar.isNotEmpty;
  }

  // Helper method untuk cek apakah ada replies
  bool get hasReplies {
    return replies != null && replies!.isNotEmpty;
  }

  // Helper method untuk menghitung total replies
  int get replyCount {
    return replies?.length ?? 0;
  }
}

// ===== PAGINATION MODEL (untuk future use) =====
class PaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? json['page'] ?? 1,
      totalPages: json['total_pages'] ?? json['last_page'] ?? 1,
      totalItems: json['total'] ?? json['total_items'] ?? 0,
      itemsPerPage: json['per_page'] ?? json['limit'] ?? 10,
      hasNextPage: json['has_next_page'] ?? json['hasNextPage'] ?? false,
      hasPreviousPage: json['has_previous_page'] ?? json['hasPreviousPage'] ?? false,
    );
  }
}

// ===== API RESPONSE MODEL =====
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final PaginationModel? pagination;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic)? fromJsonT
  ) {
    PaginationModel? paginationData;
    if (json['pagination'] != null) {
      paginationData = PaginationModel.fromJson(json['pagination']);
    }

    return ApiResponse<T>(
      success: json['success'] ?? json['status'] == 'success' ?? true,
      message: json['message']?.toString(),
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      errors: json['errors'] as Map<String, dynamic>?,
      pagination: paginationData,
    );
  }
}