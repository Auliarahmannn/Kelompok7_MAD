import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campgear/models/user_model.dart';

class UserService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Get token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // GET - Ambil profil user yang sedang login
  static Future<UserModel> getProfile() async {
  try {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Sesuaikan dengan struktur JSON dari backend
      if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
        return UserModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Gagal memuat profil');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Token tidak valid. Silakan login kembali.');
    } else {
      throw Exception('Gagal memuat profil: ${response.statusCode}');
    }
  } catch (e) {
    print('Error getProfile: $e');
    rethrow;
  }
}


  // PUT - Update profil user
  static Future<UserModel> updateProfile({
  String? name,
  String? email,
  String? phone,
  String? address,
  String? currentPassword,
  String? newPassword,
  String? newPasswordConfirmation,
}) async {
  try {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    // Siapkan data body dinamis
    Map<String, dynamic> body = {};

    if (name?.isNotEmpty ?? false) body['name'] = name;
    if (email?.isNotEmpty ?? false) body['email'] = email;
    if (phone?.isNotEmpty ?? false) body['phone'] = phone;
    if (address?.isNotEmpty ?? false) body['address'] = address;

    if (currentPassword?.isNotEmpty ?? false) {
      body['current_password'] = currentPassword;
    }
    if (newPassword?.isNotEmpty ?? false) {
      body['new_password'] = newPassword;
    }
    if (newPasswordConfirmation?.isNotEmpty ?? false) {
      body['new_password_confirmation'] = newPasswordConfirmation;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
        return UserModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Gagal memperbarui profil');
      }
    } else if (response.statusCode == 400) {
      throw Exception(jsonResponse['message'] ?? 'Password lama tidak sesuai');
    } else if (response.statusCode == 422) {
      final errors = jsonResponse['data'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final firstError = errors.values.first;
        throw Exception(firstError is List ? firstError.first : firstError);
      }
      throw Exception('Validasi gagal');
    } else {
      throw Exception('Gagal memperbarui profil: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updateProfile: $e');
    rethrow;
  }
}


  // DELETE - Hapus akun user
  static Future<bool> deleteAccount({required String password}) async {
  try {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak ditemukan. Silakan login kembali.');

    final response = await http.delete(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'password': password}), // kirim password
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['success'] == true;
    } else if (response.statusCode == 401) {
      print('Akun kemungkinan sudah dihapus (401 Unauthenticated).');
      return true;
    } else if (response.statusCode == 403) {
      // Password salah
      throw Exception('Password salah. Hapus akun dibatalkan.');
    } else {
      throw Exception('Gagal menghapus akun: ${response.statusCode}');
    }
  } catch (e) {
    print('Error deleteAccount: $e');
    rethrow;
  }
}


  // GET - Ambil user berdasarkan ID (untuk admin)
  static Future<UserModel> getUserById(int id) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return UserModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Gagal memuat data user');
        }
      } else {
        throw Exception('Gagal memuat data user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getUserById: $e');
      rethrow;
    }
  }
  
  // GET - Ambil semua customer (untuk admin)
  static Future<List<UserModel>> getAllCustomersForAdmin() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/customers'), 
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          // Ubah list JSON menjadi List<UserModel>
          List<dynamic> dataList = jsonResponse['data'];
          return dataList.map((json) => UserModel.fromJson(json)).toList();
        } else {
          // Jika status true tapi data null (kosong)
          if (jsonResponse['status'] == true) return [];
          throw Exception(jsonResponse['message'] ?? 'Gagal memuat data customer');
        }
      } else {
        throw Exception('Gagal memuat data customer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getAllCustomersForAdmin: $e');
      rethrow;
    }
  }
}