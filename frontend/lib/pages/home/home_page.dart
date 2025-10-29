import 'package:flutter/material.dart';
import '../../widgets/home_header.dart';
import '../../widgets/search_field.dart';
import '../../widgets/product_card.dart';
import '../../widgets/admin_drawer.dart';
import '../../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final role = await AuthService.getRole();
    setState(() {
      _isAdmin = (role == 'admin');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Tambahkan drawer hanya jika admin
      drawer: _isAdmin ? const AdminDrawer() : null,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Header berbeda untuk admin
            _isAdmin ? _buildAdminHeader() : const HomeHeader(),
            Padding(
              padding: const EdgeInsets.only(
                top: 175.0,
                bottom: 30.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Column(
                children: [
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: _updateSearchQuery,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
                    child: ProductGrid(searchQuery: _searchQuery),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header khusus admin dengan tombol menu drawer
  Widget _buildAdminHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/gambar1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 250,
          color: Colors.black.withOpacity(0.3),
        ),
        // Tombol menu drawer
        Positioned(
          top: 40,
          left: 10,
          child: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        // Text untuk admin
        Positioned(
          top: 40,
          left: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Admin Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}