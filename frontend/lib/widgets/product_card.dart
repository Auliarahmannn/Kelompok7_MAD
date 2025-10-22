import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import 'package:campgear/pages/product/product_detail_page.dart';
import 'package:campgear/data/api_services.dart';

class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  late Future<List<Products>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = ApiServices.getProducts();
  }

  String formatRupiah(double harga) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    return formatter.format(harga);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Products>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada produk tersedia'));
        }

        final productList = snapshot.data!;

        return Transform.translate(
          offset: const Offset(0, -20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.73,
            ),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final item = productList[index];

              final imageWidget = (item.foto.isNotEmpty)
                  ? Image.asset(
                      'assets/images/${item.foto}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 50),
                    )
                  : Image.asset(
                      'assets/images/gambar1.png',
                      fit: BoxFit.cover,
                    );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        nama: item.namaProduk,
                        deskripsi: item.deskripsi,
                        stok: item.stok,
                        harga: item.harga,
                        foto: item.foto.isNotEmpty
                            ? 'assets/images/${item.foto}'
                            : 'assets/images/gambar1.png',
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 7,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: imageWidget,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF597E52),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.namaProduk,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatRupiah(item.harga),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}