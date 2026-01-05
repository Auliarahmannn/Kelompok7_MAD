import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/admin_drawer.dart';
import '/models/admin_order_model.dart';
import '/services/order_service.dart';
import '/services/auth_service.dart'; 

// --- Model Tambahan untuk Detail Pembayaran Admin ---
class PaymentDetailModel {
  final int id;
  final String metode;
  final String? proofPath;
  final String? proofUrl; 
  final String status;
  final String? validationNote;

  PaymentDetailModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        metode = json['metode'],
        proofPath = json['proof_path'],
        proofUrl = json['proof_url'], 
        status = json['status'],
        validationNote = json['validation_note'];
}

// ----------------------------------------------------

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  String _selectedFilter = 'Dibayar';
  List<AdminOrderModel> _allOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Base URL dari OrderService
  static const String _baseUrl = 'http://10.0.2.2:8000/api'; 

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final orders = await OrderService.getAdminOrders();
      final nonPendingOrders =
          orders.where((order) => order.status != 'pending').toList();

      setState(() {
        _allOrders = nonPendingOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }
  
  // Fungsi untuk mengambil detail pembayaran (Admin)
  Future<PaymentDetailModel> _fetchPaymentDetail(int orderId) async {
  try {
    // 🔥 Gunakan method baru dari OrderService
    final data = await OrderService.getAdminPaymentDetail(orderId);
    return PaymentDetailModel.fromJson(data);
  } catch (e) {
    throw Exception('Gagal memuat detail payment: ${e.toString()}');
  }
}


  // Menerima validationNote (untuk status 'batal')
  Future<void> _updateStatus(AdminOrderModel order, String newStatus, {String? validationNote}) async {
    try {
      final result = await OrderService.updateOrderStatus(
          order.id, 
          newStatus, 
          validationNote: validationNote
      );
      if (!mounted) return;
      if (result['status'] == true) {
        setState(() {
          // Hanya update status jika berhasil
          order.status = newStatus;
        });
        
        // Refresh seluruh list setelah update status (termasuk filter)
        _fetchOrders(); 

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Status order #${order.id} diubah menjadi ${newStatus.toUpperCase()}",
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal update: ${e.toString().replaceAll('Exception: ', '')}",
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      _fetchOrders();
    }
  }

  List<AdminOrderModel> get filteredOrders {
    if (_selectedFilter == 'Semua') return _allOrders;
    return _allOrders
        .where((o) => o.status == _selectedFilter.toLowerCase())
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dibayar':
        return Colors.orange.withValues(alpha: 0.75); // Beri warna oranye untuk menunggu konfirmasi
      case 'pending':
        return Colors.orange.withValues(alpha: 0.75);
      case 'dikirim':
        return Colors.blue.withValues(alpha: 0.75);
      case 'selesai':
        return Colors.green.withValues(alpha: 0.75); // Hijau untuk selesai
      case 'batal':
        return Colors.red.withValues(alpha: 0.75);
      default:
        return Colors.grey.withValues(alpha: 0.75);
    }
  }
  
  // Dialog untuk menampilkan detail order & bukti bayar
  void _showOrderDetailsDialog(AdminOrderModel order) async {
    PaymentDetailModel? paymentDetail;
    String? fetchError;
    
    // Tampilkan loading screen sementara
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      paymentDetail = await _fetchPaymentDetail(order.id);
    } catch (e) {
      fetchError = e.toString().replaceAll('Exception: ', '');
    }
    
    // Tutup loading screen
    if(mounted) Navigator.pop(context); 

    if (fetchError != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat detail pembayaran: $fetchError'))
        );
        return;
    }

    String? selectedNewStatus = order.status;
    final noteController = TextEditingController(text: paymentDetail?.validationNote ?? '');

    // Tampilkan dialog utama
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              
              // Tentukan opsi status yang tersedia
              final List<DropdownMenuItem<String>> statusItems = [
                const DropdownMenuItem(value: 'dibayar', child: Text('Dibayar (Menunggu Konfirmasi)')),
                // Opsi 'dikirim' dan 'batal' hanya muncul jika bukti sudah diupload
                if (paymentDetail?.proofPath != null) ...[
                    const DropdownMenuItem(value: 'dikirim', child: Text('Dikirim (Bukti Valid)')),
                    const DropdownMenuItem(value: 'batal', child: Text('Batal (Bukti Tidak Valid)')),
                ],
                // Opsi 'selesai' harus dipanggil dari sisi customer, jadi tidak perlu di sini.
              ];

              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text("Konfirmasi Order #${order.id}"),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Customer: ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('Total: Rp ${order.formattedPrice}'),
                      const Divider(height: 20),
                      
                      const Text('Bukti Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      if (paymentDetail?.proofUrl != null)
  SizedBox( 
    height: 180,
    width: double.infinity,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        paymentDetail!.proofUrl!, // 🔥 Gunakan proofUrl
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (ctx, err, stack) {
          debugPrint('❌ Error loading image: $err');
          return Container(
            color: Colors.grey[200], 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                const SizedBox(height: 8),
                Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey[600])),
                Text(paymentDetail?.proofUrl ?? '', 
                     style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    ),
  )
                      else
                        const Text(
                          'Bukti transfer belum diupload oleh customer.', 
                          style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic)
                        ),
                      
                      const Divider(height: 20),
                      
                      const Text('Ubah Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: selectedNewStatus,
                        items: statusItems,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedNewStatus = value;
                          });
                        },
                      ),
                      
                      // Tampilkan input catatan hanya jika status dibatalkan
                      if (selectedNewStatus == 'batal') ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: noteController,
                          decoration: const InputDecoration(
                            labelText: 'Catatan Pembatalan (Wajib)',
                            hintText: 'Misalnya: Bukti tidak jelas atau transfer kurang',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                      // Tampilkan catatan jika sudah dibatalkan sebelumnya
                      if (order.status == 'batal' && paymentDetail?.validationNote != null) ...[
                          const SizedBox(height: 16),
                          const Text('Catatan Admin Sebelumnya:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(paymentDetail!.validationNote!, style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: selectedNewStatus == order.status
                      ? null // Disable jika status tidak berubah
                      : () async {
                      
                        if (selectedNewStatus == 'batal' && noteController.text.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Catatan pembatalan wajib diisi.')),
                          );
                          return;
                        }

                        Navigator.pop(context); // Tutup dialog
                        
                        await _updateStatus(
                          order, 
                          selectedNewStatus!, 
                          validationNote: noteController.text.isEmpty ? null : noteController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D7F5F),
                        foregroundColor: Colors.white,
                      ),
                    child: const Text('Simpan Status'),
                  ),
                ],
              );
            },
          );
        },
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text(
          "Kelola Pesanan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5D7F5F),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                value: _selectedFilter,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                  DropdownMenuItem(value: 'Dibayar', child: Text('Dibayar')),
                  DropdownMenuItem(value: 'Dikirim', child: Text('Dikirim')),
                  DropdownMenuItem(value: 'Batal', child: Text('Batal')),
                  DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                ],
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                  _fetchOrders(); // Refresh data dengan filter baru
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Error: $_errorMessage"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchOrders,
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    final ordersToShow = filteredOrders;

    if (ordersToShow.isEmpty) {
      // Buat pesan error lebih dinamis
      if (_selectedFilter == 'Semua' && _allOrders.isEmpty) {
         return const Center(
          child: Text("Belum ada pesanan (selain 'pending')."),
        );
      }
      return Center(
        child: Text("Tidak ada pesanan untuk filter '$_selectedFilter'."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: ordersToShow.length,
      itemBuilder: (context, index) {
        final order = ordersToShow[index];

        return Card(
          color: Colors.green.shade50,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              "Order #${order.id}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Customer: ${order.customerName}\n"
              "Tanggal: ${order.formattedDate}\n"
              "Total: Rp ${order.formattedPrice}",
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            children: [
              // Tambahkan baris untuk melihat detail/bukti
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text(
                  "Lihat Detail & Konfirmasi Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showOrderDetailsDialog(order),
              ),
              const Divider(),
              // Tampilkan Item Pesanan
              ...order.items.map<Widget>((item) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.shopping_cart_outlined, size: 20),
                  title: Text(item.productName, style: const TextStyle(fontSize: 14)),
                  subtitle: Text("Jumlah: ${item.jumlah}", style: const TextStyle(fontSize: 12)),
                  trailing: Text("Rp ${item.harga.toStringAsFixed(0)}", style: const TextStyle(fontSize: 14)),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}