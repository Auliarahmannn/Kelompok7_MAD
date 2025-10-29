import 'package:flutter/material.dart';
import '../../widgets/admin_drawer.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  String _selectedFilter = 'Semua';

  List<Map<String, dynamic>> orders = [
    {
      'id': 1,
      'customer_id': 1,
      'tanggal_pesan': '2025-10-14',
      'total_harga': 1130000.00,
      'status': 'dibayar',
      'items': [
        {'product': 'Carrier 70L', 'jumlah': 1, 'harga': 850000.00},
        {'product': 'Kompor Portable', 'jumlah': 1, 'harga': 280000.00},
      ],
    },
    {
      'id': 2,
      'customer_id': 2,
      'tanggal_pesan': '2025-10-15',
      'total_harga': 300000.00,
      'status': 'pending',
      'items': [
        {'product': 'Tenda Dome', 'jumlah': 1, 'harga': 300000.00},
      ],
    },
    {
      'id': 3,
      'customer_id': 1,
      'tanggal_pesan': '2025-10-15',
      'total_harga': 725000.00,
      'status': 'dikirim',
      'items': [
        {'product': 'Matras', 'jumlah': 1, 'harga': 725000.00},
      ],
    },
  ];

  // === FILTER ORDER BERDASARKAN STATUS ===
  List<Map<String, dynamic>> get filteredOrders {
    if (_selectedFilter == 'Semua') return orders;
    return orders
        .where((o) => o['status'] == _selectedFilter.toLowerCase())
        .toList();
  }

  // === WARNA STATUS (Soft Style seperti Tailwind) ===
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dibayar':
        return Colors.green.withOpacity(0.75);
      case 'pending':
        return Colors.orange.withOpacity(0.75);
      case 'dikirim':
        return Colors.blue.withOpacity(0.75);
      default:
        return Colors.grey.withOpacity(0.75);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text(
          "Kelola Pesanan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5D7F5F),
        foregroundColor: Colors.white,
        actions: [
          // === FILTER DROPDOWN DI APPBAR ===
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                value: _selectedFilter,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'Dibayar', child: Text('Dibayar')),
                  DropdownMenuItem(value: 'Dikirim', child: Text('Dikirim')),
                ],
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                },
              ),
            ),
          ),
        ],
      ),
      body: filteredOrders.isEmpty
          ? const Center(child: Text("Tidak ada pesanan ditemukan."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      "Order #${order['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Tanggal: ${order['tanggal_pesan']}\nTotal: Rp ${order['total_harga']}",
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['status']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order['status'].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: [
                      const Divider(),
                      ...order['items'].map<Widget>((item) {
                        return ListTile(
                          leading: const Icon(Icons.shopping_cart_outlined),
                          title: Text(item['product']),
                          subtitle: Text("Jumlah: ${item['jumlah']}"),
                          trailing: Text("Rp ${item['harga']}"),
                        );
                      }).toList(),
                      const Divider(),
                      // === UBAH STATUS DROPDOWN ===
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Ubah Status:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            DropdownButton<String>(
                              value: order['status'],
                              items: const [
                                DropdownMenuItem(
                                  value: 'pending',
                                  child: Text('Pending'),
                                ),
                                DropdownMenuItem(
                                  value: 'dibayar',
                                  child: Text('Dibayar'),
                                ),
                                DropdownMenuItem(
                                  value: 'dikirim',
                                  child: Text('Dikirim'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  order['status'] = value!;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Status order #${order['id']} diubah menjadi ${value!.toUpperCase()}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    backgroundColor: Colors.green[50],
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
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
            ),
    );
  }
}
