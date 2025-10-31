class PaymentMethodModel {
  final int id;
  final String metode;
  final String? deskripsi;
  // bisa tambahkan field lain jika perlu, misal 'nomor_rekening'
  // final String? nomorAkun; 
  // final String? logoUrl;

  PaymentMethodModel({
    required this.id,
    required this.metode,
    this.deskripsi,
    // this.nomorAkun,
    // this.logoUrl,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? 0,
      metode: json['metode'] ?? '',
      deskripsi: json['deskripsi'],
      // nomorAkun: json['nomor_akun'],
      // logoUrl: json['logo_url'],
    );
  }
}