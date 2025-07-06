// lib/Screens/users/customers/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/models/auth_model.dart'; // Import Auth model
import 'package:frontend/service/auth_service.dart'; // Import AuthService for update logic
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io'; // For File

class EditProfileScreen extends StatefulWidget {
  final Auth currentUser; // The user object to be edited

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController; // Email might not be editable, but included for completeness

  File? _selectedImage; // The new image file chosen by the user
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _backendError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _emailController = TextEditingController(text: widget.currentUser.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Function to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
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
              if (widget.currentUser.profileImageUrl != null || _selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Remove Current Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null; // Clear selected new image
                      // You might need a way to tell the backend to remove the existing image
                      // This would typically be a specific field in the update request, e.g., 'remove_profile_image': true
                      // For now, we'll just clear the local selection.
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _backendError = null;
      });

      try {
        // Call the service method to update profile
        final updatedUser = await _authService.updateUserProfile(
          name: _nameController.text,
          email: _emailController.text, // Pass email even if not editable, as it's part of user model
          imageFile: _selectedImage,
          // You might need to pass a flag if the user explicitly wants to remove the profile image
          // For example: removeExistingImage: _selectedImage == null && widget.currentUser.profileImageUrl != null,
        );

        _showSnackBar('Profile updated successfully!', Colors.green);
        if (mounted) {
          // Pop the screen and pass the updated user object back
          Navigator.pop(context, updatedUser);
        }
      } catch (e) {
        setState(() {
          _backendError = e.toString().replaceFirst('Exception: ', '');
          _showSnackBar('Profile update failed: $_backendError', Colors.red);
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
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green,
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
                GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.green,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!) as ImageProvider<Object>?
                              : (widget.currentUser.profileImageUrl != null && widget.currentUser.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(widget.currentUser.profileImageUrl!) as ImageProvider<Object>?
                                  : null),
                          child: (_selectedImage == null && (widget.currentUser.profileImageUrl == null || widget.currentUser.profileImageUrl!.isEmpty))
                              ? const Icon(Icons.person, size: 80, color: Colors.white)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.green[700],
                            radius: 20,
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Your email address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true, // Typically email is not editable after registration
                  style: TextStyle(color: Colors.grey[700]),
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
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
