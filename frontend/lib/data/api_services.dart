import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiServices {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<List<Products>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
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
