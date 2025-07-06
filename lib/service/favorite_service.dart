// lib/service/favorite_service.dart (HTTP-based)

import 'dart:convert';
import 'package:frontend/models/favorite_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/product.dart'; // Import Product model to use in addFavorite

class FavoriteService {
  final String _baseUrl = 'http://10.0.2.2:8000/api'; // Your Laravel backend URL
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Add a product to favorites
  Future<void> addFavorite(Product product) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/favorites'),
      headers: await _getAuthHeaders(),
      body: json.encode({'product_id': product.id}),
    );

    if (response.statusCode == 201) {
      // Successfully added
      print('Product ${product.name} added to favorites.');
    } else if (response.statusCode == 409) { // Conflict - already favorited
      throw Exception('Product is already in favorites.');
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Failed to add to favorites.';
      throw Exception(errorMessage);
    }
  }

  // Remove a product from favorites
  Future<void> removeFavorite(int productId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/favorites/$productId'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      // Successfully removed
      print('Product ID $productId removed from favorites.');
    } else if (response.statusCode == 404) {
      throw Exception('Product not found in favorites.');
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Failed to remove from favorites.';
      throw Exception(errorMessage);
    }
  }

  // Check if a product is favorited by the user
  Future<bool> isFavorite(int productId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/favorites/check/$productId'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['is_favorited'] ?? false;
    } else {
      // Handle error, e.g., unauthorized or server error
      print('Error checking favorite status: ${response.statusCode} ${response.body}');
      return false; // Assume not favorited on error
    }
  }

  // Get all favorited products for the user
  Future<List<FavoriteModel>> getFavorites() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/favorites'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> favoritesJson = json.decode(response.body);
      return favoritesJson.map((json) => FavoriteModel.fromJson(json)).toList();
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Failed to load favorites.';
      throw Exception(errorMessage);
    }
  }
}
