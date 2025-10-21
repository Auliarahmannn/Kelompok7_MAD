class Products {
  final int id;
  final String namaProduk;
  final String deskripsi;
  final String foto;
  final double harga;
  final int stok;

  Products({
    required this.id,
    required this.namaProduk,
    required this.deskripsi,
    required this.foto,
    required this.harga,
    required this.stok,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'] ?? 0,
      namaProduk: json['nama_produk'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      foto: json['foto'] ?? '',
      harga: double.tryParse(json['harga'].toString())?.roundToDouble() ?? 0.0,
      stok: json['stok'] ?? 0,
    );
  }
}
