// lib/Screens/users/customers/account_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/Screens/users/customers/order_history_screen.dart';
import 'package:frontend/Screens/users/customers/favorite_screen.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/Screens/Auth/login_screen.dart';
import 'package:frontend/Screens/users/components/bottom_nav.dart';
import 'package:frontend/Screens/users/customers/edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  final Auth user;
  final int initialTabIndex;

  const AccountScreen({
    super.key,
    required this.user,
    this.initialTabIndex = 3,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Auth _currentUser;
  int _currentBottomNavIndex = 3;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Define your refined color palette consistent with other screens
  static const Color _primaryGreen = Color(0xFF4CAF50); // A vibrant, appealing green
  static const Color _lightGreenBackground = Color(0xFFE8F5E9); // Your chosen light green base
  static const Color _textColor = Color(0xFF333333); // Dark grey for general text
  static const Color _lightTextColor = Color(0xFF757575); // Lighter grey for secondary text
  static const Color _errorColor = Color(0xFFD32F2F); // Standard red for errors/removals/logout
  static const Color _successColor = Color(0xFF388E3C); // Standard green for success
  static const Color _cardColor = Colors.white; // White for cards

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _currentBottomNavIndex = widget.initialTabIndex;
  }

  // Function to re-fetch user data from secure storage after an update
  Future<void> _refreshUserData() async {
    final int? id = int.tryParse(await _secureStorage.read(key: 'user_id') ?? '');
    final String? name = await _secureStorage.read(key: 'user_name');
    final String? email = await _secureStorage.read(key: 'user_email');
    final bool isAdmin = (await _secureStorage.read(key: 'is_admin') ?? 'false') == 'true';
    final String? profileImageUrl = await _secureStorage.read(key: 'profile_image_url');

    if (id != null && name != null && email != null) {
      setState(() {
        _currentUser = Auth(
          id: id,
          name: name,
          email: email,
          isAdmin: isAdmin,
          profileImageUrl: profileImageUrl,
        );
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Consistent border radius
          margin: const EdgeInsets.all(16), // Consistent margin
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: _lightTextColor)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: _primaryGreen)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: _errorColor, foregroundColor: Colors.white),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_id');
      await _secureStorage.delete(key: 'user_name');
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'is_admin');
      await _secureStorage.delete(key: 'profile_image_url');

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        _showSnackBar('Logged out successfully!', _successColor);
      }
    }
  }

  // Handles bottom navigation bar taps (mostly for visual highlight, actual navigation is in BottomNav)
  void _onBottomNavTapped(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });
  }

  Widget _buildAccountOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0), // Adjust margin for padding in column
      elevation: 4, // Subtle elevation for modern look
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded corners
      color: _cardColor, // White card background
      child: InkWell( // Add InkWell for visual feedback on tap
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Internal padding
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 28), // Larger icon
              const SizedBox(width: 20), // More spacing
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 17, color: _textColor, fontWeight: FontWeight.w500), // Updated text style
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: _lightTextColor, size: 20), // Consistent arrow icon
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreenBackground, // Consistent background color
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _primaryGreen, // Consistent app bar color
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false, // Keep false if it's a bottom nav tab
        elevation: 6, // Subtle elevation for a modern look
        // Removed the 'shape' property for a rectangular app bar
      ),
      body: SingleChildScrollView( // Changed Padding to SingleChildScrollView for overflow safety
        padding: const EdgeInsets.all(20.0), // Increased overall padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center contents horizontally
          children: [
            // Profile Picture Section
            Stack(
              children: [
                CircleAvatar(
                  radius: 70, // Slightly larger avatar
                  backgroundColor: _primaryGreen.withOpacity(0.2), // Lighter green for background
                  backgroundImage: _currentUser.profileImageUrl != null && _currentUser.profileImageUrl!.isNotEmpty
                      ? NetworkImage(_currentUser.profileImageUrl!) as ImageProvider<Object>?
                      : null,
                  child: _currentUser.profileImageUrl == null || _currentUser.profileImageUrl!.isEmpty
                      ? const Icon(Icons.person, size: 90, color: _primaryGreen) // Larger, green icon
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      final Auth? updatedUser = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(currentUser: _currentUser),
                        ),
                      );
                      if (updatedUser != null) {
                        _refreshUserData(); // Re-fetch from secure storage to ensure consistency
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: _primaryGreen, // Edit button background color
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Spacing after avatar

            // User Name and Email
            Text(
              _currentUser.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _textColor, // Use _textColor
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _currentUser.email,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _lightTextColor, // Use _lightTextColor
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30), // More space before options

            // Account Options List
            _buildAccountOption(
              icon: Icons.receipt_long,
              iconColor: Colors.deepPurpleAccent, // Unique color for orders
              title: 'My Orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderHistoryScreen(user: _currentUser)),
                );
              },
            ),
            _buildAccountOption(
              icon: Icons.favorite_rounded, // Filled favorite icon
              iconColor: _errorColor, // Consistent red for favorites
              title: 'Favorite Products',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (contxt) => FavoriteScreen(user: _currentUser)));
              },
            ),
            _buildAccountOption(
              icon: Icons.lock_outline_rounded, // Outlined lock icon
              iconColor: Colors.orange, // Consistent orange
              title: 'Change Password',
              onTap: () {
                _showSnackBar('Change Password feature coming soon!', Colors.orange);
              },
            ),
            _buildAccountOption(
              icon: Icons.logout_rounded, // Rounded logout icon
              iconColor: _errorColor, // Red for logout
              title: 'Log Out',
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 20), // Padding at the bottom
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        user: _currentUser, // Pass the mutable _currentUser
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}