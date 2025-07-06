import 'package:flutter/material.dart';
import 'package:frontend/Screens/users/components/bottom_nav.dart';
import 'package:frontend/Screens/users/customers/account_screen.dart';
import 'package:frontend/Screens/users/customers/products/product_detail_screen.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/service/category_service.dart';
import 'package:frontend/service/product_service.dart';

class HomepageScreen extends StatefulWidget {
  final Auth user;
  final Category? selectedCategory;

  const HomepageScreen({super.key, required this.user, this.selectedCategory});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  late Future<List<Product>> _productsFuture;
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();
  List<Category> _categories = [];
  Category? _selectedCategory;

  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _fetchProducts();
    _fetchCategories();
  }

  void _fetchProducts() {
    setState(() {
      _productsFuture = _productService.fetchProducts(
        categoryId: _selectedCategory?.id,
      );
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryService.fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      _showSnackBar('Failed to load categories: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _navigateToAccountScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountScreen(user: widget.user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Hello, ${widget.user.name}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap:
                            _navigateToAccountScreen,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green[100],
                            border: Border.all(
                              color: Colors.green.withOpacity(0.2),
                              width: 1.5,
                            ),
                            image:
                                widget.user.profileImageUrl != null
                                    ? DecorationImage(
                                      image: NetworkImage(
                                        widget.user.profileImageUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              widget.user.profileImageUrl == null
                                  ? Icon(Icons.person, color: Colors.green[700])
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.green[600],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.green[600],
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                                : null,
                      ),
                      onSubmitted: (value) {
                        _fetchProducts();
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory?.id == category.id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                          _fetchProducts();
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.green[400],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.green[800],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color:
                              isSelected
                                  ? Colors.green[400]!
                                  : Colors.green[200]!,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Products Grid
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}\nPull to refresh.',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        _selectedCategory != null
                            ? 'No products in this category'
                            : 'No products available',
                        style: TextStyle(color: Colors.green[800]),
                      ),
                    );
                  } else {
                    return RefreshIndicator(
                      onRefresh: () async {
                        _fetchProducts();
                        _fetchCategories();
                      },
                      backgroundColor: Colors.white,
                      color: Colors.green,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.65,
                            ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final product = snapshot.data![index];
                          return ProductCard(
                            product: product,
                            user: widget.user,
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        user: widget.user,
        currentIndex: _selectedIndex,
      ),
    );
  }
}


class ProductCard extends StatelessWidget {
  final Product product;
  final Auth user;

  const ProductCard({super.key, required this.product, required this.user});

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ProductDetailScreen(product: product, user: user),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 1, // Square image
                child: Image.network(
                  product.imageUrl ??
                      'https://placehold.co/600x600/E0E0E0/000000?text=No+Image',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              product.stockQuantity > 0
                                  ? Colors.green[50]
                                  : Colors.red[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.stockQuantity > 0 ? 'In Stock' : 'Sold Out',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                product.stockQuantity > 0
                                    ? Colors.green[800]
                                    : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
