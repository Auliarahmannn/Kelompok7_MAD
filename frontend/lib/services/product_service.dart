import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campgear/models/product_model.dart';
import 'package:campgear/services/auth_service.dart';

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // 🔹 GET: Ambil semua produk
  static Future<List<Products>> getProducts() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<dynamic> data = jsonData['data'];
      return data.map((e) => Products.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data produk');
    }
  }

  // 🔹 CREATE produk baru
  static Future<bool> createProduct({
    required String namaProduk,
    required String deskripsi,
    required double harga,
    required int stok,
    required String foto,
  }) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama_produk': namaProduk,
        'deskripsi': deskripsi,
        'harga': harga,
        'stok': stok,
        'foto': foto,
      }),
    );

    return response.statusCode == 201;
  }

  // 🔹 UPDATE produk
  static Future<bool> updateProduct({
    required int id,
    required String namaProduk,
    required String deskripsi,
    required double harga,
    required int stok,
    required String foto,
  }) async {
    final token = await AuthService.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama_produk': namaProduk,
        'deskripsi': deskripsi,
        'harga': harga,
        'stok': stok,
        'foto': foto,
      }),
    );

    return response.statusCode == 200;
  }

  // 🔹 DELETE produk
  static Future<bool> deleteProduct(int id) async {
    final token = await AuthService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}
