import 'package:flutter/material.dart';
import 'package:campgear/models/cart_model.dart'; 
import 'package:campgear/services/cart_service.dart'; // 
import '/widgets/custom_button.dart';
import '/pages/payment/payment_page.dart';
import '/layout/buttom_nav.dart';
import 'package:intl/intl.dart'; 

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<CartItemModel>> _cartFuture;
  bool _selectAll = false;

  // Set untuk menyimpan item yang sedang di-update (loading)
  final Set<int> _loadingItems = {};

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  // Fungsi untuk memuat atau me-refresh data keranjang
  void _loadCartData() {
    setState(() {
      _cartFuture = CartService.getCart();
    });
  }

  // Fungsi untuk memformat harga (Anda sudah punya ini, tapi kita buat static)
  String _formatPrice(int price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(price).replaceAll(',', '.');
  }

  // Fungsi untuk menghitung total HANYA dari item yang terseleksi
  int _calculateTotal(List<CartItemModel> items) {
    double total = 0.0;
    for (var item in items) {
      if (item.isSelected) {
        total += (item.price * item.quantity);
      }
    }
    return total.toInt();
  }

  // Fungsi untuk menangani update kuantitas
  Future<void> _updateQuantity(CartItemModel item, int newQuantity) async {
    if (_loadingItems.contains(item.orderItemId)) return; // Hindari double-tap

    // Batasi kuantitas 1 s/d stok
    if (newQuantity < 1) {
      // Tampilkan dialog konfirmasi hapus
      _confirmRemoveItem(item);
      return;
    }
    if (newQuantity > item.productStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok maksimal ${item.productStock} unit')),
      );
      return;
    }

    setState(() {
      _loadingItems.add(item.orderItemId); // Mulai loading
    });

    try {
      bool success = await CartService.updateQuantity(
        orderItemId: item.orderItemId,
        quantity: newQuantity,
      );
      if (success) {
        _loadCartData(); // Refresh seluruh keranjang
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _loadingItems.remove(item.orderItemId); // Selesai loading
      });
    }
  }

  // Fungsi untuk menghapus item
  Future<void> _removeItem(CartItemModel item) async {
    if (_loadingItems.contains(item.orderItemId)) return;

    setState(() {
      _loadingItems.add(item.orderItemId);
    });

    try {
      bool success = await CartService.removeFromCart(
        orderItemId: item.orderItemId,
      );
      if (success) {
        _loadCartData(); // Refresh
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _loadingItems.remove(item.orderItemId);
      });
    }
  }

  // Dialog konfirmasi hapus
  void _confirmRemoveItem(CartItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Item'),
        content: Text(
          'Anda yakin ingin menghapus ${item.productName} dari keranjang?',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _removeItem(item);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background header (tetap sama)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              // ... styling Anda ...
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header (tetap sama)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BottomNav(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Keranjang Saya',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Content - Ganti dengan FutureBuilder
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: FutureBuilder<List<CartItemModel>>(
                      future: _cartFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              'Keranjang Anda masih kosong.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        // Data berhasil dimuat
                        final cartItems = snapshot.data!;
                        int totalPrice = _calculateTotal(cartItems);

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildCartItem(item),
                                  );
                                },
                              ),
                            ),

                            // Bottom checkout section
                            _buildCheckoutSection(cartItems, totalPrice),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Checkout Bar (diekstrak dari FutureBuilder)
  Widget _buildCheckoutSection(List<CartItemModel> items, int totalPrice) {
    // Cek apakah semua item terseleksi
    _selectAll = items.isNotEmpty && items.every((item) => item.isSelected);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: (value) {
                      setState(() {
                        _selectAll = value ?? false;
                        for (var item in items) {
                          item.isSelected = _selectAll;
                        }
                      });
                    },
                    activeColor: const Color(0xFF5D7F5F),
                  ),
                  const Text(
                    'Semua',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      'Rp. ${_formatPrice(totalPrice)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4A574),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          CustomButton(
            text: 'Check out',
            onPressed: totalPrice > 0
                ? () {
                    // Filter item yang di-checkout
                    List<CartItemModel> itemsToCheckout = items
                        .where((item) => item.isSelected)
                        .toList();

                    // TODO: Kirim `itemsToCheckout` dan `totalPrice` ke PaymentPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaymentPage(
                              totalPrice: totalPrice,
                              itemsToCheckout: itemsToCheckout,
                              ),
                      ),
                    );
                  }
                : () {}, // Tombol disable jika total 0
            width: 120,
            height: 48,
          ),
        ],
      ),
    );
  }

  // Widget untuk item keranjang
  Widget _buildCartItem(CartItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Opacity(
        // Beri efek redup jika sedang loading
        opacity: _loadingItems.contains(item.orderItemId) ? 0.5 : 1.0,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: item.isSelected,
                    onChanged: (value) {
                      setState(() {
                        item.isSelected = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF5D7F5F),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item.assetImagePath, // Gunakan path asset lokal
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName, // Gunakan data dari model
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.formattedPrice, // Gunakan data dari model
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4A574),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _updateQuantity(item, item.quantity - 1),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[400]!,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.remove, size: 16),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      _updateQuantity(item, item.quantity + 1),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[400]!,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.add, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // TODO: Anda bisa menambahkan logika voucher/gratis ongkir di sini
            // jika API Anda menyediakannya.
          ],
        ),
      ),
    );
  }
}
