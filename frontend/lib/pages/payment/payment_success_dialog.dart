import 'package:flutter/material.dart';
import '/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import '/models/product_model.dart';
import '/services/product_service.dart';
import '/pages/history/history_page.dart'; 

class PaymentSuccessDialog extends StatefulWidget {
  const PaymentSuccessDialog({super.key});

  @override
  State<PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<PaymentSuccessDialog> {
  late Future<List<Products>> _productsFuture;
  List<Products> _carrierProducts = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.getProducts().then((allProducts) {
      if (mounted) { 
        setState(() {
          _carrierProducts = allProducts
              .where((p) => p.namaProduk.toLowerCase().contains('carrier'))
              .toList();
        });
      }
      return allProducts;
    });
  }

  String formatRupiah(double harga) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return formatter.format(harga);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pembayaran berhasil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Lihat Pesanan Saya',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const HistoryPage(initialStatus: 'dibayar'),
                  ),
                  (route) => false, // hapus semua halaman sebelumnya
                );
              },
              icon: Icons.receipt_long,
            ),
            const SizedBox(height: 16),
            // Product recommendations
            const Text(
              'Rekomendasi Carrier',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: FutureBuilder<List<Products>>(
                // Sekarang _productsFuture sudah terdefinisi
                future: _productsFuture,
                builder: (context, snapshot) {
                  // Tampilkan loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Color(0xFF5D7F5F),
                    ));
                  }
                  
                  // Tampilkan error jika ada
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Gagal memuat',
                            style: TextStyle(fontSize: 10)));
                  }

                  // Tampilkan jika tidak ada carrier
                  // Sekarang _carrierProducts sudah terdefinisi
                  if (_carrierProducts.isEmpty) {
                    return const Center(
                        child: Text('Tidak ada rekomendasi',
                            style: TextStyle(fontSize: 10)));
                  }

                  // Tampilkan list produk dinamis
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _carrierProducts.length,
                    itemBuilder: (context, index) {
                      final product = _carrierProducts[index];
                      // Panggil _buildProductCard dengan data dinamis
                      return _buildProductCard(product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Products product) {
    // Ambil path gambar dari aset, sama seperti di ProductGrid
    final String imagePath =
        'assets/images/${product.foto.isNotEmpty ? product.foto : 'default.png'}';
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Error builder jika gambar aset tidak ditemukan
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.namaProduk,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            // Sekarang formatRupiah sudah terdefinisi
            formatRupiah(product.harga),
            style: const TextStyle(fontSize: 9, color: Color(0xFF5D7F5F)),
          ),
        ],
      ),
    );
  }
} 