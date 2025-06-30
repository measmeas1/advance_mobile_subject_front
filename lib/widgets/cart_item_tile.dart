// lib/widgets/cart_item_tile.dart
import 'package:flutter/material.dart';
import 'package:frontend/widgets/productmodel.dart';

class CartItemTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final int quantity;

  const CartItemTile({
    required this.product,
    required this.quantity,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(product.imageUrl, width: 50, height: 50),
      title: Text(product.name),
      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
      trailing: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: Icon(Icons.remove), onPressed: onDecrease),
              Text('$quantity'),
              IconButton(icon: Icon(Icons.add), onPressed: onIncrease),
            ],
          ),
          IconButton(icon: Icon(Icons.delete), onPressed: onRemove),
        ],
      ),
    );
  }
}
