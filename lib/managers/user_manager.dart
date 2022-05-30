import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  static const TOKEN_KEY = "access_token";

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(TOKEN_KEY);

    return token;
  }

  Future<void> setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(TOKEN_KEY, token);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt("userId");
  }

  Future<bool> setUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.setInt("userId", userId);
  }

  Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();

    return await prefs.clear();
  }
}
