import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/auth_service.dart';

import 'api_config.dart';

class PostService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// ================= GET FEED (PUBLIC) =================
  static Future<List<dynamic>> getPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/posts'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      print('DEBUG FEED RESPONSE: ${response.body}');
      List data = jsonDecode(response.body);
      
      // MAPPING DATA AGAR SESUAI FRONTEND
      return data.map((e) {
        // 1. Fix Image URL
        if (e['image_path'] != null) {
           String rawUrl = '$baseUrl/uploads/${e['image_path']}';
           e['image_url'] = rawUrl.replaceFirst('http://', 'https://');
        }

        // 2. Fix Uploaded By (Jika backend belum join user)
        e['uploaded_by'] ??= 'User';

        // 3. Fix Verification (Jika backend belum hitung)
        if (e['verification'] == null) {
          e['verification'] = {'valid': 0, 'false': 0};
        }

        return e;
      }).toList();
    } else {
      throw Exception('Gagal memuat feed');
    }
  }

  /// ================= VERIFY POST (JWT) =================
  static Future<bool> verifyPost({
    required int postId,
    required String type, // CONFIRM / FALSE
  }) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/posts/$postId/verify'),
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'type': type}),
    );

    // Cek Token Expired
    await AuthService.checkTokenExpiration(response);

    return response.statusCode == 200;
  }
}
