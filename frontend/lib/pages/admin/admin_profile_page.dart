import 'package:campgear/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:campgear/services/user_service.dart';
import 'package:campgear/models/user_model.dart';
import 'package:campgear/widgets/admin_drawer.dart'; 
import 'package:campgear/pages/profile/profile_update.dart';
import 'package:campgear/pages/profile/profile_delete.dart';
import 'package:campgear/pages/profile/profile_change_password.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Key to control the Scaffold (needed to open the drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UserModel? user;
  bool isLoading = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() => isLoading = true);
    try {
      final data = await UserService.getProfile();
      setState(() {
        user = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat profil: $e')));
      }
    }
  }

  // 🔹 Dialog Konfirmasi Reusable
  Future<void> showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              isDestructive ? Icons.delete_rounded : Icons.logout_rounded,
              color: isDestructive ? Colors.red[700] : const Color(0xFF5D7F5F),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDestructive ? Colors.red[700] : const Color(0xFF5D7F5F),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? Colors.red[600]
                  : Colors.green[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: fetchUserProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // ==== HEADER FOTO ====
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            'assets/images/gambar1.png',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: const Color(0xFF5D7F5F),
                              );
                            },
                          ),
                          Positioned(
                            bottom: -40,
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 42,
                                backgroundColor: const Color(0xFF5D7F5F),
                                child: Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 55),

                      // ==== NAMA USER ====
                      Text(
                        user?.name ?? "Loading...",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Role
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: user?.role == 'admin'
                                  ? Colors.red[50]
                                  : Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user?.role.toUpperCase() ?? '',
                              style: TextStyle(
                                color: user?.role == 'admin'
                                    ? Colors.red[700]
                                    : Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Email
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user!.email,
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ==== INFO KONTAK ====
                      if (user?.phone != null || user?.address != null)
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (user?.phone != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: const Color(0xFF5D7F5F),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        user!.phone!,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              if (user?.phone != null && user?.address != null)
                                const Divider(height: 20),
                              if (user?.address != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: const Color(0xFF5D7F5F),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        user!.address!,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
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
                            buildMenu(Icons.edit_outlined, "Edit Profil", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileUpdatePage(user: user!),
                                ),
                              ).then((updated) {
                                if (updated == true) {
                                  fetchUserProfile();
                                }
                              });
                            }),
                            buildMenu(
                              Icons.notifications_none,
                              "Notifikasi",
                              () {},
                            ),
                            buildMenu(Icons.lock_outline, "Ganti Password", () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfileChangePasswordPage(),
                                ),
                              );
                            }),
                            buildMenu(
                              isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode_outlined,
                              "Mode Gelap",
                              () {
                                setState(() {
                                  isDarkMode = !isDarkMode;
                                });
                              },
                            ),
                            buildMenu(
                              Icons.report_problem_outlined,
                              "Laporkan Masalah",
                              () {},
                            ),
                            buildMenu(
                              Icons.delete_outline,
                              "Hapus Akun",
                              () {
                                showConfirmDialog(
                                  title: "Hapus Akun",
                                  message:
                                      "Anda yakin ingin menghapus akun Anda? Tindakan ini tidak dapat dibatalkan.",
                                  isDestructive: true,
                                  onConfirm: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfileDeletePage(),
                                      ),
                                    );
                                  },
                                );
                              },
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==== TOMBOL LOGOUT ====
                      GestureDetector(
                        onTap: () {
                          showConfirmDialog(
                            title: "Keluar",
                            message: "Anda yakin ingin keluar dari akun ini?",
                            onConfirm: () async {
                              await AuthService.logout();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/signin',
                                  (route) => false,
                                );
                              }
                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.logout_rounded, color: Colors.red),
                                  SizedBox(width: 10),
                                  Text(
                                    "Keluar",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
      ),
    );
  }

  Widget buildMenu(
    IconData icon,
    String text,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: isDestructive ? Colors.red : Colors.black,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDestructive ? Colors.red : Colors.grey,
          ),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
