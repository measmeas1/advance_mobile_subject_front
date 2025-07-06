// lib/screens/customer/customer_category_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/Screens/users/customers/order_history_screen.dart';
import 'package:frontend/Screens/users/customers/homepage_screen.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/Screens/users/customers/products/product_detail_screen.dart';
import 'package:frontend/Screens/users/components/bottom_nav.dart';
import 'package:frontend/service/category_service.dart';
import 'package:frontend/service/product_service.dart';

class CategoryScreen extends StatefulWidget {
  final Auth user;

  const CategoryScreen({super.key, required this.user});

  @override
  State<CategoryScreen> createState() => _CustomerCategoryScreenState();
}

class _CustomerCategoryScreenState extends State<CategoryScreen> {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  List<Category> _categories = [];
  Category?
  _selectedCategory; // Null means "All Products" or no category selected
  late Future<List<Product>> _productsFuture;

  int _currentBottomNavIndex = 1; // Keep track of the selected bottom nav tab

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchProducts(); // Initial fetch for all products or based on a default category
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetches all categories
  Future<void> _fetchCategories() async {
    try {
      final fetchedCategories = await _categoryService.fetchCategories();
      setState(() {
        _categories = fetchedCategories;
        // Optionally, select the first category by default if the list is not empty
        if (_selectedCategory == null && _categories.isNotEmpty) {
          _selectedCategory = _categories.first;
          _fetchProducts(); // Re-fetch products for the newly selected default category
        }
      });
    } catch (e) {
      _showSnackBar(
        'Failed to load categories: ${e.toString().replaceFirst('Exception: ', '')}',
        Colors.red,
      );
    }
  }

  // Fetches products based on the selected category and search query
  void _fetchProducts() {
    setState(() {
      _productsFuture = _productService.fetchProducts(
        categoryId: _selectedCategory?.id,
        // searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
    });
  }

  // Handles category selection from the left sidebar
  void _onCategorySelected(Category? category) {
    setState(() {
      _selectedCategory = category;
      _fetchProducts(); // Fetch products for the newly selected category
    });
  }

  // Helper function to show snackbar messages
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // Handles bottom navigation bar taps
  void _onBottomNavTapped(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    // Navigate to respective screens using pushReplacement to avoid stacking
    if (index == 0) {
      // Products
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomepageScreen(user: widget.user),
        ),
      );
    } else if (index == 1) {
      // Categories (current screen)
      // Already on this screen, just refresh products for current category
      _fetchProducts();
    } else if (index == 2) {
      // My Orders
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderHistoryScreen(user: widget.user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5E9),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.green[600]),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                            : null,
                  ),
                  onSubmitted: (value) {
                    _fetchProducts();
                  },
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 120, // Fixed width for category list
                    color: Color(0xFFE8F5E9), // Light background for categories
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount:
                          _categories.length + 1, // +1 for "All Products"
                      itemBuilder: (context, index) {
                        final isAllProducts = index == 0;
                        final category =
                            isAllProducts ? null : _categories[index - 1];
                        final isSelected =
                            (_selectedCategory == null && isAllProducts) ||
                            (_selectedCategory?.id == category?.id &&
                                !isAllProducts);

                        return InkWell(
                          onTap: () => _onCategorySelected(category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 8.0,
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.teal.shade100
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.teal.shade300
                                        : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              isAllProducts ? 'All Products' : category!.name,
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? Colors.teal.shade800
                                        : Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Right Side: Products Grid
                  Expanded(
                    child: FutureBuilder<List<Product>>(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Error loading products: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              _selectedCategory != null
                                  ? 'No products found in this category.'
                                  : 'No products available.',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          );
                        } else {
                          return GridView.builder(
                            padding: const EdgeInsets.all(12.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 columns
                                  crossAxisSpacing: 12.0,
                                  mainAxisSpacing: 12.0,
                                  childAspectRatio:
                                      0.7, // Adjust as needed for content
                                ),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final product = snapshot.data![index];
                              return ProductGridItem(
                                product: product,
                                user: widget.user,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        user: widget.user,
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}

// Reusing the ProductCard concept for grid items
class ProductGridItem extends StatelessWidget {
  final Product product;
  final Auth user;

  const ProductGridItem({super.key, required this.product, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ProductDetailScreen(product: product, user: user),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  product.imageUrl ??
                      'https://placehold.co/600x600/E0E0E0/000000?text=No+Image',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 14,
                        color:
                            product.stockQuantity > 0
                                ? Colors.green
                                : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.stockQuantity > 0 ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              product.stockQuantity > 0
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
