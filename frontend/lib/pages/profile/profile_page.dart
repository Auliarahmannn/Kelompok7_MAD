import 'package:campgear/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:campgear/services/customer_service.dart';
import 'package:campgear/models/customer_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  CustomerModel? customer;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  Future<void> fetchCustomerData() async {
    try {
      final data = await CustomerService.getProfile();
      setState(() {
        customer = data;
      });
    } catch (e) {
      debugPrint('❌ Gagal memuat profil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ==== HEADER FOTO ====
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/gambar1.png',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: -40,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.green[700],
                        child: const Icon(Icons.person,
                            size: 50, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 55),

              // ==== NAMA CUSTOMER ====
              Text(
                customer?.name ?? "Loading...",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                customer?.email ?? '',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 15),

              // ==== TOMBOL AKTIVITAS ====
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green.shade700, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.timeline, color: Colors.redAccent),
                        SizedBox(width: 10),
                        Text(
                          "Lihat 4 Aktivitas Terbaru",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ==== MENU PROFIL ====
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    buildMenu(Icons.person_outline, "Lihat Profil", () {}),
                    buildMenu(Icons.notifications_none, "Notifikasi", () {}),
                    buildMenu(Icons.lock_outline, "Privasi", () {}),
                    buildMenu(
                        isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode_outlined,
                        "Mode Gelap", () {
                      setState(() {
                        isDarkMode = !isDarkMode;
                      });
                    }),
                    buildMenu(Icons.report_problem_outlined,
                        "Laporkan Masalah", () {}),
                    buildMenu(Icons.switch_account_outlined, "Ganti Akun", () {}),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==== TOMBOL LOGOUT ====
              GestureDetector(
                onTap: () async {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            "Keluar",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right, color: Colors.red),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenu(IconData icon, String text, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(text, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
