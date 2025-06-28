// lib/models/product.dart

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String category;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.isFavorite = false,
  });

  // Optionally, add a method to toggle favorite
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}
