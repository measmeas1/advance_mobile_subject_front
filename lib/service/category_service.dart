import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/order.dart';
import 'package:http/http.dart' as http;

class CategoryService {
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

  // --- Fetch Categories Method ---
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/categories'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> categoriesJson = json.decode(response.body);
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories. Status code: ${response.statusCode}');
    }
  }

  // --- Create Category (Admin Only) ---
  Future<Category> createCategory(Category category) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/categories'),
      headers: await _getAuthHeaders(),
      body: json.encode({
        'name': category.name,
        'description': category.description,
        'slug': category.slug,
        'parent_id': category.parentId,
      }),
    );

    if (response.statusCode == 201) {
      return Category.fromJson(json.decode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied. Admin access required to create categories.');
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Validation failed.';
      if (errorData.containsKey('errors')) {
        Map<String, dynamic> errors = errorData['errors'];
        errors.forEach((key, value) => errorMessage += '\n${value[0]}');
      }
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to create category. Status code: ${response.statusCode}');
    }
  }

  // --- Update Category (Admin Only) ---
  Future<Category> updateCategory(int id, Category category) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/categories/$id'),
      headers: await _getAuthHeaders(),
      body: json.encode({
        'name': category.name,
        'description': category.description,
        'slug': category.slug,
        'parent_id': category.parentId,
      }),
    );

    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied. Admin access required to update categories.');
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Validation failed.';
      if (errorData.containsKey('errors')) {
        Map<String, dynamic> errors = errorData['errors'];
        errors.forEach((key, value) => errorMessage += '\n${value[0]}');
      }
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to update category. Status code: ${response.statusCode}');
    }
  }

  // --- Delete Category (Admin Only) ---
  Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/categories/$id'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      // Success, no content expected
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied. Admin access required to delete categories.');
    } else {
      throw Exception('Failed to delete category. Status code: ${response.statusCode}');
    }
  }

  // --- Fetch Orders Method ---
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders'), // This endpoint handles admin vs. customer filtering
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> ordersJson = json.decode(response.body);
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied. You do not have access to view these orders.');
    } else {
      throw Exception('Failed to load orders. Status code: ${response.statusCode}');
    }
  }
}