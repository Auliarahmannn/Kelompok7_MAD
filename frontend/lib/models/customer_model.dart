class CustomerModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final int userId;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    required this.userId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      userId: json['user_id'] ?? 0,
    );
  }
}
