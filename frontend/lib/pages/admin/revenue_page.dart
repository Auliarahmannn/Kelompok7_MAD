import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  String _selectedFilter = 'Harian';

  // datanya masih asal (nanti bisa diganti data dari API)
  final Map<String, Map<String, dynamic>> _dummyData = {
    'Harian': {'barangTerjual': 25, 'uangMasuk': 1250000},
    'Bulanan': {'barangTerjual': 480, 'uangMasuk': 27500000},
    'Tahunan': {'barangTerjual': 5200, 'uangMasuk': 312000000},
  };

  @override
  Widget build(BuildContext context) {
    final data = _dummyData[_selectedFilter]!;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pendapatan"),
        backgroundColor: const Color(0xFF5D7F5F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FILTER PILIHAN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('Harian'),
                _buildFilterButton('Bulanan'),
                _buildFilterButton('Tahunan'),
              ],
            ),
            const SizedBox(height: 20),

            // Kartu statistik
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.shopping_cart,
                    label: "Barang Terjual",
                    value: "${data['barangTerjual']} pcs",
                    color: Colors.blue.shade100,
                    iconColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.monetization_on,
                    label: "Arus Uang Masuk",
                    value: formatter.format(data['uangMasuk']),
                    color: Colors.green.shade100,
                    iconColor: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              "Grafik Pendapatan (mock)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            // Placeholder grafik (bisa diganti nanti dengan package chart)
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text(
                  "Grafik pendapatan akan tampil di sini 📊",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tombol filter harian/bulanan/tahunan
  Widget _buildFilterButton(String label) {
    final bool isSelected = _selectedFilter == label;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFF5D7F5F)
            : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }

  // Kartu statistik
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
