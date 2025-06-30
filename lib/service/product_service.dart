import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/product.dart';
import 'package:http/http.dart' as http;

class ProductService {
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

  // --- Fetch Products Method (Accepts optional categoryId) ---
  Future<List<Product>> fetchProducts({int? categoryId}) async {
    String url = '$_baseUrl/products';
    if (categoryId != null) {
      url += '?category_id=$categoryId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> productsJson = json.decode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products. Status code: ${response.statusCode}');
    }
  }

  // --- Create Product (Admin Only) ---
   // --- EDITED: Create Product (Admin Only) to handle image upload ---
  Future<Product> createProduct(Product product, {File? imageFile}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/products'));

    // Add headers (Authorization only, Content-Type is handled by MultipartRequest)
    request.headers.addAll(await _getAuthHeaderForMultipart());

    // Add product data fields
    request.fields['name'] = product.name;
    request.fields['description'] = product.description ?? '';
    request.fields['price'] = product.price.toString();
    request.fields['stock_quantity'] = product.stockQuantity.toString();
    if (product.categoryId != null) {
      request.fields['category_id'] = product.categoryId.toString();
    }
    // Only send image_url if no imageFile is provided and there's a URL
    if (imageFile == null && product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      request.fields['image_url'] = product.imageUrl!;
    }

    // Add image file if available
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image', // This must match the name Laravel expects (e.g., $request->file('image'))
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied. Admin access required to create products.');
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Validation failed.';
      if (errorData.containsKey('errors')) {
        Map<String, dynamic> errors = errorData['errors'];
        errors.forEach((key, value) => errorMessage += '\n${value[0]}');
      }
      throw Exception(errorMessage);
    }
    else {
      throw Exception('Failed to create product. Status code: ${response.statusCode}\nResponse: ${response.body}');
    }
  }

  // --- EDITED: Update Product (Admin Only) to handle image upload ---
  Future<Product> updateProduct(int id, Product product, {File? imageFile}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/products/$id'));

    // Laravel expects PUT, but MultipartRequest only supports POST.
    // So, we'll send _method=PUT in the form data for Laravel to interpret it as a PUT request.
    request.fields['_method'] = 'PUT';

    // Add headers (Authorization only)
    request.headers.addAll(await _getAuthHeaderForMultipart());

    // Add product data fields
    request.fields['name'] = product.name;
    request.fields['description'] = product.description ?? '';
    request.fields['price'] = product.price.toString();
    request.fields['stock_quantity'] = product.stockQuantity.toString();
    if (product.categoryId != null) {
      request.fields['category_id'] = product.categoryId.toString();
    } else {
        request.fields['category_id'] = ''; // Ensure it's explicitly sent as empty string if null
    }

    // Handle image_url or image file
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image', // This must match the name Laravel expects
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ));
      request.fields['image_url'] = ''; // Clear existing URL if new image is uploaded
    } else {
      // If no new image file, send the existing URL if it's there
      request.fields['image_url'] = product.imageUrl ?? '';
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied. Admin access required to update products.');
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Validation failed.';
      if (errorData.containsKey('errors')) {
        Map<String, dynamic> errors = errorData['errors'];
        errors.forEach((key, value) => errorMessage += '\n${value[0]}');
      }
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to update product. Status code: ${response.statusCode}\nResponse: ${response.body}');
    }
  }

  // --- Delete Product (Admin Only) ---
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/products/$id'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      // Success, no content expected
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied. Admin access required to delete products.');
    } else {
      throw Exception('Failed to delete product. Status code: ${response.statusCode}');
    }
  }
}
