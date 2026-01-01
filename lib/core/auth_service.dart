import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_config.dart';

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;

  // ================= GOOGLE SIGN-IN INSTANCE =================
  // Konfigurasi Google Sign-In
  // Untuk Android: tidak perlu clientId (menggunakan SHA-1 dari Google Console)
  // Untuk Web: tambahkan clientId jika diperlukan
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  /// ================= LOGIN (Username/Password) =================
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

  /// ================= GOOGLE SIGN-IN =================
  /// Login menggunakan akun Google
  /// Return: Map dengan 'success' (bool) dan 'message' (String)
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // 1. Trigger proses sign-in Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User membatalkan sign-in
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Login dibatalkan',
        };
      }

      // 2. Ambil data dari Google account
      final String email = googleUser.email;
      final String name = googleUser.displayName ?? 'User';
      final String googleId = googleUser.id;

      // 3. Kirim data ke backend untuk diproses
      final response = await http.post(
        Uri.parse('$baseUrl/api/google-login'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
          'name': name,
          'google_id': googleId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();

        // 🔐 SIMPAN JWT
        await prefs.setString('token', data['token']);
        await prefs.setString('login_method', 'google'); // Tandai login via Google

        // 🧑 DATA USER
        final user = data['user'];
        if (user['id'] != null) await prefs.setInt('user_id', user['id']);
        await prefs.setString('username', user['username']);
        await prefs.setString('full_name', user['full_name']);
        await prefs.setString('role', user['role']);
        if (user['email'] != null) await prefs.setString('email', user['email']);
        if (user['phone'] != null) await prefs.setString('phone', user['phone']);
        if (user['bio'] != null) await prefs.setString('bio', user['bio']);

        return {
          'success': true,
          'message': 'Login berhasil',
        };
      } else {
        // Gagal dari backend
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['error'] ?? 'Terjadi kesalahan pada server',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// ================= GOOGLE SIGN-OUT =================
  /// Sign out dari Google (jika login via Google)
  static Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Abaikan error jika tidak login via Google
    }
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
    // Sign out dari Google juga jika login via Google
    await signOutGoogle();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// ================= CHECK LOGIN =================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  /// ================= GET TOKEN =================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ================= CHECK IF LOGGED IN VIA GOOGLE =================
  static Future<bool> isGoogleLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_method') == 'google';
  }
}
