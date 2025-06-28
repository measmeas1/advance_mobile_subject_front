import 'package:flutter/material.dart';
import 'package:frontend/utils/dummy_data.dart';
import 'package:frontend/widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = dummyProducts;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: TextField(decoration: InputDecoration(hintText: 'Search...'))),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['Shoes', 'Electronics', 'Fashion']
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Chip(label: Text(e)),
                        ))
                    .toList(),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemBuilder: (_, index) => ProductCard(product: products[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
