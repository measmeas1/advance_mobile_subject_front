// lib/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/Screens/Auth/login_screen.dart';
import 'package:frontend/Screens/users/admin/admin_edit_product_screen.dart';
import 'package:frontend/Screens/users/admin/admin_product_listing_screen.dart';
import 'package:frontend/models/auth_model.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Auth user;

  const AdminDashboardScreen({super.key, required this.user});

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
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepOrange, // Admin specific color
        foregroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.only(bottom: 24),
              color: Colors.deepOrange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.security, size: 50, color: Colors.deepOrange),
                    const SizedBox(height: 10),
                    Text(
                      'Welcome, ${user.name}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'You are logged in as an Administrator.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.deepOrange.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 40, thickness: 2, color: Colors.grey),
            
            Text(
              'Product Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildAdminButton(
              context,
              icon: Icons.add_shopping_cart,
              label: 'Add New Product',
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEditProductScreen(user: user)),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildAdminButton(
              context,
              icon: Icons.category,
              label: 'View/Manage Products',
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminProductListingScreen(user: user)),
                );
              },
            ),
            const SizedBox(height: 40),

            Text(
              'Category Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildAdminButton(
              context,
              icon: Icons.create_new_folder,
              label: 'Add New Category',
              color: Colors.green,
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => AddEditCategoryScreen(user: user)),
                // );
              },
            ),
            const SizedBox(height: 15),
            _buildAdminButton(
              context,
              icon: Icons.list_alt,
              label: 'View/Manage Categories',
              color: Colors.blue,
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => CategoryListingScreen(user: user)),
                // );
              },
            ),
            const SizedBox(height: 40),

            Text(
              'Order Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildAdminButton(
              context,
              icon: Icons.receipt,
              label: 'View All Orders',
              color: Colors.purple,
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => OrderHistoryScreen(user: user)), // Admin sees all orders
                // );
              },
            ),
             const SizedBox(height: 40),
            _buildAdminButton(
              context,
              icon: Icons.analytics,
              label: 'Analytics (Placeholder)',
              color: Colors.grey,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
    );
  }
}
