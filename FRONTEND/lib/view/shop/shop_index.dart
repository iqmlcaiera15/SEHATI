import 'package:flutter/material.dart';
import 'package:Sehati/services/api/api_service_shop.dart';
import 'package:Sehati/view/homeprofile/home.dart';
import 'package:Sehati/view/komunitas/index_komunitas.dart';
import 'package:Sehati/models/product_model.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:Sehati/view/homeprofile/profile.dart'; 

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Future<List<ProductModel>> _products = Future.value([]);
  bool isLoading = false;
  int _currentIndex = 2; 
  
 
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      final products = await ApiServiceShop.fetchProducts();
      if (mounted) {
        setState(() {
          _products = Future.value(products);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnackBar('Error: ${e.toString()}');
        _products = Future.value([]);
      }
    }
  }

  // Helper function to safely show SnackBar
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    if (!mounted) return;
    
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Helper function to format price
  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    )}';
  }

  // Function to launch URL
  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) {
      _showSnackBar('Link produk tidak tersedia', backgroundColor: Colors.orange);
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Membuka di browser eksternal
        );
      } else {
        _showSnackBar('Tidak dapat membuka link: $url');
      }
    } catch (e) {
      _showSnackBar('Error membuka link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
           
              // App Bar with Back Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back arrow button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
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
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF1E293B),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Shop',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ),
                    // Search button
                    
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F4F4),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(4, 0),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shop Header
                      Positioned(
                        left: 29,
                        top: 20,
                        right: 29,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF9F9F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Produk Kesehatan Terpercaya",
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Products Grid
                      Positioned(
                        left: 20,
                        top: 90,
                        right: 20,
                        bottom: 20,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await _loadProducts();
                          },
                          color: const Color(0xFF4DBAFF),
                          child: FutureBuilder<List<ProductModel>>(
                            future: _products,
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
                                      const Icon(Icons.error, color: Color(0xFFFC5C9C), size: 64),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Error: ${snapshot.error}",
                                        style: const TextStyle(
                                          color: Color(0xFF1E293B),
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: _loadProducts,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4DBAFF),
                                        ),
                                        child: const Text('Refresh'),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.shopping_bag, color: Color(0xFF4DBAFF), size: 64),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Belum ada produk",
                                        style: TextStyle(
                                          color: Color(0xFF1E293B),
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              final products = snapshot.data!;
                              return GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return _buildProductCard(products[index]);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigation(),
        ),
      );
    }

    Widget _buildBottomNavigation() {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CommunityPage()),
              );
            }   else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserDataViewPage()),
              );
            }
          });
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4DBAFF),
        unselectedItemColor: const Color(0xFF4C617F),
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Komunitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      );
    }

    Widget _buildProductCard(ProductModel product) {
      return GestureDetector(
        onTap: () {
          _showProductDetail(product);
        },
        child: Container(
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
              // Product Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: _buildProductImage(product.gambar),
                  ),
                ),
              ),
              
              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.produk,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Product Description
                      Expanded(
                        child: Text(
                          product.deskripsi,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Price
                      Text(
                        _formatPrice(product.harga),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: Color(0xFF4DBAFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildProductImage(String? imageUrl) {
      if (imageUrl == null || imageUrl.isEmpty) {
        return Container(
          color: const Color(0xFFF4F4F4),
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: Color(0xFF64748B),
              size: 40,
            ),
          ),
        );
      }

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFF4F4F4),
            child: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF4DBAFF),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF4F4F4),
            child: const Center(
              child: Icon(
                Icons.broken_image,
                color: Color(0xFF64748B),
                size: 40,
              ),
            ),
          );
        },
      );
    }

    void _showProductDetail(ProductModel product) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Image
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: _buildProductImage(product.gambar),
                    ),
                  ),
                  
                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.produk,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          _formatPrice(product.harga),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            color: Color(0xFF4DBAFF),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        const Text(
                          'Deskripsi:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          product.deskripsi,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Color(0xFF64748B),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action Buttons - Button utama untuk buka link
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _launchURL(product.link); // Mengarahkan ke link produk
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4DBAFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.open_in_new,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Beli Sekarang',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Color(0xFF4DBAFF)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  'Tutup',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4DBAFF),
                                  ),
                                ),
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
        },
      );
    }
}