import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color.fromARGB(255, 140, 235, 145),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          // User Profile Header
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=3'), // example avatar
              ),
              title: const Text(
                "John Doe",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("john.doe@example.com"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to profile edit page
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Order History Section
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              leading: const Icon(Icons.history, color: Colors.green),
              title: const Text(
                "Order History",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: const [
                ListTile(
                  leading: Icon(Icons.shopping_bag),
                  title: Text("Order #12345"),
                  subtitle: Text("Delivered on June 10, 2025"),
                ),
                ListTile(
                  leading: Icon(Icons.shopping_bag),
                  title: Text("Order #12346"),
                  subtitle: Text("Processing"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Favorites Section
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              leading: const Icon(Icons.favorite, color: Colors.redAccent),
              title: const Text(
                "Favorites ❤️",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: const [
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text("Red Sneakers"),
                ),
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text("Blue Jacket"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Settings Section
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.blueGrey),
              title: const Text(
                "Settings",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to settings page
              },
            ),
          ),

          const SizedBox(height: 16),

          // Logout Button
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Logout",
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.redAccent),
              ),
              onTap: () {
                // Handle logout action
              },
            ),
          ),
        ],
      ),
    );
  }
}
