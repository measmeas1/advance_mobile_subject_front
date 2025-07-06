import 'package:flutter/material.dart';
import 'package:frontend/Screens/users/customers/account_screen.dart';
import 'package:frontend/Screens/users/customers/cart_screen.dart';
import 'package:frontend/Screens/users/customers/category_screen.dart';
import 'package:frontend/Screens/users/customers/homepage_screen.dart';
import 'package:frontend/models/auth_model.dart';

class BottomNav extends StatelessWidget {
  final Auth user;
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNav({
    super.key,
    required this.user,
    required this.currentIndex,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if(index == 0){
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomepageScreen(user: user)));
        }else if(index == 1){
          Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryScreen(user: user,)));
        }else if(index == 2){
          Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(user: user,)));
        }else if(index == 3){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen(user: user)));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Category'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Person')
      ],
    );
  }
}
