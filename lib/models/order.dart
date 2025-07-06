// lib/models/order.dart

import 'package:frontend/models/auth_model.dart'; // Assuming Auth is your User model
import 'package:frontend/models/orderitem.dart';

class Order {
  final int id;
  final int userId;
  final String orderNumber;
  final double totalAmount;
  final String shippingAddress;
  final String? phoneNumber; 
  final String orderStatus;
  final String createdAt;
  final Auth? user; 
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.totalAmount,
    required this.shippingAddress,
    this.phoneNumber, 
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
      totalAmount: double.parse(json['total_amount'].toString()),
      shippingAddress: json['shipping_address'],
      phoneNumber: json['phone_number']?.toString(),
      orderStatus: json['order_status'],
      createdAt: json['created_at'],
      user: json['user'] != null ? Auth.fromJson(json['user']) : null,
      items: orderItems,
    );
  }
}
