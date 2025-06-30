import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://10.0.2.2:8000/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<AuthResponse> loginUser(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: await _getAuthHeaders(),
      body: json.encode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(res.body));
    } else if (res.statusCode == 401 || res.statusCode == 422) {
      final errorDate = json.decode(res.body);
      String errorMessage = errorDate['meesage'] ?? 'Authentication failed';

      if (errorDate.containsKey('errors')) {
        Map<String, dynamic> errors = errorDate['errors'];
        errors.forEach((key, value) {
          errorMessage += '\n${value[0]}';
        });
      }
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to login. Status code: ${res.statusCode}');
    }
  }

  Future<AuthResponse> registerUser(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: await _getAuthHeaders(),
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (res.statusCode == 201) {
      return AuthResponse.fromJson(json.decode(res.body));
    } else if (res.statusCode == 422) {
      final errorData = json.decode(res.body);
      String errorMessage = errorData['message'] ?? 'Registration failed.';

      if (errorData.containsKey('errors')) {
        Map<String, dynamic> errors = errorData['errors'];
        errors.forEach((key, value) {
          errorMessage += '\n${value[0]}';
        });
      }
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to register. Status code: ${res.statusCode}');
    }
  }
}
