import 'package:flutter/material.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Cart")),
      body: Column(
        children: [
          ListTile(
            title: Text("Items: ${cart.items.length}"),
            subtitle: Text("Subtotal: \$${cart.subtotal.toStringAsFixed(2)}"),
            trailing: Text("Total: \$${cart.total.toStringAsFixed(2)}"),
          ),
          Expanded(
            child: ListView(
              children: cart.items.map((item) {
                return ListTile(
                  leading: Image.network(item.imageUrl),
                  title: Text(item.name),
                  subtitle: Text('\$${item.price}'),
                  trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => cart.removeItem(item)),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(decoration: InputDecoration(hintText: "Promo Code")),
          ),
          ElevatedButton(onPressed: () {}, child: Text("Checkout")),
        ],
      ),
    );
  }
}
