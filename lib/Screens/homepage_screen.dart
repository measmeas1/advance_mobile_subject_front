import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/Screens/Auth/login_screen.dart';
import 'package:frontend/models/auth_model.dart';

class HomePage extends StatelessWidget {
  final Auth user; // The logged-in user object

  const HomePage({super.key, required this.user});

  // Function to handle logout
  Future<void> _logout(BuildContext context) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'auth_token'); // Clear the token
    await secureStorage.delete(key: 'user_id');
    await secureStorage.delete(key: 'user_name');
    await secureStorage.delete(key: 'user_email');
    await secureStorage.delete(key: 'is_admin');

    // Navigate back to the login screen and remove all previous routes
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Assuming LoginScreen is your initial route
        (route) => false, // Remove all routes from the stack
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
        title: const Text('Home Page'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context), // Call the logout function
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Display welcome message
              Text(
                'Welcome, ${user.name}!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Display user email
              Text(
                'Email: ${user.email}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Display admin status
              Text(
                'Account Type: ${user.isAdmin ? 'Administrator' : 'Customer'}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: user.isAdmin ? Colors.deepOrange : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- Conditional UI based on user.isAdmin ---
              if (user.isAdmin) // If the user is an admin
                Column(
                  children: [
                    const Text(
                      'Admin Dashboard Access',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to a dedicated admin panel screen
                        print('Navigating to Admin Product Management Screen...');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Admin Product Management functionality goes here!')),
                        );
                        // Example Navigation:
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProductManagementScreen()));
                      },
                      icon: const Icon(Icons.category),
                      label: const Text('Manage Products'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo, // Admin-specific color
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        print('Navigating to Admin Order Management Screen...');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Admin Order Management functionality goes here!')),
                        );
                      },
                      icon: const Icon(Icons.receipt),
                      label: const Text('View All Orders'),
                       style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                  ],
                )
              else // If the user is a regular customer
                Column(
                  children: [
                    const Text(
                      'Customer Features',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to the main product browsing screen
                        print('Navigating to Customer Product Listing...');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product catalog for customers goes here!')),
                        );
                        // Example Navigation:
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListingScreen()));
                      },
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Browse Products'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Customer-specific color
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        print('Navigating to My Orders Screen...');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Your personal order history goes here!')),
                        );
                        // Example Navigation:
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => const UserOrdersScreen()));
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('My Orders'),
                       style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
