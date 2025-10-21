import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String nama;
  final String deskripsi;
  final String gambar;

  const ProductDetailPage({
    super.key,
    required this.nama,
    required this.deskripsi,
    required this.gambar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(backgroundColor: Colors.green[700], title: Text(nama)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Gambar produk
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.asset(
                gambar,
                width: double.infinity,
                height: 275,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Informasi produk
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deskripsi,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Spesifikasi / contoh deskripsi tambahan
                  const Text(
                    "Spesifikasi Produk:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• Kapasitas: 70 Liter\n• Bahan: Nylon tahan air\n• Berat: 1.2 kg\n• Warna: Hijau",
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Tombol aksi
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text("Tambah ke Keranjang"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
