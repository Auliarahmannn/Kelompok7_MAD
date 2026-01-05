import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/models/cart_model.dart';
import '/models/user_model.dart';
import '/models/payment_method_model.dart';
import '/services/user_service.dart';
import '/services/payment_method_service.dart';
import '/widgets/custom_button.dart';
import 'payment_detail_page.dart';
import '../../services/order_service.dart';
import '../../pages/profile/profile_update.dart';

// --- Model untuk Opsi Pengiriman ---
class ShippingOption {
  final String name;
  final int price;
  final String eta; 
  final String description;

  ShippingOption({
    required this.name,
    required this.price,
    required this.eta,
    required this.description,
  });
}

// --- Halaman Placeholder untuk Edit Alamat ---
class EditAddressPage extends StatelessWidget {
  final UserModel user;
  const EditAddressPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Alamat')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Halaman untuk mengedit alamat ${user.name}'),
            SizedBox(height: 20),
            CustomButton(
              text: 'Simpan',
              onPressed: () {
                // Kirim 'true' untuk menandakan ada perubahan
                Navigator.pop(context, true); 
              },
            ),
          ],
        ),
      ),
    );
  }
}
// ------------------------------------------

class PaymentPage extends StatefulWidget {
  final int totalPrice;
  final List<CartItemModel> itemsToCheckout;

  const PaymentPage({
    super.key,
    required this.totalPrice,
    required this.itemsToCheckout,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Future<List<PaymentMethodModel>> _paymentMethodsFuture;
  late Future<UserModel> _userFuture;
  int? _selectedPaymentMethodId;
  PaymentMethodModel? _selectedPaymentMethod;
  
  // State untuk tombol checkout/loading
  bool _isProcessingCheckout = false; 

  // --- State Baru ---
  bool _useProtection = true;
  static const int protectionFee = 2700; // Biaya proteksi
  String _sellerNote = ''; // Catatan untuk penjual

  final List<ShippingOption> _shippingOptions = [
    ShippingOption(
      name: 'Hemat Kargo',
      price: 0,
      eta: 'Garansi tiba 21 - 24 Okt',
      description: 'Kamu mendapatkan gratis ongkir!',
    ),
    ShippingOption(
      name: 'Reguler',
      price: 15000,
      eta: 'Tiba 20 - 22 Okt',
      description: 'Pengiriman reguler oleh kurir.',
    ),
    ShippingOption(
      name: 'Next Day',
      price: 25000,
      eta: 'Tiba 19 Okt',
      description: 'Pengiriman super cepat.',
    ),
  ];
  late ShippingOption _selectedShipping;
  // --------------------

  @override
  void initState() {
    super.initState();
    _paymentMethodsFuture = PaymentMethodService.getPaymentMethods();
    _userFuture = UserService.getProfile();
    _selectedShipping = _shippingOptions[0]; // Set default pengiriman
  }

  String _formatPrice(int price) {
    if (price == 0) return 'Gratis'; // Tampilkan 'Gratis' jika harga 0
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(price).replaceAll(',', '.');
  }

  Future<void> _handleCheckout() async {
    if (_selectedPaymentMethodId == null || _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih metode pembayaran dahulu.')),
      );
      return;
    }

    int finalTotal = widget.totalPrice;
    if (_useProtection) {
      finalTotal += protectionFee;
    }
    finalTotal += _selectedShipping.price;
    
    setState(() => _isProcessingCheckout = true);

    try {
      // 1. Panggil Service Checkout
      final result = await OrderService.checkout(
        items: widget.itemsToCheckout,
        paymentMethodId: _selectedPaymentMethod!.id,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        // 2. Ambil Order ID dari respons
        final int newOrderId = result['data']['order_id'];
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checkout berhasil, lanjutkan ke detail pembayaran.'),
            backgroundColor: Color(0xFF5D7F5F),
          ),
        );
        
        // 3. Navigasi ke PaymentDetailPage dengan orderId
        Navigator.pushReplacement( 
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailPage(
              totalPrice: finalTotal, 
              itemsToCheckout: widget.itemsToCheckout,
              selectedPaymentMethod: _selectedPaymentMethod!,
              orderId: newOrderId, // Meneruskan orderId yang baru dibuat
            ),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Checkout gagal.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Checkout: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessingCheckout = false);
    }
  }

  // --- Fungsi Baru: Edit Alamat ---
  Future<void> _editAddress(UserModel currentUser) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // Ganti ke ProfileUpdatePage dan tambahkan autoFocusAddress
        builder: (context) => ProfileUpdatePage(
          user: currentUser,
          autoFocusAddress: true, 
        ),
      ),
    );

    // Jika hasil pop adalah 'true' (ada perubahan), refresh data user
    if (result == true) {
      setState(() {
        _userFuture = UserService.getProfile();
      });
    }
  }

  // --- Fungsi Baru: Tampilkan Dialog Catatan ---
  Future<void> _showSellerNoteDialog() async {
    final TextEditingController noteController =
        TextEditingController(text: _sellerNote);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pesan untuk Penjual'),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: 'Tinggalkan catatan (opsional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _sellerNote = noteController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // --- Fungsi Baru: Tampilkan Modal Opsi Pengiriman ---
  Future<void> _showShippingOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // Gunakan StatefulBuilder agar modal bisa update
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Opsi Pengiriman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ..._shippingOptions.map((option) { // Loop opsi
                    return RadioListTile<ShippingOption>(
                      title: Text(option.name),
                      subtitle: Text(
                          '${option.eta} (${_formatPrice(option.price)})'),
                      value: option,
                      groupValue: _selectedShipping,
                      onChanged: (value) {
                        setState(() { // Update state utama
                          _selectedShipping = value!;
                        });
                        modalSetState(() {}); // Update modal
                        Navigator.pop(context); // Tutup modal
                      },
                      activeColor: Color(0xFF5D7F5F),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- Hitung Total Harga Dinamis ---
    int finalTotal = widget.totalPrice;
    if (_useProtection) {
      finalTotal += protectionFee;
    }
    finalTotal += _selectedShipping.price;
    // ---------------------------------

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
              // ... (styling background)
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
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.5),
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
                    // ... (styling header)
                     children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
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
                        'Pembayaran',
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
                      color: Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ### ALAMAT DINAMIS (Bisa Diklik) ###
                          GestureDetector( // <-- DIBUNGKUS GESTUREDETECTOR
                            onTap: () {
                              // Cek jika data user sudah ada
                              _userFuture.then((user) {
                                _editAddress(user);
                              }).catchError((e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal memuat data user')),
                                );
                              });
                            },
                            child: FutureBuilder<UserModel>(
                              future: _userFuture,
                              builder: (context, snapshot) {
                                // ... (Tampilan loading dan error tetap sama)
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                if (snapshot.hasError || !snapshot.hasData) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('Gagal memuat data alamat.'),
                                  );
                                }

                                // Tampilan jika berhasil
                                final user = snapshot.data!;
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${user.name} (${user.email})',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user.address ??
                                                  'Alamat belum diatur.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right,
                                          color: Colors.grey[600]),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ### PRODUK DINAMIS ###
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: widget.itemsToCheckout.map((item) {
                                return _buildProductItem(item);
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ### FITUR PROTEKSI ###
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Padding dikurangi
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _useProtection,
                                  onChanged: (value) {
                                    setState(() {
                                      _useProtection = value ?? false;
                                    });
                                  },
                                  activeColor: Color(0xFF5D7F5F),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Proteksi Kerusakan +',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      // ... (Deskripsi proteksi)
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatPrice(protectionFee), // Harga dinamis
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(width: 8) // Beri jarak
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ### FITUR PESAN & OPSI (Fungsional) ###
                          _buildClickableRow(
                            'Pesan Untuk Penjual',
                            // Tampilkan pesan jika ada, jika tidak, tampilkan placeholder
                            _sellerNote.isNotEmpty ? _sellerNote : 'Tinggalkan Pesan',
                            onTap: _showSellerNoteDialog, // Panggil dialog
                            maxLines: 1, // Batasi 1 baris
                          ),
                          
                          const SizedBox(height: 8),
                          
                          _buildClickableRow(
                            'Opsi Pengiriman',
                            // Tampilkan opsi terpilih
                            '${_selectedShipping.name} (${_formatPrice(_selectedShipping.price)})',
                            onTap: _showShippingOptions, // Panggil modal
                          ),
                          
                          const SizedBox(height: 12),

                          // ### INFO PENGIRIMAN (Dinamis) ###
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedShipping.name, // Nama dari state
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.local_shipping,
                                        size: 18, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedShipping.eta, // ETA dari state
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatPrice(_selectedShipping.price), // Harga dari state
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedShipping.description, // Deskripsi dari state
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF5D7F5F),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ### METODE PEMBAYARAN DINAMIS ###
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Metode Pembayaran',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FutureBuilder<List<PaymentMethodModel>>(
                                  future: _paymentMethodsFuture,
                                  builder: (context, snapshot) {
                                    // ... (Kode FutureBuilder tetap sama)
                                     if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return const Center(child: Text('Gagal memuat metode. Cek koneksi & API.'));
                                    }
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return Center(child: Text('Metode pembayaran tidak tersedia.'));
                                    }

                                    final methods = snapshot.data!;
                                    
                                    if (_selectedPaymentMethodId == null && methods.isNotEmpty) {
                                      // Set default jika belum ada yang terpilih
                                      Future.microtask(() {
                                        setState(() {
                                          _selectedPaymentMethodId = methods.first.id;
                                          _selectedPaymentMethod = methods.first;
                                        });
                                      });
                                    }

                                    return Column(
                                      children: methods.map((method) {
                                        return RadioListTile<int>(
                                          title: Text(method.metode),
                                          subtitle: Text(method.deskripsi ?? ''),
                                          value: method.id,
                                          groupValue: _selectedPaymentMethodId,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedPaymentMethodId = value;
                                              _selectedPaymentMethod = method;
                                            });
                                          },
                                          activeColor: Color(0xFF5D7F5F),
                                          controlAffinity: ListTileControlAffinity.trailing,
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            // Gunakan finalTotal yang sudah dihitung
                            _formatPrice(finalTotal), 
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4A574),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      CustomButton(
                        // Ganti teks dan status loading
                        text: _isProcessingCheckout ? 'Memproses...' : 'Check out',
                        onPressed: _isProcessingCheckout ? null : _handleCheckout,
                        width: 140,
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

  // Widget helper untuk build item produk
  Widget _buildProductItem(CartItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        // ... (Kode _buildProductItem tetap sama)
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.assetImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
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
                  item.productName, 
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.formattedPrice,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A574),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'x${item.quantity}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper _buildClickableRow
  Widget _buildClickableRow(String title, String subtitle,
      {required VoidCallback onTap, int maxLines = 1}) { // Tambah maxLines
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Expanded( // Tambahkan Expanded
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded( // Tambahkan Expanded
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.end,
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}