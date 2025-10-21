import 'package:flutter/material.dart';
import '/widgets/custom_button.dart';
import '/pages/payment/payment_page.dart';
import '/layout/buttom_nav.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _selectAll = false;
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      name: 'Tenda Decathlon Eiger | Muat Hingga 5 Orang',
      price: 180000,
      quantity: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1622260614153-03223fb72052?w=400',
      isSelected: true,
      freeShipping: true,
    ),
    CartItem(
      id: '2',
      name: 'Carrier Eiger 70L | Warna bisa request',
      price: 50000,
      quantity: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1622260614153-03223fb72052?w=400',
      isSelected: false,
      hasVoucher: true,
      voucherAmount: 30000,
      freeShipping: true,
    ),
    CartItem(
      id: '3',
      name: 'Jaket Arei | Triple Layer Warna Merah',
      price: 30000,
      quantity: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
      isSelected: false,
      freeShipping: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int totalPrice = _calculateTotal();

    return Scaffold(
      body: Stack(
        children: [
          // Background header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
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
                // Header
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

                // Content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ..._cartItems
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildCartItem(item),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),

                // Bottom checkout section
                Container(
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
                    children: [
                      Checkbox(
                        value: _selectAll,
                        onChanged: (value) {
                          setState(() {
                            _selectAll = value ?? false;
                            for (var item in _cartItems) {
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
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                      const SizedBox(width: 16),
                      CustomButton(
                        text: 'Check out',
                        onPressed: totalPrice > 0
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PaymentPage(totalPrice: totalPrice),
                                  ),
                                );
                              }
                            : () {},
                        width: 120,
                        height: 48,
                      ),
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

  Widget _buildCartItem(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
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
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
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
                        item.name,
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
                            'Rp. ${_formatPrice(item.price)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4A574),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (item.quantity > 1) item.quantity--;
                                  });
                                },
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
                                onTap: () {
                                  setState(() {
                                    item.quantity++;
                                  });
                                },
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

          if (item.hasVoucher) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Voucher Discount s/d Rp. ${_formatPrice(item.voucherAmount)} syarat ketentuan berlaku',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (item.freeShipping) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gratis Ongkir s/d Rp. 10.000 dengan min. belanja Rp.0 khusus daerah JABODETABEK',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _calculateTotal() {
    return _cartItems
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class CartItem {
  final String id;
  final String name;
  final int price;
  int quantity;
  final String imageUrl;
  bool isSelected;
  final bool hasVoucher;
  final int voucherAmount;
  final freeShipping;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.isSelected = false,
    this.hasVoucher = false,
    this.voucherAmount = 0,
    this.freeShipping = false,
  });
}
