import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_html/flutter_html.dart';

// Model class
class PostpartumArticle {
  final int id;
  final String judul;
  final String konten;
  final String? kategori;
  final String? gambar; // Added gambar field
  final DateTime createdAt;

  PostpartumArticle({
    required this.id,
    required this.judul,
    required this.konten,
    this.kategori,
    this.gambar, // Added gambar field
    required this.createdAt,
  });

  factory PostpartumArticle.fromJson(Map<String, dynamic> json) {
    return PostpartumArticle(
      id: json['id'],
      judul: json['judul'],
      konten: json['konten'],
      kategori: json['kategori'],
      gambar: json['gambar'], // Added gambar field
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// API Service
class PostpartumApiService {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app/api';

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<List<PostpartumArticle>> fetchArticles() async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/postpartum'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => PostpartumArticle.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load postpartum articles');
    }
  }

  static Future<PostpartumArticle> fetchArticle(int id) async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. User might not be logged in.');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/postpartum/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      return PostpartumArticle.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load postpartum article');
    }
  }
}

// Index Page
class IndexPostpartum extends StatefulWidget {
  const IndexPostpartum({Key? key}) : super(key: key);

  @override
  State<IndexPostpartum> createState() => _IndexPostpartumState();
}

class _IndexPostpartumState extends State<IndexPostpartum> {
  late Future<List<PostpartumArticle>> _articlesFuture;
  String _selectedCategory = 'Semua';
  List<String> _categories = ['Semua'];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  void _loadArticles() {
    _articlesFuture = PostpartumApiService.fetchArticles();
    _articlesFuture.then((articles) {
      setState(() {
        // Extract unique categories
        Set<String> uniqueCategories = {'Semua'};
        for (var article in articles) {
          if (article.kategori != null && article.kategori!.isNotEmpty) {
            uniqueCategories.add(article.kategori!);
          }
        }
        _categories = uniqueCategories.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Artikel Postpartum',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Categories Selector
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    selectedColor: const Color(0xFF4DBAFF),
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? Colors.white : const Color(0xFF4C617F),
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          
          // Articles List
          Expanded(
            child: FutureBuilder<List<PostpartumArticle>>(
              future: _articlesFuture,
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
                        const Icon(Icons.error_outline, color: Color(0xFFFC5C9C), size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _loadArticles();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DBAFF),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada artikel yang tersedia'),
                  );
                }

                // Filter articles by category if not "Semua"
                final articles = snapshot.data!;
                final filteredArticles = _selectedCategory == 'Semua'
                    ? articles
                    : articles.where((article) => article.kategori == _selectedCategory).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];
                    return _buildArticleCard(article);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(PostpartumArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPostpartum(articleId: article.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: article.gambar != null && article.gambar!.isNotEmpty
                    ? Image.network(
                        article.gambar!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFF4DBAFF).withOpacity(0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF4DBAFF),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF4DBAFF).withOpacity(0.1),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Color(0xFF4DBAFF),
                                size: 48,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFF4DBAFF).withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            Icons.article,
                            color: Color(0xFF4DBAFF),
                            size: 48,
                          ),
                        ),
                      ),
              ),
            ),
            
            // Article Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  if (article.kategori != null && article.kategori!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DBAFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.kategori!,
                        style: const TextStyle(
                          color: Color(0xFF4DBAFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Title
                  Text(
                    article.judul,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Content Preview
                  Text(
                    _getContentPreview(article.konten),
                    style: const TextStyle(
                      color: Color(0xFF4C617F),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Date and Read More
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(article.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Baca Selengkapnya',
                        style: TextStyle(
                          color: const Color(0xFF4DBAFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

String _getContentPreview(String content) {
  String strippedContent = content
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .trim();
  
  if (strippedContent.length > 100) {
    return strippedContent.substring(0, 100) + '...';
  }
  return strippedContent;
}

  String _formatDate(DateTime date) {
    // Simple date formatter
    List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Detail Page
class DetailPostpartum extends StatefulWidget {
  final int articleId;
  
  const DetailPostpartum({Key? key, required this.articleId}) : super(key: key);

  @override
  State<DetailPostpartum> createState() => _DetailPostpartumState();
}

class _DetailPostpartumState extends State<DetailPostpartum> {
  late Future<PostpartumArticle> _articleFuture;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  void _loadArticle() {
    _articleFuture = PostpartumApiService.fetchArticle(widget.articleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PostpartumArticle>(
        future: _articleFuture,
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
                  const Icon(Icons.error_outline, color: Color(0xFFFC5C9C), size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadArticle();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DBAFF),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Artikel tidak ditemukan'),
            );
          }

          final article = snapshot.data!;
          
          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 250,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF4DBAFF),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
               
                flexibleSpace: FlexibleSpaceBar(
                  background: article.gambar != null && article.gambar!.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              article.gambar!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: const Color(0xFF4DBAFF),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF4DBAFF),
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 80,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Gradient overlay for better text readability
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: const Color(0xFF4DBAFF),
                          child: Center(
                            child: Icon(
                              Icons.article,
                              color: Colors.white.withOpacity(0.7),
                              size: 80,
                            ),
                          ),
                        ),
                ),
              ),
              
              // Article Content
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      if (article.kategori != null && article.kategori!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DBAFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            article.kategori!,
                            style: const TextStyle(
                              color: Color(0xFF4DBAFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        article.judul,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Date
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF4C617F),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(article.createdAt),
                            style: const TextStyle(
                              color: Color(0xFF4C617F),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Content
                      Html(
                        data: article.konten,
                        style: {
                          "body": Style(
                            color: const Color(0xFF1E293B),
                            fontSize: FontSize(16),
                            lineHeight: LineHeight.number(1.6),
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                          "p": Style(
                            margin: Margins.only(bottom: 16),
                          ),
                          "ul": Style(
                            margin: Margins.only(bottom: 16),
                            padding: HtmlPaddings.only(left: 20),
                          ),
                          "ol": Style(
                            margin: Margins.only(bottom: 16),
                            padding: HtmlPaddings.only(left: 20),
                          ),
                          "li": Style(
                            margin: Margins.only(bottom: 8),
                          ),
                          "strong": Style(
                            fontWeight: FontWeight.bold,
                          ),
                          "em": Style(
                            fontStyle: FontStyle.italic,
                          ),
                        },
                      ),
                                            
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Same formatter as in index page
    List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}