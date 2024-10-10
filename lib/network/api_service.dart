import 'dart:convert';
import 'package:admin/models/user.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  String? _accessToken;

  Future<AuthResponse> signup(String username, String email, String firstName,
      String lastName, String password, String password2) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'password2': password2,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to signup');
    }
  }

  Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      _accessToken = authResponse.accessToken;
      return authResponse;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<User>> getProfiles() async {
    if (_accessToken == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/profiles/'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load profiles');
    }
  }
}