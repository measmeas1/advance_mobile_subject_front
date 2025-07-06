import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/models/product.dart';

class CartService {
  // final String _baseUrl = 'http://10.0.2.2:8000/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

 // NEW: Cart Management Methods (Client-side using FlutterSecureStorage)
  static const String _cartKey = 'user_cart';

  Future<List<CartItem>> getCartItems() async {
    try {
      final String? cartJsonString = await _secureStorage.read(key: _cartKey);
      if (cartJsonString == null || cartJsonString.isEmpty) {
        return [];
      }
      final List<dynamic> cartJsonList = json.decode(cartJsonString);
      return cartJsonList.map((itemJson) => CartItem.fromJson(itemJson)).toList();
    } catch (e) {
      print('Error getting cart items: $e');
      return []; // Return empty list on error
    }
  }

  Future<void> _saveCartItems(List<CartItem> cartItems) async {
    try {
      final String cartJsonString = json.encode(cartItems.map((item) => item.toJson()).toList());
      await _secureStorage.write(key: _cartKey, value: cartJsonString);
    } catch (e) {
      print('Error saving cart items: $e');
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    List<CartItem> cartItems = await getCartItems();
    bool found = false;

    for (var item in cartItems) {
      if (item.productId == product.id) {
        item.quantity += quantity;
        found = true;
        break;
      }
    }

    if (!found) {
      cartItems.add(CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: quantity,
      ));
    }
    await _saveCartItems(cartItems);
  }

  Future<void> updateCartItemQuantity(int productId, int newQuantity) async {
    List<CartItem> cartItems = await getCartItems();
    if (newQuantity <= 0) {
      cartItems.removeWhere((item) => item.productId == productId);
    } else {
      for (var item in cartItems) {
        if (item.productId == productId) {
          item.quantity = newQuantity;
          break;
        }
      }
    }
    await _saveCartItems(cartItems);
  }

  Future<void> removeCartItem(int productId) async {
    List<CartItem> cartItems = await getCartItems();
    cartItems.removeWhere((item) => item.productId == productId);
    await _saveCartItems(cartItems);
  }

  Future<void> clearCart() async {
    await _secureStorage.delete(key: _cartKey);
  }
}