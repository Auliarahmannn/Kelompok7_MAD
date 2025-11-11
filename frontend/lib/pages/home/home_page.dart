import 'package:flutter/material.dart';
import '../../widgets/home_header.dart';
import '../../widgets/search_field.dart'; // SearchBarWidget
import '../../widgets/product_card.dart'; // ProductGrid

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Tambahkan controller dan state untuk query pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; 

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk memperbarui state query
  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            const HomeHeader(),
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
                    // 2. Hubungkan onChanged ke fungsi pembaruan state
                    onChanged: _updateSearchQuery, 
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 30.0,
                      bottom: 0.0
                    ),
                    child: ProductGrid(searchQuery: _searchQuery),
                  )
                ],
              )
            ),
            // 3. Kirim query pencarian ke ProductGrid
          ],
        ),
      ),
    );
  }
}