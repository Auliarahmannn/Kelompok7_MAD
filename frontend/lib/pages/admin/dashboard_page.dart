import 'package:flutter/material.dart';
import 'package:campgear/widgets/admin_drawer.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(), 
      appBar: AppBar(
        title: const Text(
          "Dashboard Admin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5D7F5F),
        foregroundColor: Colors.white,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(context, Icons.shopping_bag, "Kelola Produk", Colors.blue),
          _buildCard(context, Icons.list_alt, "Kelola Pesanan", Colors.green),
          _buildCard(context, Icons.attach_money, "Pendapatan", Colors.purple),
          _buildCard(context, Icons.people, "Pengguna", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buka halaman $label')),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
