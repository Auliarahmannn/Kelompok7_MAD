import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campgear/models/cart_model.dart'; // Ganti dengan path model Anda

class CartService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Get token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Helper untuk membuat headers
  static Future<Map<String, String>> _getHeaders({bool useContentType = true}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    
    if (useContentType) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  // GET - Ambil semua item di keranjang
  static Future<List<CartItemModel>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: await _getHeaders(useContentType: false),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((item) => CartItemModel.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Gagal memuat keranjang');
      }
    } catch (e) {
      print('Error getCart: $e');
      rethrow;
    }
  }

  // POST - Tambah item ke keranjang
  static Future<bool> addToCart({required int productId, required int quantity}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: await _getHeaders(),
        body: json.encode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      final jsonResponse = json.decode(response.body);
      return response.statusCode == 201 && jsonResponse['status'] == true;
      
    } catch (e) {
      print('Error addToCart: $e');
      rethrow;
    }
  }

  // PUT - Update jumlah item
  static Future<bool> updateQuantity({required int orderItemId, required int quantity}) async {
     try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart/$orderItemId'),
        headers: await _getHeaders(),
        body: json.encode({
          'quantity': quantity,
        }),
      );

      final jsonResponse = json.decode(response.body);
      return response.statusCode == 200 && jsonResponse['status'] == true;

    } catch (e) {
      print('Error updateQuantity: $e');
      rethrow;
    }
  }

  // DELETE - Hapus item dari keranjang
  static Future<bool> removeFromCart({required int orderItemId}) async {
     try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/$orderItemId'),
        headers: await _getHeaders(useContentType: false),
      );

      final jsonResponse = json.decode(response.body);
      return response.statusCode == 200 && jsonResponse['status'] == true;

    } catch (e) {
      print('Error removeFromCart: $e');
      rethrow;
    }
  }
}