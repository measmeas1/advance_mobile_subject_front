// lib/screens/account_screen.dart
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account")),
      body: ListView(
        children: [
          ListTile(title: Text("User Profile")),
          ExpansionTile(title: Text("Order History"), children: [Text("Order 1"), Text("Order 2")]),
          ExpansionTile(title: Text("Favorites ❤️"), children: [Text("Item 1"), Text("Item 2")]),
          ListTile(title: Text("Settings")),
          ListTile(title: Text("Logout")),
        ],
      ),
    );
  }
}
