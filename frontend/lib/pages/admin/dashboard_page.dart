import 'package:flutter/material.dart';
import 'package:campgear/widgets/admin_drawer.dart';

// Import halaman yang mau dituju
import 'package:campgear/pages/admin/manage_product_page.dart';
import 'package:campgear/pages/admin/manage_orders_page.dart';
import 'package:campgear/pages/admin/revenue_page.dart';
import 'package:campgear/pages/admin/manage_users_page.dart';

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
          _buildCard(
            context,
            icon: Icons.shopping_bag,
            label: "Kelola Produk",
            color: Colors.blue,
            page: const ManageProductPage(),
          ),
          _buildCard(
            context,
            icon: Icons.list_alt,
            label: "Kelola Pesanan",
            color: Colors.green,
            page: const ManageOrdersPage(),
          ),
          _buildCard(
            context,
            icon: Icons.attach_money,
            label: "Pendapatan",
            color: Colors.purple,
            page: const RevenuePage(),
          ),
          _buildCard(
            context,
            icon: Icons.people,
            label: "Pengguna",
            color: Colors.orange,
            page: const UserPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
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
