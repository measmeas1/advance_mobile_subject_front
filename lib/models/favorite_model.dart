// lib/models/favorite_item.dart

class FavoriteModel {
  final int productId;
  final String productName;
  final double price;
  final String? imageUrl;
  final String addedAt; // Timestamp when added to favorites

  FavoriteModel({
    required this.productId,
    required this.productName,
    required this.price,
    this.imageUrl,
    required this.addedAt,
  });

  // Factory constructor to create a FavoriteModel from a JSON response from Laravel
  // This assumes the Laravel /api/favorites endpoint returns product details directly
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      productId: json['id'], // Assuming 'id' is the product_id from Laravel's favorite index
      productName: json['name'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      addedAt: json['added_at'], // This should be the 'created_at' from the favorite record
    );
  }

  // Method to convert a FavoriteModel to a map for sending to Laravel (e.g., for adding)
  // Only product_id is typically needed for adding a favorite
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
    };
  }
}
