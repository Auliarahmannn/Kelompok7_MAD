class ChartDataPoint {
  final String label; // label X-axis (Jam '10', Hari '15', Bulan '3')
  final double total; // label Y-axis (Total pendapatan)

  ChartDataPoint({required this.label, required this.total});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: (json['label'] ?? 0).toString(),
      total: double.tryParse(json['total'].toString()) ?? 0.0,
    );
  }
}

// Model utama yang diperbarui
class StatisticsModel {
  final double pendapatanSelesai;
  final int pesananSelesai;
  final int barangTerjual;
  final int pesananDiproses;
  final int pesananDibatalkan;
  final double pendapatanDiproses;
  
  // Data baru untuk grafik
  final List<ChartDataPoint> chartData;

  StatisticsModel({
    required this.pendapatanSelesai,
    required this.pesananSelesai,
    required this.barangTerjual,
    required this.pesananDiproses,
    required this.pesananDibatalkan,
    required this.pendapatanDiproses,
    required this.chartData, 
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    var chartList = <ChartDataPoint>[];
    if (json['chart_data'] != null && json['chart_data'] is List) {
      chartList = (json['chart_data'] as List)
          .map((item) => ChartDataPoint.fromJson(item))
          .toList();
    }

    return StatisticsModel(
      pendapatanSelesai: double.tryParse(json['pendapatan_selesai'].toString()) ?? 0.0,
      pesananSelesai: int.tryParse(json['pesanan_selesai'].toString()) ?? 0,
      barangTerjual: int.tryParse(json['barang_terjual'].toString()) ?? 0,
      pesananDiproses: int.tryParse(json['pesanan_diproses'].toString()) ?? 0,
      pesananDibatalkan: int.tryParse(json['pesanan_dibatalkan'].toString()) ?? 0,
      pendapatanDiproses: double.tryParse(json['pendapatan_diproses'].toString()) ?? 0.0,
      
      chartData: chartList, 
    );
  }
}