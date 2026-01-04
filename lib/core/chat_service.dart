import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class ChatService {
  static Future<String> sendMessage(String message) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Unauthorized: No token found');
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          ...ApiConfig.headers,
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? "Maaf, saya tidak mengerti.";
      } else if (response.statusCode == 503) {
        throw Exception('Chatbot belum siap (Model loading/error).');
      } else {
        // Cek apakah token expired (401)
        if (await AuthService.checkTokenExpiration(response)) {
          return "Session expired"; // Atau throw exception
        }
        
        final error = jsonDecode(response.body)['error'] ?? 'Terjadi kesalahan';
        throw Exception(error);
      }
    } catch (e) {
      rethrow;
    }
  }
}
