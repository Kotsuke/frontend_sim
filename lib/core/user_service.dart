import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/auth_service.dart';

import 'api_config.dart';

class UserService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> getProfile(int userId) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: {
        'ngrok-skip-browser-warning': 'true', // Add explicit skip warning
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal ambil profil');
    }
  }

  static Future<bool> updateProfile(int userId, Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }
}
