import 'package:flutter/material.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/service/cart_service.dart';
import 'package:frontend/service/favorite_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Auth user;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.user,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  final FavoriteService _favoriteService = FavoriteService();
  final CartService _cartService = CartService();
  bool _isFavorited = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final status = await _favoriteService.isFavorite(widget.product.id);
      if (mounted) {
        setState(() {
          _isFavorited = status;
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (!mounted) return;
    
    setState(() {
      _isFavorited = !_isFavorited;
    });
    
    try {
      if (_isFavorited) {
        await _favoriteService.addFavorite(widget.product);
        _showSnackBar('Added to favorites!', Colors.green);
      } else {
        await _favoriteService.removeFavorite(widget.product.id);
        _showSnackBar('Removed from favorites!', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorited = !_isFavorited;
        });
      }
      _showSnackBar('Failed to update favorites: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _addToCart() async {
    if (!mounted) return;
    
    setState(() {
      _isAddingToCart = true;
    });
    
    try {
      await _cartService.addToCart(widget.product, _quantity);
      _showSnackBar('${_quantity}x ${widget.product.name} added to cart!', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to add to cart: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = widget.product.stockQuantity <= 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Product Detail ',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.green, // Changed to black for better visibility
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFE8F5E9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.green), // Changed to black
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : Colors.green, // Changed to black
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Image.network(
                      widget.product.imageUrl ?? 'https://placehold.co/600x400/E0E0E0/000000?text=No+Image',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                    // Add a semi-transparent gradient overlay at the top to improve text visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              automaticallyImplyLeading: false, // This removes the default back button
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price and Stock Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isOutOfStock 
                                ? Colors.red[100]
                                : Colors.green[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory,
                                size: 16,
                                color: isOutOfStock 
                                    ? Colors.red[700]
                                    : Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOutOfStock
                                    ? 'Out of Stock'
                                    : 'In Stock (${widget.product.stockQuantity})',
                                style: TextStyle(
                                  color: isOutOfStock
                                      ? Colors.red[700]
                                      : Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Product Name
                    Text(
                      widget.product.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Description Section
                    Text(
                      'About this product',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description ?? 'No description available.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Quantity Selector
                    if (!isOutOfStock) ...[
                      Text(
                        'Quantity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  if (_quantity > 1) _quantity--;
                                });
                              },
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                _quantity.toString(),
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  if (_quantity < widget.product.stockQuantity) {
                                    _quantity++;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Add to Cart Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isAddingToCart ? null : _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isAddingToCart
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shopping_cart),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add to Cart',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ] else ...[
                      // Out of Stock Message
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[100]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This product is currently out of stock',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Check back later for availability',
                              style: TextStyle(
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}