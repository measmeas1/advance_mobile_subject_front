// lib/screens/users/customers/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/Screens/users/components/bottom_nav.dart';
import 'package:frontend/Screens/users/customers/homepage_screen.dart';
import 'package:frontend/models/auth_model.dart'; // Import Auth model
import 'package:frontend/models/cart_model.dart'; // Import CartItem model
import 'package:frontend/Screens/users/customers/checkout_screen.dart'; // Import CheckoutScreen
import 'package:frontend/service/cart_service.dart';

class CartScreen extends StatefulWidget {
  final Auth user;
  final int initialTabIndex;

  const CartScreen({
    super.key,
    required this.user,
    this.initialTabIndex = 2, // Cart is index 2 in your BottomNav
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  int _currentBottomNavIndex = 2; 

  static const Color _primaryGreen = Color(0xFF4CAF50); 
  static const Color _lightGreenBackground = Color(0xFFE8F5E9); 
  static const Color _darkGreenAccent = Color(0xFF2E7D32); 
  static const Color _textColor = Color(0xFF333333); 
  static const Color _lightTextColor = Color(0xFF757575); 
  static const Color _errorColor = Color(0xFFD32F2F); 
  static const Color _successColor = Color(0xFF388E3C); 

  @override
  void initState() {
    super.initState();
    _currentBottomNavIndex = widget.initialTabIndex;
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final items = await _cartService.getCartItems();
      setState(() {
        _cartItems = items;
      });
    } catch (e) {
      _showSnackBar(
          'Failed to load cart items: ${e.toString().replaceFirst('Exception: ', '')}',
          _errorColor);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(CartItem item, int change) async {
    int newQuantity = item.quantity + change;
    if (newQuantity < 0) newQuantity = 0; // Prevent negative quantity

    // Optimistic update
    setState(() {
      if (newQuantity == 0) {
        _cartItems.removeWhere((cartItem) => cartItem.productId == item.productId);
      } else {
        // Directly modify the quantity as your model allows
        item.quantity = newQuantity;
      }
    });

    try {
      if (newQuantity == 0) {
        await _cartService.removeCartItem(item.productId);
        _showSnackBar('${item.productName} removed from cart.', _successColor);
      } else {
        await _cartService.updateCartItemQuantity(item.productId, newQuantity);
      }
      _fetchCartItems(); // Re-fetch to ensure consistency with storage after backend call
    } catch (e) {
      _showSnackBar(
          'Failed to update quantity: ${e.toString().replaceFirst('Exception: ', '')}',
          _errorColor);
      _fetchCartItems(); // Revert UI on error
    }
  }

  Future<void> _removeItem(CartItem item) async {
    // Optimistic update
    setState(() {
      _cartItems.removeWhere((cartItem) => cartItem.productId == item.productId);
    });
    try {
      await _cartService.removeCartItem(item.productId);
      _showSnackBar('${item.productName} removed from cart.', _successColor);
    } catch (e) {
      _showSnackBar(
          'Failed to remove item: ${e.toString().replaceFirst('Exception: ', '')}',
          _errorColor);
      _fetchCartItems(); // Revert UI on error
    }
  }

  Future<void> _clearCart() async {
    final bool? confirmClear = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to clear your entire cart?',
            style: TextStyle(color: _lightTextColor)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: _primaryGreen)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: _errorColor, foregroundColor: Colors.white),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmClear == true) {
      // Optimistic update
      setState(() {
        _cartItems.clear();
      });
      try {
        await _cartService.clearCart();
        _showSnackBar('Cart cleared successfully!', _successColor);
      } catch (e) {
        _showSnackBar(
            'Failed to clear cart: ${e.toString().replaceFirst('Exception: ', '')}',
            _errorColor);
        _fetchCartItems(); // Revert UI on error
      }
    }
  }

  double get _cartTotal {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.quantity * item.price));
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16), // Margin from edges
        ),
      );
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });
    // Navigation is handled by the BottomNav widget itself via pushReplacement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreenBackground,
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Cart',
            onPressed: _fetchCartItems,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear Cart',
            onPressed: _cartItems.isEmpty ? null : _clearCart,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen)))
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 120, color: Colors.grey[400]), // Larger icon
                      const SizedBox(height: 25), // More spacing
                      Text(
                        'Your cart is empty!',
                        style: TextStyle(fontSize: 22, color: _lightTextColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Time to find some great products!',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to home or product screen, assuming index 0 is home
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomepageScreen(user: widget.user,)), // Adjust as per your BottomNav implementation
                          );
                        },
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Start Shopping'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0), // Consistent padding
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return _buildCartItemCard(item);
                        },
                      ),
                    ),
                    _buildCartSummary(),
                  ],
                ),
      bottomNavigationBar: BottomNav(
        user: widget.user,
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Vertical margin only
      elevation: 5, // A subtle lift
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded corners
      color: Colors.white, // Ensure card background is white
      child: Padding(
        padding: const EdgeInsets.all(15.0), // Padding inside the card
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200], // Light grey background for image area
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  item.imageUrl ?? 'https://placehold.co/80x80/E0E0E0/000000?text=No+Img',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 35, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Product Details and Quantity Controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: _textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Unit Price: \$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(color: _lightTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuantityControl(
                          icon: Icons.remove_circle_outline,
                          onPressed: () => _updateQuantity(item, -1),
                          isDecrement: true),
                      Text(
                        item.quantity.toString(),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _textColor),
                      ),
                      _buildQuantityControl(
                          icon: Icons.add_circle_outline,
                          onPressed: () => _updateQuantity(item, 1),
                          isDecrement: false),
                      // Spacer to push total to the right
                      const Spacer(),
                      Text(
                        'Total: \$${(item.quantity * item.price).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _darkGreenAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Remove Button
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: _errorColor, size: 28),
              onPressed: () => _removeItem(item),
              tooltip: 'Remove Item',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl({required IconData icon, required VoidCallback onPressed, required bool isDecrement}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          icon,
          color: isDecrement ? _errorColor : _primaryGreen,
          size: 26,
        ),
      ),
    );
  }


  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30), // More bottom padding for floating button effect
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, -8),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Smoother, larger top radius
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal:', // Changed to Subtotal for clarity before checkout
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: _textColor),
              ),
              Text(
                '\$${_cartTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: _primaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _cartItems.isEmpty ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutScreen(
                    user: widget.user,
                    cartItems: _cartItems,
                    cartTotal: _cartTotal,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outline, size: 24), // New icon for checkout
            label: const Text('Proceed to Checkout', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 8, // Subtle shadow for the button
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}