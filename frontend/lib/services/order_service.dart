import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/models/cart_model.dart';
import '/models/my_order_item_model.dart';
import '/models/admin_order_model.dart';
import '/models/statistics_model.dart';

class OrderService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> checkout({
    required List<CartItemModel> items,
    required int paymentMethodId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    List<Map<String, dynamic>> itemsJson = items.map((item) {
      return {
        'product_id': item.productId,
        'quantity': item.quantity,
        'order_item_id': item.orderItemId,
      };
    }).toList();

    print('🧾 Sending checkout request:');
    print(jsonEncode({
      'payment_method_id': paymentMethodId,
      'items': itemsJson,
    }));

    final response = await http.post(
      Uri.parse('$_baseUrl/checkout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'payment_method_id': paymentMethodId,
        'items': itemsJson,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      try {
        final Map<String, dynamic> error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Gagal melakukan checkout',
        };
      } catch (e) {
        throw Exception('Response bukan JSON valid: ${response.body}');
      }
    }
  }
  
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<MyOrderItemModel>> getMyOrderItems() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/order-items'), // Panggil endpoint OrderItemsController@index
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((item) => MyOrderItemModel.fromJson(item)).toList();
      } else {
        // Jika status true tapi data null
        return [];
      }
    } 
    // 404 = Tidak Ditemukan (customer belum punya pesanan)
    else if (response.statusCode == 404) {
      return [];
    } 
    // Error lainnya
    else {
      throw Exception('Gagal memuat data pesanan: ${response.body}');
    }
  }

  // UNTUK ADMIN 
  static Future<List<AdminOrderModel>> getAdminOrders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    // Panggil endpoint OrdersController@index
    final response = await http.get(
      Uri.parse('$_baseUrl/orders'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      // 'data' adalah key dari BaseResource Laravel Anda
      if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((item) => AdminOrderModel.fromJson(item)).toList();
      } else if (jsonResponse['status'] == true && jsonResponse['data'] == null) {
        // Data bisa jadi null jika memang kosong
        return []; 
      } else {
        throw Exception(jsonResponse['message'] ?? 'Gagal memuat data pesanan');
      }
    } else {
      throw Exception('Gagal memuat data pesanan: ${response.body}');
    }
  }
  
  // UNTUK UPDATE STATUS 
  static Future<Map<String, dynamic>> updateOrderStatus(int orderId, String newStatus) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.patch(
      // Panggil endpoint baru yang kita buat di routes/api.php
      Uri.parse('$_baseUrl/admin/orders/$orderId/status'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': newStatus,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
       final Map<String, dynamic> error = jsonDecode(response.body);
       return {
         'status': false,
         'message': error['message'] ?? 'Gagal update status',
       };
    }
  }

  static Future<bool> confirmOrderReceived(int orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.patch(
      Uri.parse('$_baseUrl/my-orders/$orderId/receive'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      // Tidak perlu body, endpoint sudah spesifik
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['status'] == true; // Berhasil
    } else {
      // Coba parse error
      try {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal update status');
      } catch (e) {
        throw Exception('Gagal update status: ${response.body}');
      }
    }
  }

  static Future<StatisticsModel> getStatistics(String filter) async { // 1. Terima filter
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/admin/statistics/$filter'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
        return StatisticsModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Gagal memuat data statistik');
      }
    } else {
      throw Exception('Gagal memuat data statistik: ${response.body}');
    }
  }
}
