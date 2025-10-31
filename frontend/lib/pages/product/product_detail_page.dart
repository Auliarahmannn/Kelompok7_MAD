import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/pages/cart/cart_page.dart';
import '/services/cart_service.dart';
import '/models/cart_model.dart';
import '/pages/payment/payment_page.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  final String nama;
  final String deskripsi;
  final int stok;
  final double harga;
  final String foto;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.nama,
    required this.deskripsi,
    required this.stok,
    required this.harga,
    required this.foto,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isAddingToCart = false;
  bool _isBuyingNow = false;

  String formatRupiah(double harga) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return formatter.format(harga);
  }

  Future<void> _handleAddToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      bool success = await CartService.addToCart(
        productId: widget.productId, // pakai 'widget.'
        quantity: 1, // default tambah 1
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Produk ditambahkan ke keranjang',
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFFD4A574),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal menambah ke keranjang',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll(
                'Exception: ',
                '',
              ),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<void> _handleBuyNow() async {
    setState(() {
      _isBuyingNow = true;
    });

    try {
      // Tambahkan item ke keranjang
      bool success = await CartService.addToCart(
        productId: widget.productId,
        quantity: 1,
      );

      if (success && context.mounted) {
        // Ambil SEMUA item di keranjang untuk dapat 'order_item_id'
        final allCartItems = await CartService.getCart();

        // Cari item yang baru saja kita tambahkan
        // Kita cari item terakhir yang cocok (paling baru)
        final itemToCheckout = allCartItems.lastWhere(
          (item) => item.productId == widget.productId,
        );

        // Siapkan data untuk PaymentPage
        final List<CartItemModel> items = [itemToCheckout];
        final int totalPrice = (itemToCheckout.price * itemToCheckout.quantity).toInt();

        // Navigasi ke PaymentPage
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(
                totalPrice: totalPrice,
                itemsToCheckout: items,
              ),
            ),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memproses pinjaman'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBuyingNow = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan gambar produk
                Stack(
                  children: [
                    Container(
                      height: 350,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Image.asset(
                        widget.foto,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Tombol back dan cart
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CartPage(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Informasi produk
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // 6. Ganti 'nama' menjadi 'widget.nama', dst.
                        widget.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatRupiah(widget.harga)}/Hari',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD4A574),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol aksi
                      Row(
                        children: [
                          GestureDetector(
                            // Panggil fungsi _handleAddToCart
                            onTap: _isAddingToCart ? null : _handleAddToCart,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A574),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _isAddingToCart
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5D7F5F),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                // Nonaktifkan tombol saat loading
                                disabledBackgroundColor: Colors.grey[400],
                              ),
                              // Panggil fungsi _handleBuyNow
                              // Nonaktifkan jika salah satu sedang loading
                              onPressed: (_isAddingToCart || _isBuyingNow) 
                                  ? null 
                                  : _handleBuyNow,
                              child: _isBuyingNow
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Pinjam Sekarang',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Spesifikasi Produk
                      const Text(
                        'Spesifikasi Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildSpecRow('Kategori', 'CampGear > Tenda dan Tempat Tidur'),
                      _buildSpecRow('Stok', widget.stok.toString()),
                      _buildSpecRow('Merek', 'Eiger'),

                      const SizedBox(height: 24),

                      // Deskripsi Produk
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        widget.deskripsi,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}