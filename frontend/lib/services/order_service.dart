import 'dart:convert';
import 'dart:io'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/models/cart_model.dart';
import '/models/my_order_item_model.dart';
import '/models/admin_order_model.dart';
import '/models/statistics_model.dart';

class OrderService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';
  // BASE URL KHUSUS GAMBAR/STORAGE (emulator default)
  static const String _imageBaseUrl = 'http://10.0.2.2:8000/'; 
  static const String _storageBaseUrl = 'http://10.0.2.2:8000/storage/';
  // Pastikan 10.0.2.2 benar untuk emulator Android

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ==================== CUSTOMER: CHECKOUT ====================

  /// Proses checkout, memindahkan item keranjang ke order baru.
  /// Mengembalikan response dari server yang berisi order_id.
  static Future<Map<String, dynamic>> checkout({
    required List<CartItemModel> items,
    required int paymentMethodId,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    List<Map<String, dynamic>> itemsJson = items.map((item) {
      return {
        // Hanya kirim ID item keranjang (order_item_id) untuk dipindahkan
        'product_id': item.productId,
        'quantity': item.quantity,
        'order_item_id': item.orderItemId,
      };
    }).toList();

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
        // Menggunakan 'status' agar konsisten dengan BaseResource Laravel
        return {
          'status': false, 
          'message': error['message'] ?? 'Gagal melakukan checkout',
        };
      } catch (e) {
        throw Exception('Response bukan JSON valid: ${response.body}');
      }
    }
  }

  // ==================== CUSTOMER: UPLOAD BUKTI PEMBAYARAN ====================

  /// Mengunggah bukti pembayaran sebagai Multipart File.
  static Future<Map<String, dynamic>> uploadPaymentProof(
    int orderId,
    File imageFile,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/payments/$orderId/proof'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.files.add(await http.MultipartFile.fromPath(
      'proof_image', 
      imageFile.path,
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // 🔥 Tambahkan full URL di sini
      if (jsonResponse['data']['proof_path'] != null) {
        jsonResponse['data']['proof_url'] = 
            '$_storageBaseUrl${jsonResponse['data']['proof_path']}';
      }
      return jsonResponse;
    } else {
      final message = jsonResponse['message'] ?? 'Gagal mengupload bukti pembayaran';
      throw Exception(message);
    }
  }

  // ==================== CUSTOMER: GET PAYMENT DETAIL ====================

  /// Mendapatkan detail pembayaran (termasuk proof_url) untuk Customer.
  static Future<Map<String, dynamic>> getCustomerPaymentDetail(int orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/payments/order/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final jsonResponse = jsonDecode(response.body);
    
    if (response.statusCode == 200 && jsonResponse['status'] == true) {
      final Map<String, dynamic> data = jsonResponse['data'];
      
      // 🔥 Konstruksi URL dari proof_path
      if (data['proof_path'] != null && data['proof_path'].isNotEmpty) { 
        data['proof_url'] = '$_storageBaseUrl${data['proof_path']}'; 
      } else {
        data['proof_url'] = null;
      }
      
      print('✅ Proof URL: ${data['proof_url']}'); 
      return data;
    } else {
      final message = jsonResponse['message'] ?? 'Gagal memuat detail pembayaran';
      throw Exception(message); 
    }
  }

  // ==================== CUSTOMER: RIWAYAT PESANAN ====================

  /// Mendapatkan semua item order milik customer yang sedang login.
  static Future<List<MyOrderItemModel>> getMyOrderItems() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/order-items'), // OrderItemsController@index
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
        return [];
      }
    } 
    else if (response.statusCode == 404) {
      return [];
    } 
    else {
      throw Exception('Gagal memuat data pesanan: ${response.body}');
    }
  }

  /// Konfirmasi bahwa customer telah menerima pesanan.
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
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['status'] == true; // Berhasil
    } else {
      try {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal update status');
      } catch (e) {
        throw Exception('Gagal update status: ${response.body}');
      }
    }
  }

  // ==================== ADMIN: KELOLA PESANAN ====================

  /// Mendapatkan semua data order untuk admin.
  static Future<List<AdminOrderModel>> getAdminOrders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/orders'), // OrdersController@index
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((item) => AdminOrderModel.fromJson(item)).toList();
      } else {
        return []; 
      }
    } else {
      throw Exception('Gagal memuat data pesanan: ${response.body}');
    }
  }
  
  /// Mengupdate status pesanan (oleh Admin).
  static Future<Map<String, dynamic>> updateOrderStatus(
      int orderId, 
      String newStatus, 
      {String? validationNote}) async {
    
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.patch(
      // Endpoint: PATCH /admin/orders/{id}/status
      Uri.parse('$_baseUrl/admin/orders/$orderId/status'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': newStatus,
        'validation_note': validationNote, // Catatan admin jika dibatalkan
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

  // Fungsi helper untuk admin
  static Future<Map<String, dynamic>> getAdminPaymentDetail(int orderId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token admin tidak ditemukan.');

    final response = await http.get(
      Uri.parse('$_baseUrl/admin/payments/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == true) {
      final data = jsonResponse['data'];
      
      // 🔥 Konstruksi URL dari proof_path
      if (data['proof_path'] != null && data['proof_path'].isNotEmpty) {
        data['proof_url'] = '$_storageBaseUrl${data['proof_path']}';
      } else {
        data['proof_url'] = null;
      }
      
      return data;
    } else {
      throw Exception(jsonResponse['message'] ?? 'Gagal memuat detail payment');
    }
  }


  /// Batalkan pesanan oleh customer.
  static Future<bool> cancelOrder(int orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.delete( // Menggunakan DELETE method
      Uri.parse('$_baseUrl/my-orders/$orderId/cancel'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['status'] == true; 
    } else {
      try {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal membatalkan pesanan');
      } catch (e) {
        throw Exception('Gagal membatalkan pesanan: ${response.body}');
      }
    }
  }

  // ==================== ADMIN: STATISTIK ====================

  /// Mendapatkan data statistik berdasarkan filter (harian/bulanan/tahunan).
  static Future<StatisticsModel> getStatistics(String filter) async {
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