import 'package:flutter/material.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/service/auth_service.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final User user; // Pass the logged-in admin user
  final Category? category; // Null if adding, not null if editing

  const AddEditCategoryScreen({super.key, required this.user, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<Category> _parentCategories = []; // For parent_id dropdown
  Category? _selectedParentCategory;

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _backendError;

  @override
  void initState() {
    super.initState();
    _fetchParentCategories();

    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _slugController.text = widget.category!.slug ?? '';
      _descriptionController.text = widget.category!.description ?? '';
    }
  }

  Future<void> _fetchParentCategories() async {
    try {
      final categories = await _authService.fetchCategories();
      setState(() {
        // Exclude the current category if editing to prevent self-referencing loops
        _parentCategories = categories.where((cat) => cat.id != widget.category?.id).toList();
        // If editing, try to set the initial selected parent category
        if (widget.category != null && widget.category!.parentId != null) {
          _selectedParentCategory = _parentCategories.firstWhere(
            (cat) => cat.id == widget.category!.parentId,
            orElse: () => _parentCategories.first,
          );
        }
      });
    } catch (e) {
      _showSnackBar('Failed to load parent categories: ${e.toString().replaceFirst('Exception: ', '')}', Colors.red);
    }
  }

  Future<void> _submitCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _backendError = null;
      });

      final newCategory = Category(
        id: widget.category?.id ?? 0, // ID is 0 or existing for new category
        name: _nameController.text,
        slug: _slugController.text.isNotEmpty ? _slugController.text : null,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        parentId: _selectedParentCategory?.id, // Include selected parent category ID
      );

      try {
        if (widget.category == null) {
          // Creating new category
          await _authService.createCategory(newCategory);
          _showSnackBar('Category added successfully!', Colors.green);
        } else {
          // Updating existing category
          await _authService.updateCategory(widget.category!.id, newCategory);
          _showSnackBar('Category updated successfully!', Colors.green);
        }
        if (mounted) {
          Navigator.pop(context, true); // Pop with true to indicate success
        }
      } catch (e) {
        setState(() {
          _backendError = e.toString().replaceFirst('Exception: ', '');
          _showSnackBar('Operation failed: $_backendError', Colors.red);
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
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
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
                    labelText: 'Category Name',
                    prefixIcon: Icon(Icons.folder),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _slugController,
                  decoration: const InputDecoration(
                    labelText: 'Slug (URL-friendly name)',
                    prefixIcon: Icon(Icons.link),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a slug';
                    }
                    // Simple regex for URL-friendly slug (lowercase, numbers, hyphens)
                    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(value)) {
                      return 'Slug must be lowercase, numbers, and hyphens only.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Parent Category Dropdown
                if (_parentCategories.isNotEmpty)
                  DropdownButtonFormField<Category>(
                    value: _selectedParentCategory,
                    decoration: const InputDecoration(
                      labelText: 'Parent Category (Optional)',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('No Parent (Top-level)')), // Option for no parent
                      ..._parentCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (Category? newValue) {
                      setState(() {
                        _selectedParentCategory = newValue;
                      });
                    },
                    hint: const Text('Select a parent category'),
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
                  onPressed: _isLoading ? null : _submitCategory,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.category == null ? 'Add Category' : 'Update Category'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
