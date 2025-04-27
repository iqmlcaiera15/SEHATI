class Barang {
  final int idBarang;
  final String kode;
  final String namaBarang;
  final int harga;

  Barang({
    required this.idBarang,
    required this.kode,
    required this.namaBarang,
    required this.harga,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      idBarang: json['id_barang'],
      kode: json['kode'],
      namaBarang: json['nama_barang'],
      harga: json['harga'],
    );
  }
}
