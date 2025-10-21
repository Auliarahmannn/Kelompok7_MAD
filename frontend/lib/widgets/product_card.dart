import 'package:flutter/material.dart';
import 'package:campgear/data/product_data.dart';
import 'package:campgear/pages/product/product_detail_page.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemCount: produkData.length,
      itemBuilder: (context, index) {
        final item = produkData[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(
                  nama: item.nama,
                  deskripsi: item.deskripsi,
                  gambar: item.gambar,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Image.asset(item.gambar, fit: BoxFit.cover)),
                const SizedBox(height: 8),
                Text(
                  item.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Rp${item.harga}'),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
