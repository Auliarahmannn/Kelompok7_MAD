import 'package:campgear/pages/admin/admin_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:campgear/pages/admin/dashboard_page.dart';
import 'package:campgear/pages/admin/manage_product_page.dart';
import 'package:campgear/pages/admin/manage_orders_page.dart';
import 'package:campgear/pages/admin/revenue_page.dart';
import 'package:campgear/pages/admin/manage_users_page.dart';
import 'package:campgear/services/auth_service.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF5F5F5),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ==== HEADER ====
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5D7F5F), Color(0xFF81A684)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'CampGear Management',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ==== MENU ITEM ====
          buildMenuItem(
            context,
            icon: Icons.person_rounded,
            text: "Profile",
            color: const Color(0xFF5D7F5F),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),

          const Divider(height: 1),

          buildMenuItem(
            context,
            icon: Icons.dashboard_rounded,
            text: "Dashboard",
            color: const Color(0xFF4F6F52),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardPage(),
                ),
              );
            },
          ),

          buildMenuItem(
            context,
            icon: Icons.shopping_bag_rounded,
            text: "Kelola Produk",
            color: const Color(0xFF6B8F71),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageProductPage(),
                ),
              );
            },
          ),

          buildMenuItem(
            context,
            icon: Icons.list_alt_rounded,
            text: "Kelola Pesanan",
            color: const Color(0xFF507963),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageOrdersPage(),
                ),
              );
            },
          ),

          buildMenuItem(
            context,
            icon: Icons.attach_money,
            text: "Pendapatan",
            color: const Color(0xFF6B8F71),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RevenuePage()),
              );
            },
          ),

          buildMenuItem(
            context,
            icon: Icons.people,
            text: "Pengguna",
            color: const Color(0xFF6B8F71),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserPage()),
              );
            },
          ),

          const Divider(height: 1),

          // ==== LOGOUT ====
          buildMenuItem(
            context,
            icon: Icons.logout_rounded,
            text: "Logout",
            color: Colors.red[600]!,
            isDestructive: true,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red[700]),
                      const SizedBox(width: 10),
                      Text(
                        "Konfirmasi Logout",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Apakah Anda yakin ingin keluar?",
                    style: TextStyle(fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AuthService.logout();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/signin');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red[700] : const Color(0xFF2F2F2F),
        ),
      ),
      onTap: onTap,
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? Colors.red[700] : Colors.grey[400],
      ),
    );
  }
}
