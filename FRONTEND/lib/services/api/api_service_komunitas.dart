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
                    // Menggunakan PostModel.fromJson yang sudah Anda definisikan
                    posts.add(PostModel.fromJson(postJson));
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

class PostModel {
  final dynamic id; 
  final String judul;
  final String deskripsi;
  final int apresiasi;
  final int komentar; // Ini adalah jumlah komentar
  final String? userImage;
  final String? username;
  final String? timeAgo; // Ini sepertinya dihitung oleh _formatTimeAgo di fetchPosts

  PostModel({
    this.id,
    required this.judul,
    required this.deskripsi,
    this.username,
    this.userImage,
    this.timeAgo,
    this.apresiasi = 0,
    this.komentar = 0, // Jumlah komentar
  });

  PostModel copyWith({
    dynamic id, // Ubah tipe jadi dynamic
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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // print('[PostModel] Parsing post: $json'); // Bisa diaktifkan jika perlu debug PostModel
    
    int? safeInt(dynamic value) {
      if (value == null) return 0; // Default ke 0 jika null
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0; // Default ke 0 jika parsing gagal
      return 0; // Default untuk tipe lain
    }

    final postId = json['id'] ?? json['post_id'] ?? json['_id'];
    
    // Untuk `timeAgo`, jika API mengirim `created_at` yang perlu diformat,
    // sebaiknya formatting dilakukan di UI atau saat data akan ditampilkan,
    // bukan saat parsing model, kecuali API sudah mengirim string "time ago".
    // Jika `created_at` adalah timestamp, simpan sebagai DateTime atau String timestamp.
    String? createdAtTimestamp = json['created_at']?.toString(); 
    // String timeAgoFormatted = createdAtTimestamp != null ? ApiServicePosts._formatTimeAgo(createdAtTimestamp) : 'baru saja'; 
    // Menghapus _formatTimeAgo dari sini karena sudah ada di CommentPage dan bisa menyebabkan duplikasi/inkonsistensi

    return PostModel(
      id: postId,
      judul: json['judul']?.toString() ?? json['title']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? json['description']?.toString() ?? json['content']?.toString() ?? '',
      apresiasi: safeInt(json['apresiasi']) ?? safeInt(json['like_count']) ?? 0,
      komentar: safeInt(json['komen']) ?? safeInt(json['komentar']) ?? safeInt(json['comment_count']) ?? 0,
      username: json['user'] != null && json['user'] is Map ? json['user']['name']?.toString() : (json['username']?.toString() ?? json['user_name']?.toString() ?? 'User'),
      userImage: json['user'] != null && json['user'] is Map ? json['user']['photo_profile']?.toString() : (json['userImage']?.toString() ?? json['user_image']?.toString() ?? 'assets/images/default_user.png'),
      timeAgo: createdAtTimestamp, // Simpan timestamp mentah, format di UI
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      if (id != null) 'post_id': id.toString(),
    };
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? role;
  // final String? photoProfile; // Contoh jika ada

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    // this.photoProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] != null ? json['name'].toString() : 'Nama Tidak Diketahui',
      email: json['email'] != null ? json['email'].toString() : '',
      role: json['role']?.toString(),
      // photoProfile: json['photo_profile']?.toString(),
    );
  }
}

class CommentModel {
  final int id;
  final int postId;
  final String userId;
  final String komentar;
  final String? createdAt;
  final String? updatedAt;
  final UserModel? user;

  String? username;
  String? userImage;
  String get content => komentar;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.komentar,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.username,
    this.userImage,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
        try {
            parsedUser = UserModel.fromJson(json['user'] as Map<String, dynamic>);
        } catch (e) {
            print('[CommentModel] Error parsing nested user in comment: $e. User JSON: ${json['user']}');
        }
    }

    final comment = CommentModel(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      userId: json['user_id'] != null ? json['user_id'].toString() : '',
      komentar: json['komentar'] != null ? json['komentar'].toString() : '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      user: parsedUser,
    );

    if (comment.user != null) {
      comment.username = comment.user!.name;
      // Jika UserModel punya photoProfile:
      // comment.userImage = comment.user!.photoProfile ?? 'assets/images/default_user.png';
    } else {
      comment.username = 'User'; // Default jika tidak ada info user
    }
    
    // Pastikan userImage di-set, jika tidak dari user, gunakan default
    comment.userImage ??= 'assets/images/default_user.png';

    return comment;
  }
}