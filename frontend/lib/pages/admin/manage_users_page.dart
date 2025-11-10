import 'package:flutter/material.dart';
import 'package:campgear/services/user_service.dart';
import 'package:campgear/models/user_model.dart';
import 'package:campgear/widgets/admin_drawer.dart';
import 'package:campgear/pages/admin/admin_chat_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchUsers();
  }

  // Fungsi untuk mengambil data dari service
  Future<List<UserModel>> fetchUsers() async {
    try {
      final users = await UserService.getAllCustomersForAdmin();
      return users;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat pengguna: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return Future.error(e);
    }
  }

  // Fungsi untuk refresh
  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = fetchUsers();
    });
  }

  void _navigateToChat(UserModel user) {
    if (user.customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: User ID untuk ${user.name} tidak ditemukan.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminChatPage(
          customerUserId: user.customerId.toString(), // Kirim Id
          customerName: user.name, // Kirim Nama
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text(
          "Daftar Pengguna",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5D7F5F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: FutureBuilder<List<UserModel>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            // 1. Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Error state
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: ${snapshot.error.toString()}"),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshUsers,
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              );
            }

            // 3. Empty state
            final users = snapshot.data;
            if (users == null || users.isEmpty) {
              return const Center(child: Text("Belum ada data pengguna"));
            }

            // 4. Success state
            return RefreshIndicator(
              onRefresh: _refreshUsers,
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    color: Colors.green.shade50,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.chat_rounded,
                                  color: Color(0xFF5D7F5F),
                                ),
                                onPressed: () => _navigateToChat(user),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.email,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (user.phone != null && user.phone!.isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  user.phone!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 4),
                          if (user.address != null && user.address!.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.home,
                                  size: 16,
                                  color: Colors.brown,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    user.address!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
