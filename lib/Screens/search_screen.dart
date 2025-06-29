import 'package:flutter/material.dart';
import 'package:frontend/utils/dummy_data.dart';
import 'package:frontend/widgets/product_card.dart';
import 'package:frontend/models/product.dart'; // Make sure this exists

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = dummyProducts;
  int _visibleItemCount = 10;

  void _filterProducts(String query) {
    final results = dummyProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _searchResults = results;
      _visibleItemCount = 10;
    });
  }

  void _loadMore() {
    setState(() {
      _visibleItemCount = (_visibleItemCount + 10).clamp(0, _searchResults.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleResults = _searchResults.take(_visibleItemCount).toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Container(
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: "Search products",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Optional: add category chips here
            Expanded(
              child: visibleResults.isEmpty
                  ? Center(child: Text("No products found"))
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: visibleResults.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ProductCard(product: visibleResults[i]),
                      ),
                    ),
            ),
            if (_visibleItemCount < _searchResults.length)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: _loadMore,
                  child: Text("Load more"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
