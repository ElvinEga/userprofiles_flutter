import 'dart:convert';

import 'package:admin/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  final SharedPreferences _prefs;

  TokenManager(this._prefs);

  static Future<TokenManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenManager(prefs);
  }

  Future<void> saveAuthResponse(AuthResponse response) async {
    if (response.accessToken != null) {
      await _prefs.setString(_accessTokenKey, response.accessToken!);
    }
    if (response.refreshToken != null) {
      await _prefs.setString(_refreshTokenKey, response.refreshToken!);
    }
    if (response.user != null) {
      await _prefs.setString(_userKey, jsonEncode(response.user!.toJson()));
    }
  }

  Future<void> saveTokens({String? accessToken, String? refreshToken}) async {
    if (accessToken != null) {
      await _prefs.setString(_accessTokenKey, accessToken);
    }
    if (refreshToken != null) {
      await _prefs.setString(_refreshTokenKey, refreshToken);
    }
  }



  Future<void> clearAll() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userKey);
  }

  String? get accessToken => _prefs.getString(_accessTokenKey);
  String? get refreshToken => _prefs.getString(_refreshTokenKey);
  bool get hasTokens => accessToken != null && refreshToken != null;

  User? get user {
    final userStr = _prefs.getString(_userKey);
    if (userStr != null) {
      try {
        return User.fromJson(jsonDecode(userStr));
      } catch (e) {
        print('Error parsing stored user data: $e');
        return null;
      }
    }
    return null;
  }

  bool get isAuthenticated => accessToken != null && user != null;

}