import 'package:flutter/material.dart';
import '../../widgets/admin_drawer.dart';

class ManageProductPage extends StatefulWidget {
  const ManageProductPage({super.key});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  List<Map<String, dynamic>> produk = [
    {'nama': 'Tenda Eiger', 'harga': 250000},
    {'nama': 'Carrier 70L', 'harga': 300000},
  ];

  void _hapusProduk(int index) {
    setState(() {
      produk.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(title: const Text("Kelola Produk")),
      body: ListView.builder(
        itemCount: produk.length,
        itemBuilder: (context, index) {
          final item = produk[index];
          return ListTile(
            title: Text(item['nama']),
            subtitle: Text('Rp${item['harga']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _hapusProduk(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: Tambah produk baru nanti di sini
        },
      ),
    );
  }
}
