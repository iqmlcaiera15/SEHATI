import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:Sehati/services/api/api_service_rekomen.dart'; 

class RekomendasiMakananPage extends StatefulWidget {
  const RekomendasiMakananPage({Key? key}) : super(key: key);

  @override
  State<RekomendasiMakananPage> createState() => _RekomendasiMakananPageState();
}

class _RekomendasiMakananPageState extends State<RekomendasiMakananPage> {
  late Future<List<dynamic>> _makananData;
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Hamil', 'Menyusui'];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMakananData();
  }

  void _loadMakananData() {
    setState(() {
      _makananData = ApiServiceRekomen.fetchMakananData();
    });
  }

  List<dynamic> _filterData(List<dynamic> data) {
    // Filter data based on selected category
    if (_selectedFilter != 'Semua') {
      data = data.where((item) {
        // Handle both string and array formats
        List<dynamic> targetMakanan = [];
        if (item['target_makanan'] is String) {
          try {
            targetMakanan = json.decode(item['target_makanan']);
          } catch (e) {
            debugPrint('Error parsing target_makanan: $e');
            return false;
          }
        } else if (item['target_makanan'] is List) {
          targetMakanan = item['target_makanan'];
        }
        return targetMakanan.contains(_selectedFilter);
      }).toList();
    }

    // Filter data based on search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      data = data.where((item) {
        return item['nama'].toString().toLowerCase().contains(query) ||
               item['deskripsi'].toString().toLowerCase().contains(query);
      }).toList();
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rekomendasi Makanan',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.50,
            letterSpacing: 0.12,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari rekomendasi makanan...',
                hintStyle: TextStyle(color: Color(0xFF4C617F)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF4DBAFF)),
                filled: true,
                fillColor: Color(0xFFF4F4F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {});  // Trigger rebuild to apply search filter
              },
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    checkmarkColor: Colors.white,
                    selectedColor: Color(0xFF4DBAFF),
                    backgroundColor: Color(0xFFF4F4F4),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Color(0xFF4C617F),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Food Recommendations List
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _makananData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF4DBAFF)),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Color(0xFFFC5C9C), size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _loadMakananData();
                            });
                          },
                          icon: Icon(Icons.refresh, color: Color(0xFF4DBAFF)),
                          label: Text(
                            'Coba lagi',
                            style: TextStyle(
                              color: Color(0xFF4DBAFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_food, color: Color(0xFF4C617F), size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada data rekomendasi makanan',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final filteredData = _filterData(snapshot.data!);
                  
                  if (filteredData.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, color: Color(0xFF4C617F), size: 48),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada hasil yang cocok',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final item = filteredData[index];
                      return _buildFoodItem(item);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(dynamic item) {
    // Debug: Print item data
    debugPrint('Item data: $item');
    debugPrint('Image URL: ${item['gambar']}');
    debugPrint('Target makanan: ${item['target_makanan']}');
    debugPrint('Target makanan type: ${item['target_makanan'].runtimeType}');

    // Handle target_makanan - it's already an array from API
    List<dynamic> targetList = [];
    try {
      if (item['target_makanan'] is String) {
        targetList = json.decode(item['target_makanan']);
      } else if (item['target_makanan'] is List) {
        targetList = item['target_makanan'];
      }
    } catch (e) {
      debugPrint('Error parsing target_makanan: $e');
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image - Fixed version
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              color: Colors.grey[200],
            ),
            child: _buildImageWidget(item['gambar']),
          ),
          // Food Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Name
                Text(
                  item['nama'] ?? 'Tidak ada judul',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),

                // Target Groups
                if (targetList.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: targetList.map<Widget>((target) {
                      return Chip(
                        label: Text(
                          target.toString(),
                          style: TextStyle(
                            color: Color(0xFF4DBAFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Color(0xFFAEE2FF).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Color(0xFF4DBAFF), width: 1),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                SizedBox(height: 12),

                // Food Description
                Text(
                  item['deskripsi'] ?? 'Tidak ada deskripsi',
                  style: TextStyle(
                    color: Color(0xFF4C617F),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String? imageUrl) {
    // Debug image URL
    debugPrint('Building image widget for URL: $imageUrl');

    // Check if image URL is valid
    if (imageUrl == null || imageUrl.isEmpty) {
      debugPrint('Image URL is null or empty');
      return _buildPlaceholder();
    }

    // Validate URL format
    Uri? uri;
    try {
      uri = Uri.parse(imageUrl);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        debugPrint('Invalid URL scheme: $imageUrl');
        return _buildPlaceholder();
      }
    } catch (e) {
      debugPrint('Error parsing URL: $e');
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // Remove problematic headers
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            debugPrint('Image loaded successfully: $imageUrl');
            return child;
          }
          
          final progress = loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null;
              
          debugPrint('Loading image: ${(progress ?? 0) * 100}%');
          
          return Center(
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Color(0xFF4DBAFF),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $error');
          debugPrint('Image URL that failed: $imageUrl');
          debugPrint('Stack trace: $stackTrace');
          return _buildErrorPlaceholder();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood,
            size: 50,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.red[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.red[300],
          ),
          SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.red[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}