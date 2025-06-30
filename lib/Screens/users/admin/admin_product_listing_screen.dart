import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/Screens/Auth/login_screen.dart';
import 'package:frontend/Screens/users/admin/admin_edit_product_screen.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/service/product_service.dart';

class AdminProductListingScreen extends StatefulWidget {
  final Auth user; // Pass the logged-in admin user
  final Category? selectedCategory; // Optional category to filter by

  const AdminProductListingScreen({super.key, required this.user, this.selectedCategory});

  @override
  State<AdminProductListingScreen> createState() => _AdminProductListingScreenState();
}

class _AdminProductListingScreenState extends State<AdminProductListingScreen> {
  late Future<List<Product>> _productsFuture;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Function to fetch products from the API, now with optional categoryId
  void _fetchProducts() {
    setState(() {
      _productsFuture = _productService.fetchProducts(
        categoryId: widget.selectedCategory?.id, // Pass category ID if available
      );
    });
  }

  // Function to handle product deletion (Admin Only)
  Future<void> _deleteProduct(int productId) async {
    // Basic admin check (should also be handled by backend)
    if (!widget.user.isAdmin) {
      _showSnackBar('You do not have permission to delete products.', Colors.red);
      return;
    }

    // Confirmation dialog
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        _showSnackBar('Deleting product...', Colors.orange);
        await _productService.deleteProduct(productId);
        _showSnackBar('Product deleted successfully!', Colors.green);
        _fetchProducts(); // Refresh the list
      } catch (e) {
        _showSnackBar('Failed to delete product: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
      }
    }
  }

  // Function to navigate to a product creation/edit form (Admin Only)
  void _navigateToAddEditProduct({Product? product}) async {
    // Basic admin check
    if (!widget.user.isAdmin) {
      _showSnackBar('You do not have permission to manage products.', Colors.red);
      return;
    }

    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen( // Use the extracted AddEditProductScreen
          user: widget.user,
          product: product, // Pass product if editing
        ),
      ),
    );

    if (result == true) {
      _fetchProducts(); // Refresh list if product was added/edited
    }
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

  Future<void> _logout(BuildContext context) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'user_id');
    await secureStorage.delete(key: 'user_name');
    await secureStorage.delete(key: 'user_email');
    await secureStorage.delete(key: 'is_admin');

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedCategory != null
            ? 'Admin Products in ${widget.selectedCategory!.name}'
            : 'Admin All Products'),
        backgroundColor: Colors.deepOrange, // Admin color
        foregroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          // Add Product button
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Product',
            onPressed: () => _navigateToAddEditProduct(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Products',
            onPressed: _fetchProducts,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}\nTap refresh to retry.', style: const TextStyle(color: Colors.red)),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(widget.selectedCategory != null ? 'No products found in this category.' : 'No products found.'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () {
                      _showSnackBar('Tapped on product: ${product.name}', Colors.lightBlue);
                      // TODO: Navigate to Product Detail Screen
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  product.imageUrl ?? 'https://placehold.co/100x100/E0E0E0/000000?text=No+Image',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Stock: ${product.stockQuantity}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: product.stockQuantity > 0 ? Colors.grey[700] : Colors.red,
                                        fontWeight: product.stockQuantity > 0 ? FontWeight.normal : FontWeight.bold,
                                      ),
                                    ),
                                    if (product.description != null && product.description!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          product.description!,
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Admin-only actions
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _navigateToAddEditProduct(product: product),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _deleteProduct(product.id),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
