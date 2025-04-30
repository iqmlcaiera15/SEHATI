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
      _makananData = ApiService.fetchMakananData();
    });
  }

  List<dynamic> _filterData(List<dynamic> data) {
    // Filter data based on selected category
    if (_selectedFilter != 'Semua') {
      data = data.where((item) {
        List<dynamic> targetMakanan = json.decode(item['target_makanan']);
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
    // Parse target_makanan from JSON string to List
    List<dynamic> targetList = [];
    try {
      targetList = json.decode(item['target_makanan']);
    } catch (e) {
      // If parsing fails, try to use it as is (in case it's already a List)
      if (item['target_makanan'] is List) {
        targetList = item['target_makanan'];
      }
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
          // Food Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: item['gambar'] != null && item['gambar'].toString().isNotEmpty
                ? Image.network(
                    item['gambar'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Color(0xFFAEE2FF),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.white,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: Color(0xFFAEE2FF),
                    child: Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                Wrap(
                  spacing: 8,
                  children: targetList.map<Widget>((target) {
                    return Chip(
                      label: Text(
                        target,
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
}