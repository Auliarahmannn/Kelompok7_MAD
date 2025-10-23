import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:campgear/models/product_model.dart';
import 'package:campgear/services/auth_service.dart';

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

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
}
