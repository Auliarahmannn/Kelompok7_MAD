import 'dart:convert';

// Helper function untuk parsing JSON
List<AdminOrderModel> adminOrderModelFromJson(String str) =>
    List<AdminOrderModel>.from(
        json.decode(str).map((x) => AdminOrderModel.fromJson(x)));

class AdminOrderModel {
  final int id;
  final String customerName;
  final DateTime tanggalPesan;
  final double totalHarga;
  String status; // Kita buat 'String' agar bisa diubah di UI
  final List<AdminOrderItemModel> items;

  AdminOrderModel({
    required this.id,
    required this.customerName,
    required this.tanggalPesan,
    required this.totalHarga,
    required this.status,
    required this.items,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderModel(
      id: json["id"],
      // Ambil nama customer dari relasi 'customer'
      customerName: json["customer"] != null ? json["customer"]["name"] : "N/A",
      tanggalPesan: DateTime.parse(json["tanggal_pesan"]),
      totalHarga: double.parse(json["total_harga"].toString()),
      status: json["status"],
      // Ambil list item dari relasi 'order_items'
      items: json["order_items"] != null
          ? List<AdminOrderItemModel>.from(
              json["order_items"].map((x) => AdminOrderItemModel.fromJson(x)),
            )
          : [],
    );
  }

  // Helper untuk format tanggal (bisa disesuaikan)
  String get formattedDate {
    return "${tanggalPesan.day}-${tanggalPesan.month}-${tanggalPesan.year}";
  }

  // Helper untuk format harga (bisa disesuaikan)
  String get formattedPrice {
    // Anda bisa pakai package intl jika mau lebih rapi
    return totalHarga.toStringAsFixed(0);
  }
}

class AdminOrderItemModel {
  final String productName;
  final int jumlah;
  final double harga;

  AdminOrderItemModel({
    required this.productName,
    required this.jumlah,
    required this.harga,
  });

  factory AdminOrderItemModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderItemModel(
      // Ambil nama produk dari relasi 'product'
      productName:
          json["product"] != null ? json["product"]["nama_produk"] : "Produk Dihapus",
      jumlah: json["jumlah_produk"],
      harga: double.parse(json["harga"].toString()),
    );
  }
}