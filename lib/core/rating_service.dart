import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class RatingService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<bool> submitReview(int rating, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }

  static Future<bool> hasRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_rated') ?? false;
  }

  static Future<void> setRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_rated', true);
  }

  static Future<bool> shouldShowRating() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('has_rated') ?? false) return false;

    // Check usage count (number of app opens)
    int openCount = prefs.getInt('app_open_count') ?? 0;
    openCount++;
    await prefs.setInt('app_open_count', openCount);

    // Show after 3rd open
    return openCount >= 3;
    // For testing, you might want to return true always, but let's stick to logic
    // return true; 
  }
}
