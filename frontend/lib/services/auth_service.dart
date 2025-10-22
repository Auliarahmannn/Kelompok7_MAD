import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000/api"; 
  // ⚠️ gunakan 10.0.2.2 kalau pakai emulator Android (bukan localhost)

  /// Kirim kode OTP ke email
  static Future<Map<String, dynamic>> sendCode(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/send-code"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return jsonDecode(response.body);
  }

  /// Verifikasi OTP
  static Future<Map<String, dynamic>> verifyCode(String email, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/verify-code"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    return jsonDecode(response.body);
  }

  /// Register user baru
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? address,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
      }),
    );

    return jsonDecode(response.body);
  }
}
