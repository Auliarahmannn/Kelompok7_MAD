import 'package:flutter/material.dart';
import '../../widgets/admin_drawer.dart';
import '/models/admin_order_model.dart';
import '/services/order_service.dart';

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

  Future<void> _updateStatus(AdminOrderModel order, String newStatus) async {
    try {
      final result = await OrderService.updateOrderStatus(order.id, newStatus);

      if (result['status'] == true) {
        setState(() {
          order.status = newStatus;
        });

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
        return Colors.green.withOpacity(0.75);
      case 'pending':
        return Colors.orange.withOpacity(0.75);
      case 'dikirim':
        return Colors.blue.withOpacity(0.75);
      case 'selesai':
        return Colors.purple.withOpacity(0.75);
      case 'batal':
        return Colors.red.withOpacity(0.75);
      default:
        return Colors.grey.withOpacity(0.75);
    }
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
                ],
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
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
              const Divider(),
              ...order.items.map<Widget>((item) {
                return ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined),
                  title: Text(item.productName),
                  subtitle: Text("Jumlah: ${item.jumlah}"),
                  trailing: Text("Rp ${item.harga.toStringAsFixed(0)}"),
                );
              }).toList(),
              const Divider(),

              if (order.status != 'selesai')
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ubah Status:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: order.status,
                        items: const [
                          DropdownMenuItem(
                            value: 'dibayar',
                            child: Text('Dibayar'),
                          ),
                          DropdownMenuItem(
                            value: 'dikirim',
                            child: Text('Dikirim'),
                          ),
                          DropdownMenuItem(
                            value: 'batal',
                            child: Text('Batal'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null && value != order.status) {
                            _updateStatus(order, value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}