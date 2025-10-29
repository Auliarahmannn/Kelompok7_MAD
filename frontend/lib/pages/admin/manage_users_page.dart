import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<Map<String, dynamic>> users = [];
  String? errorMessage;

  // 🔹 Animasi controller
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchUsers();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulasi loading

    // 🔹 (Komen) Fetch API
    /*
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:9000/api/users'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          users = data.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil data pengguna');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
    */

    // 🔹 Dummy data
    setState(() {
      users = [
        {
          'id': 1,
          'name': 'Ahmad Fahmi',
          'email': 'fahmi@gmail.com',
          'phone': '08123456789',
          'address': 'Bandung, Jawa Barat',
        },
        {
          'id': 2,
          'name': 'Dina Lestari',
          'email': 'dina@gmail.com',
          'phone': '08129876543',
          'address': 'Jakarta Selatan',
        },
        {
          'id': 3,
          'name': 'Rizky Pratama',
          'email': 'rizky.p@gmail.com',
          'phone': '08139098765',
          'address': 'Surabaya, Jawa Timur',
        },
        {
          'id': 4,
          'name': 'Siti Rahmawati',
          'email': 'siti.rahma@gmail.com',
          'phone': '085777123456',
          'address': 'Yogyakarta',
        },
      ];
      isLoading = false;
    });

    // Jalankan animasi setelah data dimuat
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text("Error: $errorMessage"))
            : users.isEmpty
            ? const Center(child: Text("Belum ada data pengguna"))
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${user['name']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "ID: ${user['id']}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user['email'],
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user['phone'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
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
                                      user['address'],
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
                ),
              ),
      ),
    );
  }
}
