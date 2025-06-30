import 'package:flutter/material.dart';
import 'package:frontend/models/auth_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  final Auth user;

  const OrderHistoryScreen({super.key, required this.user});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // Uncomment and implement these once you build fetchOrders in AuthService
  // late Future<List<Order>> _ordersFuture;
  // final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // _fetchOrders(); // Call this when you implement order fetching
  }

  // Example placeholder for fetching orders
  // void _fetchOrders() {
  //   setState(() {
  //     _ordersFuture = _authService.fetchOrders();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title changes based on user role
        title: Text(widget.user.isAdmin ? 'All Orders (Admin)' : 'My Orders'),
        backgroundColor: widget.user.isAdmin ? Colors.deepOrange : Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
            onPressed: () {
              // _fetchOrders(); // Call actual fetch when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Orders refresh triggered (backend needed)!')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.user.isAdmin ? Icons.assignment : Icons.receipt_long,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              widget.user.isAdmin
                  ? 'This screen will display all orders.'
                  : 'This screen will display your personal order history.',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Example of how you would display orders (when data is fetched)
            // FutureBuilder<List<Order>>(
            //   future: _ordersFuture,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return CircularProgressIndicator();
            //     } else if (snapshot.hasError) {
            //       return Text('Error: ${snapshot.error}');
            //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //       return Text('No orders found.');
            //     } else {
            //       return Expanded(
            //         child: ListView.builder(
            //           itemCount: snapshot.data!.length,
            //           itemBuilder: (context, index) {
            //             final order = snapshot.data![index];
            //             return Card(
            //               margin: EdgeInsets.all(8),
            //               child: ListTile(
            //                 title: Text('Order #${order.orderNumber}'),
            //                 subtitle: Text('Total: \$${order.totalAmount.toStringAsFixed(2)}\nStatus: ${order.orderStatus}'),
            //                 trailing: Icon(Icons.arrow_forward_ios),
            //                 onTap: () {
            //                   // Navigate to order detail screen
            //                 },
            //               ),
            //             );
            //           },
            //         ),
            //       );
            //     }
            //   },
            // ),
            ElevatedButton(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backend API for orders is ready, connect frontend!')),
                );
              },
              child: const Text('Fetch Orders (Placeholder)'),
            )
          ],
        ),
      ),
    );
  }
}

