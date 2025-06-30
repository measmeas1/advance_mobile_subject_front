import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/orderitem.dart';

class Order {
  final int id;
  final int userId;
  final String orderNumber;
  final double totalAmount;
  final String shippingAddress;
  final String orderStatus;
  final String createdAt; // Can be parsed to DateTime if needed
  final Auth? user; // Optional: User who placed the order (for admin view)
  final List<OrderItem> items; // List of items in this order

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.totalAmount,
    required this.shippingAddress,
    required this.orderStatus,
    required this.createdAt,
    this.user,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<OrderItem> orderItems = itemsList.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      id: json['id'],
      userId: json['user_id'],
      orderNumber: json['order_number'],
      totalAmount: json['total_amount'].toDouble(),
      shippingAddress: json['shipping_address'],
      orderStatus: json['order_status'],
      createdAt: json['created_at'],
      user: json['user'] != null ? Auth.fromJson(json['user']) : null,
      items: orderItems,
    );
  }
}