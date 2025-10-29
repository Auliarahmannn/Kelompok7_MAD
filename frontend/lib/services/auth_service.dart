import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  static Future<Map<String, dynamic>> verifyCode(
    String email,
    String otp,
  ) async {
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

  /// Login user dan simpan token + user_id
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);

      // Cek tipe data user, bisa int atau map
      if (data['user'] is Map<String, dynamic>) {
        await prefs.setInt('user_id', data['user']['id']);
      } else if (data['user'] is int) {
        await prefs.setInt('user_id', data['user']);
      }

      // simpan role
      if (data['role'] != null) {
        await prefs.setString('role', data['role']);
      }
    }

    return data;
  }

  /// Logout (hapus data dari SharedPreferences)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("⚠️ Tidak ada token, user belum login");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Logout berhasil di server");
      } else {
        print("⚠️ Gagal logout di server: ${response.body}");
      }
    } catch (e) {
      print("❌ Error saat logout: $e");
    }

    // Hapus data lokal di Flutter
    await prefs.remove('token');
    await prefs.remove('user_id');
  }

  /// Ngambil role login
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  /// Ambil token yang tersimpan
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Ambil user_id yang tersimpan
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}
