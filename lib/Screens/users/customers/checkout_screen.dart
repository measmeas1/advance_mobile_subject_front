// lib/Screens/users/customers/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:frontend/Screens/users/customers/order_history_screen.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/service/cart_service.dart';
import 'package:frontend/service/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  final Auth user;
  final List<CartItem> cartItems;
  final double cartTotal;

  const CheckoutScreen({
    super.key,
    required this.user,
    required this.cartItems,
    required this.cartTotal,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shippingAddressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();

  bool _isLoading = false;
  String? _backendError;

  // Define your refined color palette consistent with CartScreen
  static const Color _primaryGreen = Color(0xFF4CAF50); // A vibrant, appealing green
  static const Color _lightGreenBackground = Color(0xFFE8F5E9); // Your chosen light green base
  static const Color _darkGreenAccent = Color(0xFF2E7D32); // A deeper green for highlights
  static const Color _textColor = Color(0xFF333333); // Dark grey for general text
  static const Color _lightTextColor = Color(0xFF757575); // Lighter grey for secondary text
  static const Color _errorColor = Color(0xFFD32F2F); // Standard red for errors/removals
  static const Color _successColor = Color(0xFF388E3C); // Standard green for success
  static const Color _cardColor = Colors.white; // White for cards and summary
  static const Color _inputBorderColor = Colors.grey; // Default input border color

  @override
  void initState() {
    super.initState();
    // Pre-fill address and phone number if available from user model
    // Example: _shippingAddressController.text = widget.user.address ?? '';
    // Example: _phoneNumberController.text = widget.user.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _shippingAddressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _backendError = null;
      });

      try {
        final List<Map<String, dynamic>> orderItemsPayload = widget.cartItems.map((item) => {
              'product_id': item.productId,
              'quantity': item.quantity,
              'unit_price': item.price,
            }).toList();

        await _orderService.placeOrder(
          shippingAddress: _shippingAddressController.text,
          phoneNumber: _phoneNumberController.text,
          items: orderItemsPayload,
        );

        await _cartService.clearCart(); // Clear cart after successful order

        _showSnackBar('Order placed successfully!', _successColor);

        if (mounted) {
          // Navigate to Order History screen after successful order
          Navigator.pushReplacement( // Use pushReplacement to prevent going back to checkout
            context,
            MaterialPageRoute(builder: (context) => OrderHistoryScreen(user: widget.user)),
          );
        }
      } catch (e) {
        setState(() {
          _backendError = e.toString().replaceFirst('Exception: ', '');
          _showSnackBar('Order placement failed: $_backendError', _errorColor);
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreenBackground, 
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _primaryGreen, 
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0, 
        leading: IconButton( 
          icon: const Icon(Icons.arrow_back_ios_new_rounded), 
          onPressed: () => Navigator.of(context).pop(), 
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _textColor, 
                  ),
            ),
            const SizedBox(height: 15), 
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _cardColor, // White card background
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0), // More vertical padding for items
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // Align items centrally
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0), // Slightly larger image radius
                          child: Image.network(
                            item.imageUrl ?? 'https://placehold.co/60x60/E0E0E0/000000?text=No+Img', // Slightly larger image size
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 25, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 15), // More spacing
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600, // Slightly bolder
                                  fontSize: 17, // Larger font size
                                  color: _textColor,
                                ),
                                maxLines: 2, // Allow two lines for longer names
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                                style: TextStyle(color: _lightTextColor, fontSize: 14), // Lighter text color
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${(item.quantity * item.price).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _darkGreenAccent), // Emphasize total
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25), // Adjusted spacing
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Grand Total:', // Changed to Grand Total for clarity
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor),
                  ),
                  Text(
                    '\$${widget.cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primaryGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Adjusted spacing

            // Shipping Information Section
            Text(
              'Shipping Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
            ),
            const SizedBox(height: 15),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  TextFormField(
                    controller: _shippingAddressController,
                    decoration: InputDecoration(
                      labelText: 'Shipping Address',
                      hintText: 'Enter your full shipping address',
                      prefixIcon: const Icon(Icons.location_on, color: _primaryGreen), // Green icon
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded input field
                        borderSide: const BorderSide(color: _inputBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _inputBorderColor.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _primaryGreen, width: 2), // Green focus border
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your shipping address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20), // Spacing between fields
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'e.g., 012345678',
                      prefixIcon: const Icon(Icons.phone, color: _primaryGreen), // Green icon
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded input field
                        borderSide: const BorderSide(color: _inputBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _inputBorderColor.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _primaryGreen, width: 2), // Green focus border
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 7 || value.length > 15) {
                        return 'Phone number must be between 7 and 15 digits';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Payment Method Section
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 4, // Slightly more elevation for payment card
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded corners
              color: _cardColor,
              child: ListTile(
                leading: const Icon(Icons.money, color: _darkGreenAccent, size: 30), // Updated icon
                title: const Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _textColor)),
                subtitle: const Text('Payment upon delivery', style: TextStyle(color: _lightTextColor)),
                trailing: const Icon(Icons.check_circle, color: _successColor, size: 28), // Larger, prominent check
              ),
            ),
            const SizedBox(height: 30),

            if (_backendError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0), // Increased bottom padding
                child: Text(
                  _backendError!,
                  style: const TextStyle(color: _errorColor, fontSize: 15, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),

            // Place Order Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _placeOrder,
              icon: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.payment_rounded, size: 26), // Updated icon
              label: Text(_isLoading ? 'Placing Order...' : 'Confirm Order'), // Changed text for final action
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55), // Taller button
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded corners
                elevation: 8, // Subtle shadow for the button
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold), // Larger, bolder text
              ),
            ),
          ],
        ),
      ),
    );
  }
}