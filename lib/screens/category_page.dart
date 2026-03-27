import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:organic_food_directory/models/product_model.dart';
import 'package:organic_food_directory/repositories/product_repository.dart';
import 'package:organic_food_directory/bloc/product/product_bloc.dart';
import 'package:organic_food_directory/bloc/product/product_event.dart';
import 'package:organic_food_directory/bloc/product/product_state.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_bloc.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_event.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_state.dart';
import 'package:organic_food_directory/bloc/auth/auth_bloc.dart';
import 'package:organic_food_directory/bloc/auth/auth_state.dart';
import 'package:organic_food_directory/utils/product_image_helper.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _selectedCategory = 'Vegetables';
  final _productRepository = ProductRepository();

  // Add-product form state
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  String _formCategory = 'Vegetables';
  String _formFresh = 'Today';
  String _formOrganic = '100% Organic';
  String _formFarm = 'Local';
  XFile? _pickedFile;
  Uint8List? _pickedBytes;
  bool _showImageError = false;

  static const List<String> _freshnessOptions = ['Today', 'This Week', 'This Month'];
  static const List<String> _organicOptions = ['100% Organic', '75% Organic', '50% Organic', 'Non-Organic'];
  static const List<String> _farmOptions = ['Local', 'Regional', 'Imported'];

  static const List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Grains',
    'Meat',
    'Organic',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Image helpers ──────────────────────────────────────────────────────────

  Widget _productImage(ProductModel product) {
    if (product.image.startsWith('http')) {
      return Image.network(
        product.image,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (ctx, e, st) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
    return Image.asset(
      ProductImageHelper.getAssetPath(product.name),
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  // ── Add-product bottom sheet ───────────────────────────────────────────────

  Future<void> _pickImage(StateSetter setSheet) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setSheet(() {
        _pickedFile = picked;
        _pickedBytes = bytes;
        _showImageError = false;
      });
    }
  }

  void _submitProduct(StateSetter setSheet) {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedBytes == null) {
      setSheet(() => _showImageError = true);
      return;
    }
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthSuccess ? authState.user.uid : '';
    context.read<ProductBloc>().add(AddProductEvent(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: _priceController.text.trim(),
      category: _formCategory,
      imageBytes: _pickedBytes!,
      phone: _phoneController.text.trim(),
      fresh: _formFresh,
      organic: _formOrganic,
      farm: _formFarm,
      userId: userId,
    ));
  }

  void _showAddProductSheet() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _phoneController.clear();
    _formFresh = 'Today';
    _formOrganic = '100% Organic';
    _formFarm = 'Local';
    _pickedFile = null;
    _pickedBytes = null;
    _showImageError = false;
    _formCategory = 'Vegetables';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocConsumer<ProductBloc, ProductState>(
        listener: (bCtx, state) {
          if (state is ProductAddSuccess) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(bCtx).showSnackBar(
              const SnackBar(
                content: Text('Product added successfully'),
                backgroundColor: Color(0xFF2E7D32),
              ),
            );
          } else if (state is ProductAddError) {
            ScaffoldMessenger.of(bCtx).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (bCtx, productState) {
          final isUploading = productState is ProductAdding;
          return StatefulBuilder(
            builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Add Product',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image picker
                  GestureDetector(
                    onTap: () => _pickImage(setSheet),
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showImageError ? Colors.red : Colors.grey[300]!,
                          width: _showImageError ? 1.5 : 1,
                        ),
                      ),
                      child: _pickedBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(_pickedBytes!,
                                  fit: BoxFit.cover, width: double.infinity),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to pick image from gallery',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (_showImageError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'Please select a product image',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Product Name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration('Description'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: _inputDecoration('Price (e.g. \$4.99)'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Category
                  DropdownButtonFormField<String>(
                    initialValue: _formCategory,
                    decoration: _inputDecoration('Category'),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setSheet(() => _formCategory = v);
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Phone (required for Check Availability)
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration('Phone (WhatsApp number)'),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _formFresh,
                    decoration: _inputDecoration('Freshness'),
                    items: _freshnessOptions
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) { if (v != null) setSheet(() => _formFresh = v); },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _formOrganic,
                    decoration: _inputDecoration('Organic'),
                    items: _organicOptions
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) { if (v != null) setSheet(() => _formOrganic = v); },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _formFarm,
                    decoration: _inputDecoration('Origin'),
                    items: _farmOptions
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) { if (v != null) setSheet(() => _formFarm = v); },
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          isUploading ? null : () => _submitProduct(setSheet),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Add Product',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
      );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedCategory,
          style: const TextStyle(
              color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF1B5E20)),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) => authState is AuthSuccess
            ? FloatingActionButton(
                backgroundColor: const Color(0xFF2E7D32),
                onPressed: _showAddProductSheet,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : const SizedBox.shrink(),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _productRepository.productsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allProducts = snapshot.data ?? [];
          final filtered = allProducts
              .where((p) =>
                  p.category.toLowerCase() == _selectedCategory.toLowerCase())
              .toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 15),

                // Category selector chips
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final selected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF2E7D32)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color:
                                  selected ? Colors.white : Colors.grey[700],
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Text(
                      '${filtered.length} items found',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                allProducts.isEmpty
                                    ? 'No products yet.\nTap + to add one!'
                                    : 'No products in this category',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              _productCard(filtered[index], context),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _productCard(ProductModel product, BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/product', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: _productImage(product),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final isGuest = authState is! AuthSuccess;
                        return BlocBuilder<FavoritesBloc, FavoritesState>(
                          builder: (context, favState) {
                            final isFavorite = favState is FavoritesLoaded &&
                                favState.favorites
                                    .any((p) => p.id == product.id);
                            return GestureDetector(
                              onTap: () {
                                if (isGuest) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Sign in to save favorites'),
                                      backgroundColor: Colors.orange[700],
                                      action: SnackBarAction(
                                        label: 'Sign In',
                                        textColor: Colors.white,
                                        onPressed: () =>
                                            Navigator.pushReplacementNamed(
                                                context, '/login'),
                                      ),
                                    ),
                                  );
                                } else {
                                  context.read<FavoritesBloc>().add(
                                      ToggleFavoriteEvent(product.id));
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isFavorite ? Colors.red : Colors.grey,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.price,
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
