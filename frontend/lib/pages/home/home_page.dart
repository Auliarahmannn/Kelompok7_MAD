import 'package:flutter/material.dart';
import '../../widgets/home_header.dart';
import '../../widgets/search_field.dart';
import '../../widgets/product_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: const [HomeHeader(), SearchField(), ProductGrid()],
        ),
      ),
    );
  }
}
