// lib/Screens/users/admins/admin_order_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/Screens/Auth/login_screen.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/service/order_service.dart';

class OrderListScreen extends StatefulWidget {
  // Renamed from OrderListScreen
  final Auth user; // Admin user details

  const OrderListScreen({super.key, required this.user});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState(); // Renamed state class
}

class _OrderListScreenState extends State<OrderListScreen> {
  // Renamed state class
  late Future<List<Order>> _ordersFuture;
  final OrderService _orderService = OrderService();

  // Define possible order statuses for dropdown
  final List<String> _orderStatuses = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Ensures RefreshIndicator works correctly by returning Future<void>
  Future<void> _fetchOrders() async {
    setState(() {
      _ordersFuture =
          _orderService
              .fetchOrders(); // Service will fetch all orders for admin token
    });
    await _ordersFuture; // Await the completion of the future
  }

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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.lightBlue;
      case 'delivered':
        return Colors.green; // Keeping original green for delivered
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Function to show status update dialog for admin
  Future<void> _showUpdateStatusDialog(Order order) async {
    String? selectedStatus = order.orderStatus; // Pre-select current status

    // Ensure the dialog's context is correctly managed
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use dialogContext to avoid issues
        return StatefulBuilder(
          // Use StatefulBuilder to update dropdown in dialog
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('Update Status for Order #${order.orderNumber}'),
              content: DropdownButtonFormField<String>(
                value: _orderStatuses.contains(selectedStatus) ? selectedStatus : null,
                decoration: const InputDecoration(
                  labelText: 'Order Status',
                  border: OutlineInputBorder(),
                ),
                items:
                    _orderStatuses.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setDialogState(() {
                    // Update state of the dialog
                    selectedStatus = newValue;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () {
                    if (selectedStatus != null &&
                        selectedStatus != order.orderStatus) {
                      Navigator.of(
                        dialogContext,
                      ).pop(selectedStatus); // Pop with selected status
                    } else {
                      Navigator.of(
                        dialogContext,
                      ).pop(); // Pop without updating if no change
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      try {
        _showSnackBar('Updating status to $result...', Colors.blueAccent);
        await _orderService.updateOrderStatus(order.id, result);
        _showSnackBar('Order status updated to $result!', Colors.green);
        _fetchOrders(); // Refresh the list to show updated status
      } catch (e) {
        _showSnackBar(
          'Failed to update status: ${e.toString().replaceFirst('Exception: ', '')}',
          Colors.red,
        );
      }
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
      _showSnackBar(
        'Logged out successfully!',
        Colors.green,
      ); // Using the consistent snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders (Admin)'),
        backgroundColor: Colors.deepOrange, // Admin-specific color
        foregroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
            onPressed: _fetchOrders,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading orders: ${snapshot.error.toString().replaceFirst('Exception: ', '')}\nPull to refresh.',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No orders found in the system.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            final orders = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _fetchOrders,
              backgroundColor: Colors.white,
              color: Colors.deepOrange,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(
                          order.orderStatus,
                        ).withOpacity(0.1),
                        child: Text(
                          order.orderStatus[0].toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(order.orderStatus),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                          ),
                          Text(
                            'Status: ${order.orderStatus}',
                            style: TextStyle(
                              color: _getStatusColor(order.orderStatus),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Placed On: ${order.createdAt.substring(0, 10)}',
                          ),
                          // Show customer name for admin
                          if (order.user != null)
                            Text(
                              'Customer: ${order.user!.name}',
                              style: const TextStyle(color: Colors.deepPurple),
                            ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shipping Address: ${order.shippingAddress}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (order.phoneNumber != null &&
                                  order.phoneNumber!.isNotEmpty)
                                Text(
                                  'Phone: ${order.phoneNumber}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              const SizedBox(height: 10),
                              const Text(
                                'Items:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: order.items.length,
                                itemBuilder: (context, itemIndex) {
                                  final item = order.items[itemIndex];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4.0,
                                          ),
                                          child: Image.network(
                                            item.product?.imageUrl ??
                                                'https://placehold.co/50x50/E0E0E0/000000?text=No+Img',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 20,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.product?.name ??
                                                    'Unknown Product',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Qty: ${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => _showUpdateStatusDialog(order),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Update Status'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
