import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// ================= LOGIN =================
  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: ApiConfig.headers,
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();

      // 🔐 SIMPAN JWT
      prefs.setString('token', data['token']);

      // 🧑 DATA USER (OPSIONAL)
      final user = data['user'];
      if (user['id'] != null) await prefs.setInt('user_id', user['id']); // IMPORTANT
      prefs.setString('username', user['username']);
      prefs.setString('full_name', user['full_name']);
      prefs.setString('role', user['role']);
      if (user['email'] != null) prefs.setString('email', user['email']);
      if (user['phone'] != null) prefs.setString('phone', user['phone']);
      if (user['bio'] != null) prefs.setString('bio', user['bio']);

      return true;
    }
    return false;
  }

  /// ================= REGISTER =================
  static Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: ApiConfig.headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'full_name': fullName,
      }),
    );

    return response.statusCode == 201;
  }

  /// ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// ================= CHECK LOGIN =================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  /// ================= GET TOKEN (INI YANG HILANG) =================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
