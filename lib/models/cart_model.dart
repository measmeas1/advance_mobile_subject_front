// lib/models/cart_model.dart

// This file defines the data structure for a single item within the shopping cart.

class CartItem {
  final int productId;
  final String productName;
  final double price;
  final String? imageUrl;
  int quantity; // Quantity can be changed in the cart

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.imageUrl,
    required this.quantity,
  });

  // Factory constructor to create a CartItem from a JSON map (for loading from storage)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      productName: json['productName'],
      price: double.parse(json['price'].toString()), // Ensure price is parsed as double
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
    );
  }

  // Method to convert a CartItem to a JSON map (for saving to storage)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
}
