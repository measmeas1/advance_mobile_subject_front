// import 'package:flutter/material.dart';
// import 'package:frontend/models/auth_model.dart';
// import 'package:frontend/service/auth_service.dart';

// class CartScreen extends StatefulWidget {
//   final Auth user; // Pass the current user

//   const CartScreen({super.key, required this.user});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   late Future<List<CartItem>> _cartItemsFuture;
//   final AuthService _authService = AuthService();
//   double _cartTotal = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCart();
//   }

//   void _fetchCart() {
//     setState(() {
//       _cartItemsFuture = _authService.fetchCartItems();
//     });
//     // Calculate total after fetching, or get it from API response directly if available
//     _cartItemsFuture.then((items) {
//       setState(() {
//         _cartTotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
//       });
//     }).catchError((error) {
//       _showSnackBar('Failed to load cart: ${error.toString().replaceFirst('Exception: ', '')}', Colors.red);
//       _cartTotal = 0.0;
//     });
//   }

//   Future<void> _updateCartItemQuantity(CartItem item, int newQuantity) async {
//     if (newQuantity < 0) return; // Prevent negative quantity

//     setState(() {
//       item.quantity = newQuantity; // Optimistic update
//       _cartTotal = _cartTotal + (newQuantity - item.quantity) * item.productPrice;
//     });

//     try {
//       if (newQuantity == 0) {
//         await _authService.removeCartItem(item.id);
//         _showSnackBar('Item removed from cart.', Colors.orange);
//       } else {
//         await _authService.updateCartItem(item.id, newQuantity);
//         _showSnackBar('Quantity updated.', Colors.green);
//       }
//       _fetchCart(); // Re-fetch to ensure consistency and recalculate total
//     } catch (e) {
//       _showSnackBar('Failed to update cart: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
//       _fetchCart(); // Revert to actual state if update fails
//     }
//   }

//   Future<void> _removeCartItem(int cartItemId) async {
//     final bool? confirmDelete = await showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Remove Item'),
//         content: const Text('Are you sure you want to remove this item from your cart?'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(ctx).pop(true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Remove'),
//           ),
//         ],
//       ),
//     );

//     if (confirmDelete == true) {
//       try {
//         _showSnackBar('Removing item...', Colors.orange);
//         await _authService.removeCartItem(cartItemId);
//         _showSnackBar('Item removed successfully!', Colors.green);
//         _fetchCart(); // Refresh the cart list
//       } catch (e) {
//         _showSnackBar('Failed to remove item: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
//       }
//     }
//   }

//   void _showSnackBar(String message, Color color) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: color,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Cart'),
//         backgroundColor: Colors.blueAccent,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(20),
//           ),
//         ),
//       ),
//       body: FutureBuilder<List<CartItem>>(
//         future: _cartItemsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text('Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}\nTap refresh to retry.', style: const TextStyle(color: Colors.red)),
//               ),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text('Your cart is empty!', style: TextStyle(fontSize: 20, color: Colors.grey)),
//                   SizedBox(height: 20),
//                   // Optional: Button to browse products
//                 ],
//               ),
//             );
//           } else {
//             return Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(8.0),
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       final item = snapshot.data![index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8.0),
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(8.0),
//                                 child: Image.network(
//                                   item.productImageUrl ?? 'https://placehold.co/80x80/E0E0E0/000000?text=No+Image',
//                                   width: 80,
//                                   height: 80,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       width: 80,
//                                       height: 80,
//                                       color: Colors.grey[300],
//                                       child: const Icon(Icons.broken_image, color: Colors.grey),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       item.productName,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.blueAccent,
//                                       ),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       '\$${item.productPrice.toStringAsFixed(2)} per item',
//                                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Row(
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(Icons.remove_circle_outline),
//                                           onPressed: item.quantity > 1
//                                               ? () => _updateCartItemQuantity(item, item.quantity - 1)
//                                               : null, // Disable if quantity is 1
//                                         ),
//                                         Text(
//                                           item.quantity.toString(),
//                                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(Icons.add_circle_outline),
//                                           onPressed: () => _updateCartItemQuantity(item, item.quantity + 1),
//                                         ),
//                                         const Spacer(),
//                                         Text(
//                                           '\$${item.subtotal.toStringAsFixed(2)}',
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.green,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () => _removeCartItem(item.id),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 // Cart Total and Checkout Button
//                 Container(
//                   padding: const EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.blueAccent.shade50,
//                     borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, -3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Cart Total:',
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '\$${_cartTotal.toStringAsFixed(2)}',
//                             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton.icon(
//                         onPressed: _cartTotal > 0 ? () {
//                           _showSnackBar('Proceeding to Checkout!', Colors.blue);
//                           // TODO: Implement Checkout logic (navigate to checkout screen, create order)
//                         } : null, // Disable if cart is empty
//                         icon: const Icon(Icons.payment),
//                         label: const Text('Proceed to Checkout'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           foregroundColor: Colors.white,
//                           minimumSize: const Size.fromHeight(50), // Make button wider
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
// }
