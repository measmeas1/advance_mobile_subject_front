
import 'package:flutter/material.dart';
import 'package:frontend/utils/dummy_data.dart';
import 'package:frontend/widgets/product_card.dart';


class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final results = dummyProducts; // Filter logic here

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: TextField(decoration: InputDecoration(hintText: "Search products")),
        ),
        body: Column(
          children: [
            // Chips and filters here...
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (_, i) => ProductCard(product: results[i]),
              ),
            ),
            TextButton(onPressed: () {}, child: Text("Load more")),
          ],
        ),
      ),
    );
  }
}
