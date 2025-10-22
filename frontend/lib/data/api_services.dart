import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiServices {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static String? token;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['token'] != null) {
        token = data['token'];
      }

      return data; // hasil { "status": "...", "token": "...", "message": "..." }
    } else {
      throw Exception('Failed to Login');
    }
  }

  static Future<List<Products>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
         'Authorization': 'Bearer $token',
        if (token != null) 'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // asumsi struktur response: { "data": [ { ...produk... }, ... ] }
      List<dynamic> data = jsonData['data'];
      return data.map((e) => Products.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products data');
    }
  }
}
