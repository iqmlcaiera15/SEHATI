import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Model class
class PostpartumArticle {
  final int id;
  final String judul;
  final String konten;
  final String? kategori;
  final DateTime createdAt;

  PostpartumArticle({
    required this.id,
    required this.judul,
    required this.konten,
    this.kategori,
    required this.createdAt,
  });

  factory PostpartumArticle.fromJson(Map<String, dynamic> json) {
    return PostpartumArticle(
      id: json['id'],
      judul: json['judul'],
      konten: json['konten'],
      kategori: json['kategori'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// API Service
class PostpartumApiService {
  static const String baseUrl = 'https://sehatiapp-production.up.railway.app'; // Replace with your actual API URL

  static Future<List<PostpartumArticle>> fetchArticles() async {
    final response = await http.get(Uri.parse('$baseUrl/postpartum'));
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => PostpartumArticle.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load postpartum articles');
    }
  }

  static Future<PostpartumArticle> fetchArticle(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/postpartum/$id'));
    
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
            // Article Image Placeholder
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF4DBAFF).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.article,
                  color: const Color(0xFF4DBAFF),
                  size: 48,
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
    // Strip HTML tags if present
    final strippedContent = content.replaceAll(RegExp(r'<[^>]*>'), '');
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
  bool _isBookmarked = false; // For bookmark functionality

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
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF4DBAFF),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                        // Here you would implement actual bookmark functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isBookmarked 
                              ? 'Artikel disimpan ke bookmarks' 
                              : 'Artikel dihapus dari bookmarks'
                            ),
                            backgroundColor: const Color(0xFF4DBAFF),
                          ),
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      // Implement share functionality
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
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
                      Text(
                        article.konten,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Related Articles Section (Sample - would need data)
                      const Text(
                        'Artikel Terkait',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Related Articles List (Placeholder)
                      Container(
                        height: 150,
                        child: const Center(
                          child: Text(
                            'Artikel terkait akan muncul di sini',
                            style: TextStyle(color: Color(0xFF4C617F)),
                          ),
                        ),
                      ),
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