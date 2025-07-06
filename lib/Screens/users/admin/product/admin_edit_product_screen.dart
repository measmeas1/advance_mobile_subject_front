// lib/screens/admin/add_edit_product_screen.dart
// This screen is for admins to add or edit product details, now with image picking.

import 'package:flutter/material.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/service/category_service.dart';
import 'package:frontend/service/product_service.dart';
import 'package:image_picker/image_picker.dart'; // Corrected import for image_picker
import 'dart:io';

class AddEditProductScreen extends StatefulWidget {
  final Auth user;
  final Product? product; // Null if adding, not null if editing

  const AddEditProductScreen({super.key, required this.user, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController(); 
  
  List<Category> _availableCategories = [];
  Category? _selectedCategory; // This can be null, which is correct

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  bool _isLoading = false;
  String? _backendError;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesForDropdown();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stockQuantity.toString();
      _imageUrlController.text = widget.product!.imageUrl ?? '';
    }
  }

  // Function to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageUrlController.clear(); // Clear URL field if image is picked
      });
    }
  }

  // Function to show image source selection dialog
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null; // Remove selected image
                    _imageUrlController.clear(); // Clear the text field too
                    // If editing and had an original URL, restore it for display
                    if (widget.product != null && widget.product!.imageUrl != null) {
                      _imageUrlController.text = widget.product!.imageUrl!;
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to fetch categories for the dropdown
  Future<void> _fetchCategoriesForDropdown() async {
    try {
      final categories = await _categoryService.fetchCategories();
      setState(() {
        _availableCategories = categories;
        _selectedCategory = null; // Default to null

        // Find the category by ID if product is being edited and has a categoryId
        if (widget.product != null && widget.product!.categoryId != null) {
          Category? foundCategory;
          for (var category in categories) {
            if (category.id == widget.product!.categoryId) {
              foundCategory = category;
              break; // Found it, exit loop
            }
          }
          _selectedCategory = foundCategory; // Set to found category or null if not found
        }
      });
    } catch (e) {
      _showSnackBar('Failed to load categories for dropdown: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
      setState(() {
        _availableCategories = []; // Ensure list is empty on error
        _selectedCategory = null; // Ensure selected category is null on error
      });
    }
  }

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _backendError = null;
      });

      final productData = Product(
        id: widget.product?.id ?? 0,
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        price: double.parse(_priceController.text),
        stockQuantity: int.parse(_stockController.text),
        imageUrl: _selectedImage == null ? (_imageUrlController.text.isNotEmpty ? _imageUrlController.text : null) : null,
        categoryId: _selectedCategory?.id, // This is already nullable, so it's fine
      );

      try {
        if (widget.product == null) {
          await _productService.createProduct(productData, imageFile: _selectedImage);
          _showSnackBar('Product added successfully!', Colors.green);
        } else {
          await _productService.updateProduct(widget.product!.id, productData, imageFile: _selectedImage);
          _showSnackBar('Product updated successfully!', Colors.green);
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _backendError = e.toString().replaceFirst('Exception: ', '');
          _showSnackBar('Operation failed: $_backendError', Colors.red);
          // 'Operation failed: $_backendError', Colors.red
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stock quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid integer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Image Picker and Preview Section
                GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    alignment: Alignment.center,
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : (widget.product?.imageUrl != null && _imageUrlController.text.isEmpty)
                            ? Image.network(
                                widget.product!.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                                },
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to Add Image',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (Fallback/Existing)',
                    hintText: 'Enter URL if not uploading new image',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  enabled: _selectedImage == null, // Disable if an image file is selected
                  validator: (value) {
                    if (_selectedImage == null && value != null && value.isNotEmpty && !Uri.tryParse(value)!.isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Category Dropdown
                _availableCategories.isNotEmpty
                    ? DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category (Optional)',
                          prefixIcon: Icon(Icons.category),
                        ),
                        // Add a "No Category" option to allow explicit null selection
                        items: [
                          const DropdownMenuItem<Category>(
                            value: null,
                            child: Text('No Category'),
                          ),
                          ..._availableCategories.map((category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (Category? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        hint: const Text('Select a category'),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text('Loading categories or no categories available...'),
                      ),
                const SizedBox(height: 24),
                if (_backendError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _backendError!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitProduct,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.product == null ? 'Add Product' : 'Update Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
