// lib/Screens/users/customers/favorite_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/favorite_model.dart';
import 'package:frontend/service/favorite_service.dart';
import 'package:frontend/Screens/users/customers/products/product_detail_screen.dart'; // For navigating to product detail
import 'package:frontend/models/product.dart'; // Import Product model to create dummy product
import 'package:frontend/Screens/users/components/bottom_nav.dart'; // Assuming you might navigate to a main product list via bottom nav

class FavoriteScreen extends StatefulWidget {
  final Auth user;

  const FavoriteScreen({super.key, required this.user});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<FavoriteModel>> _favoritesFuture;
  final FavoriteService _favoriteService = FavoriteService();

  // Define your refined color palette consistent with other screens
  static const Color _primaryGreen = Color(
    0xFF4CAF50,
  ); // A vibrant, appealing green
  static const Color _lightGreenBackground = Color(
    0xFFE8F5E9,
  ); // Your chosen light green base
  static const Color _textColor = Color(
    0xFF333333,
  ); // Dark grey for general text
  static const Color _lightTextColor = Color(
    0xFF757575,
  ); // Lighter grey for secondary text
  static const Color _errorColor = Color(
    0xFFD32F2F,
  ); // Standard red for errors/removals
  static const Color _cardColor = Colors.white; // White for cards

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() {
      _favoritesFuture = _favoriteService.getFavorites();
    });
  }

  Future<void> _removeFavorite(int productId, String productName) async {
    try {
      await _favoriteService.removeFavorite(productId);
      _showSnackBar(
        '$productName removed from favorites.',
        _errorColor,
      ); // Use _errorColor for removal
      _fetchFavorites(); // Refresh the list
    } catch (e) {
      _showSnackBar(
        'Failed to remove from favorites: ${e.toString().replaceFirst('Exception: ', '')}',
        _errorColor,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ), // Consistent border radius
          margin: const EdgeInsets.all(16), // Consistent margin
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreenBackground, // Consistent background color
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryGreen, // Use primary green for app bar
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 6,
        leading: IconButton(
          // Custom back button for iOS arrow
          icon: const Icon(Icons.arrow_back_ios_new_rounded), // iOS arrow icon
          onPressed: () => Navigator.of(context).pop(), // Standard pop behavior
        ),
      ),
      body: FutureBuilder<List<FavoriteModel>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
              ), // Green loader
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0), // Increased padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: _errorColor,
                    ), // Error icon
                    const SizedBox(height: 20),
                    Text(
                      'Oops! Something went wrong.',
                      style: TextStyle(
                        fontSize: 20,
                        color: _textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Failed to load favorites: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                      style: TextStyle(color: _lightTextColor, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchFavorites,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Colors.grey[400],
                  ), // Larger icon
                  const SizedBox(height: 25), // More spacing
                  Text(
                    'Your favorite list is empty!',
                    style: TextStyle(
                      fontSize: 22,
                      color: _lightTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap the heart icon on products you love to add them here.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to home or product screen, assuming index 0 is home
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  BottomNav(user: widget.user, currentIndex: 0),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Start Shopping'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final favorites = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _fetchFavorites,
              backgroundColor:
                  _cardColor, // White background for refresh indicator
              color: _primaryGreen, // Green progress indicator
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0), // Consistent padding
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                    ), // Vertical margin only
                    elevation: 5, // A subtle lift
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ), // Rounded corners
                    color: _cardColor, // Ensure card background is white
                    child: InkWell(
                      // Use InkWell for tap effect
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // Create a dummy Product object from FavoriteItem for navigation
                        final dummyProduct = Product(
                          id: item.productId,
                          name: item.productName,
                          price: item.price,
                          stockQuantity: 1, // Placeholder
                          imageUrl: item.imageUrl,
                          description:
                              'Favorited product details will load here.', // Placeholder
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailScreen(
                                  product: dummyProduct,
                                  user: widget.user,
                                ),
                          ),
                        ).then(
                          (_) => _fetchFavorites(),
                        ); // Refresh after returning from detail screen
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(
                          15.0,
                        ), // Padding inside the card
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    Colors
                                        .grey[200], // Light grey background for image area
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  item.imageUrl ??
                                      'https://placehold.co/80x80/E0E0E0/000000?text=No+Img',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 35,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: _textColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: _primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Remove Button (Heart icon)
                            IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: _errorColor,
                                size: 30,
                              ), // Red heart for remove
                              onPressed:
                                  () => _removeFavorite(
                                    item.productId,
                                    item.productName,
                                  ),
                              tooltip: 'Remove from Favorites',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
