import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://10.0.2.2:8000/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getAuthHeaderForMultipart() async {
    final token = await _getToken();
    return {
      if(token != null) 'Authorization': 'Bearer $token'
    };
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

  // NEW: Update User Profile Method
  Future<Auth> updateUserProfile({required String name, required String email, File? imageFile}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/user/profile')); // Assuming this endpoint
    request.headers.addAll(await _getAuthHeaderForMultipart());
    request.fields['_method'] = 'PUT'; // Laravel expects PUT for updates

    request.fields['name'] = name;
    request.fields['email'] = email; // Include email, even if not directly editable by user

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image', // This must match the name Laravel expects (e.g., $request->file('profile_image'))
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ));
    } else {
      request.fields['remove_profile_image'] = 'true';
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        throw Exception('Profile updated, but no response data to parse. Status: ${response.statusCode}');
      }
      try {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Auth updatedUser = Auth.fromJson(responseData['user']); // Assuming 'user' key in response

        // Update stored user data in secure storage
        await _secureStorage.write(key: 'user_name', value: updatedUser.name);
        await _secureStorage.write(key: 'user_email', value: updatedUser.email);
        if (updatedUser.profileImageUrl != null) {
          await _secureStorage.write(key: 'profile_image_url', value: updatedUser.profileImageUrl!);
        } else {
          await _secureStorage.delete(key: 'profile_image_url'); // Clear if image was removed
        }

        return updatedUser;
      } catch (e) {
        throw Exception('Profile updated, but response parsing failed. Status: ${response.statusCode}. Body: ${response.body}');
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Unauthorized or Permission denied to update profile.');
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Validation failed.';
      if (errorData.containsKey('errors')) {
        Map<String, dynamic> errors = errorData['errors'];
        errors.forEach((key, value) => errorMessage += '\n${value[0]}');
      }
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to update profile. Status code: ${response.statusCode}\nResponse: ${response.body}');
    }
  }

}
