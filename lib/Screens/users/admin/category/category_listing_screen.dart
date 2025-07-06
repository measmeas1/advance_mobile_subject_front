// lib/screens/category_listing_screen.dart
// This screen displays categories for both customers and administrators.
// Admin features (add, edit, delete) are conditionally displayed.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/Screens/Auth/login_screen.dart';
import 'package:frontend/Screens/users/admin/category/add_edit_category_screen.dart';
import 'package:frontend/Screens/users/admin/product/admin_product_listing_screen.dart';
import 'package:frontend/Screens/users/customers/homepage_screen.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/service/category_service.dart'; // For logout

class CategoryListingScreen extends StatefulWidget {
  final Auth user; // Pass the logged-in user to check admin status

  const CategoryListingScreen({super.key, required this.user});

  @override
  State<CategoryListingScreen> createState() => _CategoryListingScreenState();
}

class _CategoryListingScreenState extends State<CategoryListingScreen> {
  late Future<List<Category>> _categoriesFuture;

  final CategoryService _categoryService = CategoryService();
  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Function to fetch categories from the API
  void _fetchCategories() {
    setState(() {
      _categoriesFuture = _categoryService.fetchCategories();
    });
  }

  // Function to navigate to a category creation/edit form (Admin Only)
  void _navigateToAddEditCategory({Category? category}) async {
    if (!widget.user.isAdmin) {
      _showSnackBar('You do not have permission to manage categories.', Colors.red);
      return;
    }

    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCategoryScreen(
          user: widget.user,
          category: category, // Pass category if editing
        ),
      ),
    );

    if (result == true) {
      _fetchCategories(); // Refresh list if category was added/edited
    }
  }

  // Function to handle category deletion (Admin Only)
  Future<void> _deleteCategory(int categoryId) async {
    if (!widget.user.isAdmin) {
      _showSnackBar('You do not have permission to delete categories.', Colors.red);
      return;
    }

    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this category? This cannot be undone.'),
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
        _showSnackBar('Deleting category...', Colors.orange);
        await _categoryService.deleteCategory(categoryId);
        _showSnackBar('Category deleted successfully!', Colors.green);
        _fetchCategories(); // Refresh the list
      } catch (e) {
        _showSnackBar('Failed to delete category: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
      }
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
        title: const Text('Categories'),
        backgroundColor: widget.user.isAdmin ? Colors.deepOrange : Colors.teal, // Dynamic color
        foregroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          // Add Category button (Admin Only)
          if (widget.user.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add New Category',
              onPressed: () => _navigateToAddEditCategory(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Categories',
            onPressed: _fetchCategories,
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      // Conditional Bottom Navigation Bar: Only for customers
      bottomNavigationBar: !widget.user.isAdmin ? BottomNavigationBar(
        currentIndex: 1, // Categories tab
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) { // Products
            Navigator.pushReplacement( // Use pushReplacement to avoid stacking
              context,
              MaterialPageRoute(builder: (context) => HomepageScreen(user: widget.user)),
            );
          } else if (index == 1) { // Categories (current screen)
            _fetchCategories(); // Refresh categories if already on this tab
          } else if (index == 2) { // My Orders
            // Navigator.pushReplacement( // Use pushReplacement to avoid stacking
            //   context,
            //   MaterialPageRoute(builder: (context) => OrderHistoryScreen(user: widget.user)),
            // );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'My Orders',
          ),
        ],
      ) : null, // If user is admin, don't show BottomNavigationBar
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
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
            return const Center(child: Text('No categories found.'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final category = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: Icon(Icons.folder, color: Colors.blueAccent.shade700),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: category.description != null && category.description!.isNotEmpty
                        ? Text(category.description!)
                        : null,
                    trailing: widget.user.isAdmin // Admin-only actions
                        ? Row( // Use Row to contain multiple trailing widgets
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _navigateToAddEditCategory(category: category),
                                tooltip: 'Edit Category',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCategory(category.id),
                                tooltip: 'Delete Category',
                              ),
                            ],
                          )
                        : null,
                    onTap: () {
                      _showSnackBar('Showing products for category: ${category.name}', Colors.blue);
                      // Navigate to appropriate product listing based on role
                      if (widget.user.isAdmin) {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminProductListingScreen(
                              user: widget.user,
                              selectedCategory: category,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomepageScreen( // Customer uses HomePage for filtered products
                              user: widget.user,
                              selectedCategory: category,
                            ),
                          ),
                        );
                      }
                    },
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
