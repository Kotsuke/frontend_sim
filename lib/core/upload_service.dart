import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/auth_service.dart';

import 'api_config.dart';

class UploadService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<bool> uploadPost({
    required File image,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final token = await AuthService.getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/upload'),
    );

    // 🔐 JWT HEADER & NGROK BYPASS
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['ngrok-skip-browser-warning'] = 'true';

    // 📍 DATA LOKASI
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['address'] = address;

    // 🖼️ FILE GAMBAR
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    var response = await request.send();
    return response.statusCode == 200;
  }
}
