import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Temukan alat camping',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white),
          hintStyle: TextStyle(color: Colors.white),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
