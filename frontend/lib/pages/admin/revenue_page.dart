import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campgear/services/order_service.dart';
import 'package:campgear/models/statistics_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:campgear/widgets/admin_drawer.dart';

class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  String _selectedFilter = 'Harian';
  StatisticsModel? _data;
  bool _isLoading = true;
  String? _errorMessage;

  final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await OrderService.getStatistics(
        _selectedFilter.toLowerCase(),
      );
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text(
          "Pendapatan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5D7F5F),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildContent()],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan konten (loading, error, atau data)
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(heightFactor: 5, child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        heightFactor: 5,
        child: Text(
          'Gagal memuat data:\n$_errorMessage',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red[700]),
        ),
      );
    }

    if (_data != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Button Row — sejajar dengan elemen lain
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFilterButton('Harian'),
              _buildFilterButton('Bulanan'),
              _buildFilterButton('Tahunan'),
            ],
          ),
          const SizedBox(height: 20),

          // Row untuk kartu statistik
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.shopping_cart,
                  label: "Barang Terjual",
                  value: "${_data!.barangTerjual} pcs",
                  color: Colors.blue.shade100,
                  iconColor: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.monetization_on,
                  label: "Arus Uang Masuk",
                  value: _formatter.format(_data!.pendapatanSelesai),
                  color: Colors.green.shade100,
                  iconColor: Colors.green.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Judul grafik dan grafik pendapatan
          Text(
            "Grafik Pendapatan ($_selectedFilter)",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            height: 200,
            child: _buildChart(_data!.chartData),
          ),
        ],
      );
    }

    return const Center(heightFactor: 5, child: Text("Data tidak ditemukan."));
  }

  // Tombol filter
  Widget _buildFilterButton(String label) {
    final bool isSelected = _selectedFilter == label;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = label;
        });
        _fetchData();
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

  Widget _buildChart(List<ChartDataPoint> chartData) {
    // Jika tidak ada data untuk filter ini, tampilkan pesan
    if (chartData.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            "Tidak ada pendapatan 'selesai' untuk periode ini.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Ubah data dari API menjadi data yang dimengerti BarChart
    List<BarChartGroupData> barGroups = [];
    for (var dataPoint in chartData) {
      final xValue = double.tryParse(dataPoint.label) ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: xValue.toInt(), // Nilai X-axis
          barRods: [
            BarChartRodData(
              toY: dataPoint.total, // Nilai Y-axis (tinggi bar)
              color: const Color(0xFF5D7F5F),
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        // Styling Tooltip (saat bar disentuh)
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final yValue = rod.toY;
              return BarTooltipItem(
                _formatter.format(yValue), // Tampilkan format Rupiah
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),

        // Styling Axis (Sumbu)
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // Sumbu Y (Kiri) - Pendapatan
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                // Tampilkan label Y-axis (misal: 100k, 1M)
                if (value == 0) return const Text('');
                String text;
                if (value > 999999) {
                  text = '${(value / 1000000).toStringAsFixed(1)}Jt';
                } else if (value > 999) {
                  text = '${(value / 1000).toStringAsFixed(0)}Rb';
                } else {
                  text = value.toStringAsFixed(0);
                }
                return Text(text, style: const TextStyle(fontSize: 10));
              },
            ),
          ),

          // Sumbu X (Bawah) - Waktu
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                // Ubah label angka menjadi teks yang relevan
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(_getBottomTitle(value.toInt())),
                );
              },
            ),
          ),
        ),

        // Styling Garis
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        barGroups: barGroups,
      ),
    );
  }

  // --- 4. HELPER UNTUK LABEL BAWAH (SUMBU X) ---
  String _getBottomTitle(int value) {
    switch (_selectedFilter) {
      case 'Harian':
        // Tampilkan jam (misal: 09, 14, 21)
        return value.toString().padLeft(2, '0');

      case 'Bulanan':
        // Tampilkan tanggal (misal: 1, 5, 10, 15)
        if (value % 5 == 0 || value == 1) {
          // Hanya tampilkan kelipatan 5
          return value.toString();
        }
        return ''; // Sembunyikan label lain

      case 'Tahunan':
        // Tampilkan nama bulan
        switch (value) {
          case 1:
            return 'Jan';
          case 2:
            return 'Feb';
          case 3:
            return 'Mar';
          case 4:
            return 'Apr';
          case 5:
            return 'Mei';
          case 6:
            return 'Jun';
          case 7:
            return 'Jul';
          case 8:
            return 'Agu';
          case 9:
            return 'Sep';
          case 10:
            return 'Okt';
          case 11:
            return 'Nov';
          case 12:
            return 'Des';
          default:
            return '';
        }
      default:
        return '';
    }
  }
}
