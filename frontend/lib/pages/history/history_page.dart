import 'package:flutter/material.dart';
import '/layout/buttom_nav.dart';
import '/models/my_order_item_model.dart';
import '/services/order_service.dart';
import '/services/cart_service.dart';
import '/pages/cart/cart_page.dart';
import '/models/payment_method_model.dart';
import '/pages/payment/payment_detail_page.dart';

class HistoryPage extends StatefulWidget {
  final String? initialStatus;

  const HistoryPage({super.key, this.initialStatus});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<String> _tabs = ['belum_bayar', 'menunggu_konfirmasi', 'dikirim', 'selesai', 'batal']; 
  
  final Map<String, String> _tabDisplay = {
    'belum_bayar': 'Belum Bayar', // Order status 'dibayar' DAN BELUM upload bukti
    'menunggu_konfirmasi': 'Diproses', // Order status 'dibayar' DAN SUDAH upload bukti
    'dikirim': 'Dikirim',
    'selesai': 'Selesai',
    'batal': 'Dibatalkan',
  };

  // Default ke 'belum_bayar'
  String _selectedStatus = 'belum_bayar'; 

  bool _isLoading = true;
  String _error = '';
  List<MyOrderItemModel> _allMyItems = []; // Semua order non-'pending'
  List<MyOrderItemModel> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    // Jika initialStatus adalah 'dibayar', petakan ke status logika yang baru
    if (widget.initialStatus == 'dibayar') {
      _selectedStatus = 'menunggu_konfirmasi'; 
    } else {
      _selectedStatus = widget.initialStatus ?? 'belum_bayar';
    }
    _fetchMyOrders();
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _allMyItems.where((item) {
        final bool hasProof = item.proofOfPayment?.isNotEmpty == true;

        if (_selectedStatus == 'belum_bayar') {
          // KONDISI 1: Belum Bayar/Belum Upload (Ingin Dihilangkan Setelah Upload)
          // Order statusnya harus 'dibayar' DAN BELUM ada bukti
          return item.status == 'dibayar' && !hasProof;
        } else if (_selectedStatus == 'menunggu_konfirmasi') {
          // KONDISI 2: Menunggu Konfirmasi (Order akan Pindah ke Sini Setelah Upload)
          // Order statusnya harus 'dibayar' DAN SUDAH ada bukti
          return item.status == 'dibayar' && hasProof;
        } else {
          // KONDISI 3: Status lain (dikirim, selesai, batal)
          return item.status == _selectedStatus;
        }
      }).toList();
    });
  }

  Future<void> _fetchMyOrders() async {
    try {
      final items = await OrderService.getMyOrderItems();
      setState(() {
        _allMyItems = items.where((item) => item.status != 'pending').toList();
        _filterItems(); 
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $_error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _confirmCancelOrder(MyOrderItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: Text('Anda yakin ingin membatalkan pesanan #${item.orderId} ini? Tindakan ini akan mengembalikan stok produk.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Kembali false
            child: const Text('Tidak', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Kembali true
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membatalkan pesanan...'), duration: Duration(seconds: 1)),
      );

      try {
        final success = await OrderService.cancelOrder(item.orderId);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar(); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesanan berhasil dibatalkan.'), backgroundColor: Colors.green),
          );
          _fetchMyOrders(); // Refresh list
        } else {
          throw Exception('Gagal membatalkan di server.');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar(); 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pembatalan gagal: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Background image 
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
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // App Bar 
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
                        'Pesanan Saya',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildFilterTabs(),

                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    // 8. Tampilkan loading, error, atau list
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    // Agar bisa di-scroll ke samping jika tidak muat
    return Container(
      height: 40, // Beri tinggi agar konsisten
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: 8), // Jarak antar kotak
        itemBuilder: (context, index) {
          final status = _tabs[index];
          final displayName = _tabDisplay[status]!;
          final bool isSelected = (_selectedStatus == status);

          const Color activeColor = Color(0xFF5D7F5F);
          final Color unselectedColor = Colors.grey[200]!;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = status;
                _filterItems();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : unselectedColor,
                borderRadius: BorderRadius.circular(20), // Bikin rounded
              ),
              child: Center(
                child: Text(
                  displayName,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : activeColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget untuk konten list (Biarkan sama)
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5D7F5F)),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Oops! Terjadi kesalahan:\n$_error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[700]),
          ),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada pesanan dengan status "${_tabDisplay[_selectedStatus]}".',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    // Tampilkan list
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildOrderCard(context, item: item),
        );
      },
    );
  }

  // _buildOrderCard
  Widget _buildOrderCard(
    BuildContext context, {
    required MyOrderItemModel item,
  }) {
    final String productName = item.namaProduk;
    final String imageUrl = item.assetImagePath;
    final String jumlah = 'Jumlah : ${item.jumlahProduk}';
    final String hargaSatuan = 'Harga : ${item.formattedPrice}';
    final int totalPrice = (item.harga * item.jumlahProduk).toInt();
    
    // Status visual tergantung apakah bukti sudah diupload atau belum
    bool hasProof = item.proofOfPayment?.isNotEmpty == true;
    
    String currentLogicStatus = _selectedStatus; 

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imageUrl,
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
                        productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jumlah,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hargaSatuan,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total : Rp. ${_formatPrice(totalPrice)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
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
          
          // --- Aksi untuk status yang sedang aktif (belum_bayar & menunggu_konfirmasi) ---
          if (currentLogicStatus == 'belum_bayar' || currentLogicStatus == 'menunggu_konfirmasi')
             Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tampilkan status menunggu/belum upload
                  Text(
                    currentLogicStatus == 'menunggu_konfirmasi'
                      ? 'Bukti telah diupload. Menunggu verifikasi Admin.'
                      : 'Segera lakukan pembayaran dan upload bukti.',
                    style: TextStyle(
                      color: currentLogicStatus == 'menunggu_konfirmasi' ? Colors.blue[600] : Colors.red[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // 1. Batalkan Pesanan (Outlined/Destructive)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmCancelOrder(item), 
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Batalkan Pesanan',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 2. Bayar Sekarang/Lihat Bukti (Elevated) -> ke detail payment
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigasi ke halaman detail pembayaran 
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => PaymentDetailPage(
                                  orderId: item.orderId,
                                  totalPrice: totalPrice, 
                                  itemsToCheckout: const [], 
                                  selectedPaymentMethod: PaymentMethodModel(id: 1, metode: "Transfer Bank"), 
                                ),
                              ),
                            ).then((_) => _fetchMyOrders()); // Refresh setelah kembali
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D7F5F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: Text(
                            currentLogicStatus == 'menunggu_konfirmasi' ? 'Lihat Bukti' : 'Bayar Sekarang',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          if (item.status == 'selesai')
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showRatingDialog(context, productName);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Nilai',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _handleBuyAgain(context, item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D7F5F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Beli Lagi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (item.status == 'dikirim')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showKonfirmasiDiterima(item);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A574),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 10,
                      ),
                      minimumSize: const Size(0, 32), // tinggi tombol kecil
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                    ),
                    child: const Text(
                      'Pesanan Diterima',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
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

  // _showRatingDialog 
  void _showRatingDialog(BuildContext context, String productName) {
    int selectedRating = 0;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Beri Penilaian',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ulasan (Opsional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tulis ulasan Anda di sini...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF5D7F5F),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedRating > 0
                      ? () {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Terima kasih! Anda memberi rating $selectedRating bintang',
                              ),
                              backgroundColor: const Color(0xFF5D7F5F),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D7F5F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text(
                    'Kirim',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // _handleBuyAgain
  void _handleBuyAgain(BuildContext context, MyOrderItemModel item) {
    bool isAdding = false; // State untuk loading di dialog

    showDialog(
      context: context,
      barrierDismissible: false, // Cegah tutup dialog saat loading
      builder: (BuildContext dialogContext) {
        // Gunakan StatefulBuilder agar dialog bisa update state loading-nya
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Beli Lagi'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambahkan item ini ke keranjang?',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.namaProduk,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D7F5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jumlah: ${item.jumlahProduk}', // Tampilkan jumlah
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isAdding
                      ? null
                      : () {
                          // Nonaktifkan saat loading
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isAdding
                      ? null
                      : () async {
                          // Nonaktifkan saat loading
                          // 1. Set loading
                          setDialogState(() {
                            isAdding = true;
                          });

                          try {
                            // 2. Panggil CartService
                            bool success = await CartService.addToCart(
                              productId: item.productId, // Kirim productId
                              quantity: item.jumlahProduk, // Kirim jumlah
                            );

                            if (success && context.mounted) {
                              Navigator.of(dialogContext).pop(); // Tutup dialog

                              // 3. Tampilkan notifikasi sukses
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Produk ditambahkan ke keranjang!',
                                  ),
                                  backgroundColor: Color(0xFF5D7F5F),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // 4. Navigasi ke Halaman Keranjang
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CartPage(),
                                ),
                              );
                            } else {
                              throw Exception('Gagal menambah ke keranjang');
                            }
                          } catch (e) {
                            // 5. Handle Error
                            if (context.mounted) {
                              Navigator.of(dialogContext).pop(); // Tutup dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D7F5F),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      isAdding // Tampilkan loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Ya, Sewa Lagi',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showKonfirmasiDiterima(MyOrderItemModel item) {
    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Cegah tutup dialog saat loading
      // Gunakan StatefulBuilder agar bisa update loading di dialog
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Konfirmasi Pesanan'),
              content: Text(
                'Anda yakin sudah menerima "${item.namaProduk}"?',
                style: const TextStyle(fontSize: 14),
              ),
              actions: [
                TextButton(
                  // ignore: sort_child_properties_last
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                  // Nonaktifkan saat loading
                  onPressed: isUpdating
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D7F5F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Tampilkan loading jika 'isUpdating'
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  // ignore: sort_child_properties_last
                  child: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Ya, Sudah Diterima',
                          style: TextStyle(color: Colors.white),
                        ),

                  // Logika onPressed diubah
                  onPressed: isUpdating
                      ? null
                      : () async {
                          // 1. Set loading
                          setDialogState(() {
                            isUpdating = true;
                          });

                          try {
                            // 2. Panggil API
                            // 'item' adalah MyOrderItemModel, kita butuh 'orderId'-nya
                            bool success =
                                await OrderService.confirmOrderReceived(
                                  item.orderId,
                                );

                            if (success && context.mounted) {
                              Navigator.of(dialogContext).pop(); // Tutup dialog

                              // 3. Tampilkan notifikasi sukses
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Berhasil! Status pesanan diperbarui ke "Selesai".',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // 4. Refresh halaman
                              _fetchMyOrders();
                            } else {
                              throw Exception(
                                'Gagal mengupdate status dari server',
                              );
                            }
                          } catch (e) {
                            // 5. Handle Error
                            if (context.mounted) {
                              Navigator.of(dialogContext).pop(); // Tutup dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // _formatPrice (Biarkan sama)
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
