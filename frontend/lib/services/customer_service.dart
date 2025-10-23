import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campgear/models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<CustomerModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');

    if (token == null || userId == null) {
      throw Exception('User belum login.');
    }

    final response = await http.get(
      Uri.parse("$baseUrl/customers/$userId"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // ✅ sesuai struktur backend
      if (jsonData is Map &&
          jsonData['data'] != null &&
          jsonData['data'] is List &&
          jsonData['data'].isNotEmpty) {
        return CustomerModel.fromJson(jsonData['data'][0]);
      } else {
        throw Exception('Data customer tidak ditemukan atau format salah');
      }
    } else {
      throw Exception('Gagal mengambil data profil (${response.statusCode})');
    }
  }

  // Fungsi logout untuk menghapus data dari local storage
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // hapus semua data login
  }
}
