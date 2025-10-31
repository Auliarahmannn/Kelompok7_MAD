import 'package:intl/intl.dart';

class MyOrderItemModel {
  final int orderItemId;
  final int orderId;
  final int productId;
  final String namaProduk;
  final int jumlahProduk;
  final double harga;
  final String foto; 
  final String status;

  MyOrderItemModel({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.namaProduk,
    required this.jumlahProduk,
    required this.harga,
    required this.foto,
    required this.status,
  });

  factory MyOrderItemModel.fromJson(Map<String, dynamic> json) {
    return MyOrderItemModel(
      orderItemId: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      namaProduk: json['nama_produk'] ?? '',
      jumlahProduk: json['jumlah_produk'] ?? 0,
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      foto: json['foto'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  // Helper untuk format harga satuan
  String get formattedPrice {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return format.format(harga);
  }

  // Helper untuk format total harga per item
  String get formattedTotalPrice {
    final total = harga * jumlahProduk;
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return format.format(total);
  }
  
  // URL dari server (biarkan saja, mungkin berguna nanti)
  String get validImageUrl {
    const String imageBaseUrl = 'http://10.0.2.2:8000/storage/products/';
    if (foto.startsWith('http')) {
      return foto;
    }
    if (foto.isEmpty) {
        return 'https://via.placeholder.com/150';
    }
    return '$imageBaseUrl$foto';  
  }

  // Path gambar lokal (asset)
  String get assetImagePath {
    // Sesuaikan path ini dengan folder assets kamu
    return 'assets/images/${foto.isNotEmpty ? foto : "default.png"}';
  }
}