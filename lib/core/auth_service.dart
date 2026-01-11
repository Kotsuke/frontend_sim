import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_config.dart';
import 'navigation_service.dart';
import '../auth/login_page.dart';

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;

  // ================= GOOGLE SIGN-IN INSTANCE =================
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// ================= LOGIN USERNAME/PASSWORD =================
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: ApiConfig.headers,
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        // SIMPAN JWT
        final token = data['token'] as String?;
        if (token != null) await prefs.setString('token', token);

        // DATA USER
        final Map<String, dynamic> user = data['user'] ?? {};
        if (user.containsKey('id')) await prefs.setInt('user_id', user['id']);
        await prefs.setString('username', user['username'] ?? '');
        await prefs.setString('full_name', user['full_name'] ?? '');
        await prefs.setString('role', user['role'] ?? '');
        if (user.containsKey('email')) await prefs.setString('email', user['email']);
        if (user.containsKey('phone')) await prefs.setString('phone', user['phone']);
        if (user.containsKey('bio')) await prefs.setString('bio', user['bio']);

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  /// ================= GOOGLE SIGN-IN =================
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return {'success': false, 'message': 'Login dibatalkan'};

      final response = await http.post(
        Uri.parse('$baseUrl/api/google-login'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': googleUser.email,
          'name': googleUser.displayName ?? 'User',
          'google_id': googleUser.id,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        // SIMPAN JWT & METODE LOGIN
        final token = data['token'] as String?;
        if (token != null) await prefs.setString('token', token);
        await prefs.setString('login_method', 'google');

        // DATA USER
        final Map<String, dynamic> user = data['user'] ?? {};
        if (user.containsKey('id')) await prefs.setInt('user_id', user['id']);
        await prefs.setString('username', user['username'] ?? '');
        await prefs.setString('full_name', user['full_name'] ?? '');
        await prefs.setString('role', user['role'] ?? '');
        if (user.containsKey('email')) await prefs.setString('email', user['email']);
        if (user.containsKey('phone')) await prefs.setString('phone', user['phone']);
        if (user.containsKey('bio')) await prefs.setString('bio', user['bio']);

        return {'success': true, 'message': 'Login berhasil'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['error'] ?? 'Terjadi kesalahan server'};
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// ================= GOOGLE SIGN-OUT =================
  static Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  /// ================= REGISTER =================
  static Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
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
    } catch (e) {
      debugPrint('Register Error: $e');
      return false;
    }
  }

  /// ================= LOGOUT =================
  static Future<void> logout() async {
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

  /// ================= CHECK GOOGLE LOGIN =================
  static Future<bool> isGoogleLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_method') == 'google';
  }

  /// ================= FORCE LOGOUT =================
  static Future<void> forceLogout() async {
    await logout();

    final context = NavigationService.navigatorKey.currentState?.context;
    if (context != null) {
      NavigationService.navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi telah berakhir. Silakan login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ================= CHECK TOKEN EXPIRATION =================
  static Future<bool> checkTokenExpiration(http.Response response) async {
    if (response.statusCode == 401) {
      await forceLogout();
      return true;
    }
    return false;
  }
}
