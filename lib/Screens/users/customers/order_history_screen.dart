import 'package:flutter/material.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/service/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  final Auth user;

  const OrderHistoryScreen({super.key, required this.user});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Order>> _ordersFuture;
  final OrderService _orderService = OrderService();

  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _lightGreenBackground = Color(0xFFE8F5E9);
  static const Color _darkGreenAccent = Color(0xFF2E7D32);
  static const Color _textColor = Color(0xFF333333);
  static const Color _lightTextColor = Color(0xFF757575);
  static const Color _errorColor = Color(0xFFD32F2F);
  static const Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _ordersFuture = _orderService.fetchOrders();
    });
    await _ordersFuture;
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
        return _primaryGreen;
      case 'cancelled':
        return _errorColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreenBackground,
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 6,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Orders',
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen)));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: _errorColor),
                    const SizedBox(height: 20),
                    Text(
                      'Oops! Something went wrong.',
                      style: TextStyle(fontSize: 20, color: _textColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Failed to load your orders: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                      style: TextStyle(color: _lightTextColor, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchOrders,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 25),
                  Text(
                    'You haven\'t placed any orders yet.',
                    style: TextStyle(fontSize: 22, color: _lightTextColor, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start shopping to see your order history here!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Go to Account'),
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
            );
          } else {
            final orders = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _fetchOrders,
              backgroundColor: _cardColor,
              color: _primaryGreen,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: _cardColor,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.all(16.0),
                      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: _getStatusColor(order.orderStatus).withOpacity(0.15),
                        child: Text(
                          order.orderStatus[0].toUpperCase(),
                          style: TextStyle(color: _getStatusColor(order.orderStatus), fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      title: Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: _textColor),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 15, color: _darkGreenAccent, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Status: ${order.orderStatus}',
                            style: TextStyle(color: _getStatusColor(order.orderStatus), fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Placed On: ${order.createdAt.substring(0, 10)}',
                            style: TextStyle(color: _lightTextColor, fontSize: 13),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: Colors.grey[300]),
                              Text('Shipping Address: ${order.shippingAddress}', style: const TextStyle(fontSize: 14, color: _textColor)),
                              if (order.phoneNumber != null && order.phoneNumber!.isNotEmpty)
                                Text('Phone: ${order.phoneNumber}', style: const TextStyle(fontSize: 14, color: _textColor)),
                              const SizedBox(height: 15),
                              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: order.items.length,
                                itemBuilder: (context, itemIndex) {
                                  final item = order.items[itemIndex];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.grey[200],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.network(
                                              item.product?.imageUrl ?? 'https://placehold.co/50x50/E0E0E0/000000?text=No+Img',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.broken_image, size: 25, color: Colors.grey),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.product?.name ?? 'Unknown Product',
                                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: _textColor),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Qty: ${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(color: _lightTextColor, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: _darkGreenAccent),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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