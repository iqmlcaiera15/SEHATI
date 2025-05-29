// lib/models/product_model.dart
class ProductModel {
  final int? id;
  final String produk;
  final String deskripsi;
  final double harga;
  final String? gambar; // URL atau path ke gambar
  final String? link; // URL link untuk mengarahkan ke web
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    this.id,
    required this.produk,
    required this.deskripsi,
    required this.harga,
    this.gambar,
    this.link,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parsedHarga;
    if (json['harga'] is String) {
      parsedHarga = double.tryParse(json['harga'] ?? '0.0') ?? 0.0;
    } else if (json['harga'] is num) {
      parsedHarga = (json['harga'] as num).toDouble();
    } else {
      parsedHarga = 0.0; // Default jika tipe tidak dikenali atau null
    }

    return ProductModel(
      id: json['id'] as int?, // Pastikan backend mengirimkan integer atau null
      produk: json['produk'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      harga: parsedHarga,
      gambar: json['gambar'] as String?,
      link: json['link'] as String?, // Menambahkan parsing kolom link
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produk': produk,
      'deskripsi': deskripsi,
      'harga': harga,
      'gambar': gambar,
      'link': link, // Menambahkan link ke dalam toJson
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}