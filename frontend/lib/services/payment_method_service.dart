import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/models/payment_method_model.dart';

class PaymentMethodService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  static Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$_baseUrl/payment_method'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      if (body['status'] == true) {
        List<dynamic> data = body['data'];
        return data.map((json) => PaymentMethodModel.fromJson(json)).toList();
      } else {
        throw Exception(body['message'] ?? 'Gagal memuat metode pembayaran');
      }
    } else {
      throw Exception('Gagal memuat metode pembayaran (${response.statusCode})');
    }
  }
}
