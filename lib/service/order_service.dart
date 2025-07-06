import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/order.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final String _baseUrl = 'http://10.0.2.2:8000/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Future<Map<String, String>> _getAuthHeaderForMultipart() async {
  //   final token = await _getToken();
  //   return {
  //     if(token != null) 'Authorization': 'Bearer $token'
  //   };
  // }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
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

   // NEW: Place Order Method
  Future<void> placeOrder({required String shippingAddress,required String phoneNumber, required List<Map<String, dynamic>> items}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'), // Assuming this is your order creation endpoint
      headers: await _getAuthHeaders(),
      body: json.encode({
        'shipping_address': shippingAddress,
        'phone_number': phoneNumber,
        'items': items, // Array of {product_id, quantity, unit_price}
      }),
    );

    print('Place Order Response Status: ${response.statusCode}');
    print('Place Order Response Body: ${response.body}');

    if (response.statusCode == 201) {
      // Order created successfully
      // The backend should handle stock reduction and return the created order details
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in to place an order.');
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Order validation failed.';
      if (errorData.containsKey('errors')) {
        Map<String, dynamic> errors = errorData['errors'];
        errors.forEach((key, value) => errorMessage += '\n${value[0]}');
      }
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to place order. Status code: ${response.statusCode}\nResponse: ${response.body}');
    }
  }

  Future<Order> updateOrderStatus(int orderId, String newStatus) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/orders/$orderId/status'),
      headers: await _getAuthHeaders(),
      body: json.encode({'order_status': newStatus}),
    );

    print('Update Order Status Response Status: ${response.statusCode}');
    print('Update Order Status Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Order.fromJson(responseData['order']); // Assuming Laravel returns the updated order
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Unauthorized or Permission denied to update order status.');
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Status update validation failed.';
      if (errorData.containsKey('errors')) {
        Map<String, dynamic> errors = (errorData['errors'] as Map).cast<String, dynamic>();
        String validationMessages = '';
        errors.forEach((field, messages) {
          validationMessages += '${field}: ${(messages as List).join(', ')}\n';
        });
        errorMessage = 'Validation Errors:\n$validationMessages';
      }
      throw Exception(errorMessage);
    } else {
      throw Exception('Failed to update order status. Status code: ${response.statusCode}\nResponse: ${response.body}');
    }
  }
}