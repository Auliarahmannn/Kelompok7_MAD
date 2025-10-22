import 'user_model.dart';
import 'customer_model.dart';

class AuthResponse {
  final bool status;
  final String message;
  final String? token;
  final UserModel? user;
  final CustomerModel? customer;

  AuthResponse({
    required this.status,
    required this.message,
    this.token,
    this.user,
    this.customer,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] == true,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      customer: json['customers'] != null
          ? CustomerModel.fromJson(json['customers'])
          : null,
    );
  }
}
