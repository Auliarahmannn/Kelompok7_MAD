import 'package:flutter/material.dart';
import '../../widgets/admin_drawer.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  List<Map<String, dynamic>> orders = [
    {'namaUser': 'Fahmi', 'produk': 'Carrier 70L', 'status': 'Pending'},
    {'namaUser': 'Alya', 'produk': 'Kompor Portable', 'status': 'Dikonfirmasi'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(title: const Text("Pesanan Masuk")),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text(order['produk']),
            subtitle: Text('Oleh: ${order['namaUser']}'),
            trailing: DropdownButton<String>(
              value: order['status'],
              items: ['Pending', 'Dikonfirmasi', 'Selesai']
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  order['status'] = value!;
                });
              },
            ),
          );
        },
      ),
    );
  }
}
