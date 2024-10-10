import 'dart:io';
import 'package:admin/models/user.dart';
import 'package:admin/network/token.dart';
import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final Dio _dio;
  final TokenManager _tokenManager;

  ApiService(this._tokenManager) : _dio = Dio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_tokenManager.accessToken != null) {
            options.headers['Authorization'] = 'Bearer ${_tokenManager.accessToken}';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            if (await _refreshToken()) {
              // Retry the original request
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _tokenManager.refreshToken;
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '$baseUrl/token/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        await _tokenManager.saveTokens(
          accessToken: response.data['access'],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<AuthResponse> signup(String username, String email, String firstName,
      String lastName, String password, String password2) async {
    try {
      final response = await _dio.post(
        '$baseUrl/signup/',
        data: {
          'username': username,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
          'password2': password2,
        },
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login/',
        data: {
          'username': username,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<User>> getProfiles() async {
    try {
      final response = await _dio.get('$baseUrl/profiles/');
      List<dynamic> jsonList = response.data;
      return jsonList.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> createProfile(String username, String email, String firstName,
      String lastName, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/profiles/',
        data: {
          'username': username,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
        },
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateProfile(int userId, Map<String, dynamic> updatedData) async {
    try {
      final response = await _dio.put(
        '$baseUrl/profiles/$userId/',
        data: updatedData,
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProfile(int userId) async {
    try {
      await _dio.delete('$baseUrl/profiles/$userId/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.error is SocketException) {
      return NetworkException('Network error occurred. Please check your connection.');
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        if (statusCode == 400) {
          return ValidationException(data.toString());
        } else if (statusCode == 401) {
          return AuthenticationException('Authentication failed');
        } else if (statusCode == 403) {
          return AuthorizationException('You don\'t have permission to perform this action');
        }
        return ServerException('Server error occurred');
      default:
        return UnknownException('An unexpected error occurred');
    }
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}

class AuthorizationException implements Exception {
  final String message;
  AuthorizationException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);
}