class CartItemModel {
  final int orderId;
  final int orderItemId;
  final int quantity;
  final double price;
  final int productId;
  final String productName;
  final String productImage;
  final int productStock;

  // Variabel lokal untuk UI
  bool isSelected;

  CartItemModel({
    required this.orderId,
    required this.orderItemId,
    required this.quantity,
    required this.price,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productStock,
    this.isSelected = false, // Default tidak terseleksi
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      orderId: json['order_id'] ?? 0,
      orderItemId: json['order_item_id'] ?? 0,
      quantity: json['jumlah_produk'] ?? 0,
      price: double.tryParse(json['harga'].toString()) ?? 0.0,
      productId: json['product_id'] ?? 0,
      productName: json['nama_produk'] ?? '',
      productImage: json['product_image'] ?? '',
      productStock: json['product_stock'] ?? 0,
    );
  }

  // \Format harga ke Rupiah
  String get formattedPrice {
    final priceStr = price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp. $priceStr';
  }

  // 🔹 URL gambar dari backend
  String get validImageUrl {
    const String imageBaseUrl = 'http://10.0.2.2:8000/storage/products/';
    if (productImage.startsWith('http')) {
      return productImage;
    }
    return '$imageBaseUrl$productImage';
  }

  // Tambahan BARU: path gambar lokal (asset)
  String get assetImagePath {
    // Misal kamu simpan di assets/images/
    return 'assets/images/${productImage.isNotEmpty ? productImage : "default.png"}';
  }
}
