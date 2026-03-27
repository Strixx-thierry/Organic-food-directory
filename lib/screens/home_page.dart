import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:organic_food_directory/bloc/product/product_bloc.dart';
import 'package:organic_food_directory/bloc/product/product_event.dart';
import 'package:organic_food_directory/bloc/product/product_state.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_bloc.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_event.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_state.dart';
import 'package:organic_food_directory/bloc/auth/auth_bloc.dart';
import 'package:organic_food_directory/bloc/auth/auth_state.dart';
import 'package:organic_food_directory/widgets/notification_icon_button.dart';
import 'package:organic_food_directory/utils/notification_dialog_helper.dart';
import 'package:organic_food_directory/models/product_model.dart';
import 'package:organic_food_directory/utils/product_image_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  String _formCategory = 'Vegetables';
  String _formFresh = 'Today';
  String _formOrganic = '100% Organic';
  String _formFarm = 'Local';
  XFile? _pickedFile;
  Uint8List? _pickedBytes;
  bool _showImageError = false;
  // Cache the last loaded list so the grid doesn't blank out during ProductAdding.
  List<ProductModel> _lastProducts = [];

  static const List<String> _categories = [
    'Vegetables', 'Fruits', 'Dairy', 'Grains', 'Meat', 'Organic',
  ];
  static const List<String> _freshnessOptions = ['Today', 'This Week', 'This Month'];
  static const List<String> _organicOptions = ['100% Organic', '75% Organic', '50% Organic', 'Non-Organic'];
  static const List<String> _farmOptions = ['Local', 'Regional', 'Imported'];

  @override
  void dispose() {
    _nameController.dispose();
    _subController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(StateSetter setSheet) async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
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
    context.read<ProductBloc>().add(AddProductEvent(
      name: _nameController.text.trim(),
      sub: _subController.text.trim(),
      price: _priceController.text.trim(),
      category: _formCategory,
      imageBytes: _pickedBytes!,
      phone: _phoneController.text.trim(),
      fresh: _formFresh,
      organic: _formOrganic,
      farm: _formFarm,
    ));
  }

  void _showAddProductSheet() {
    _nameController.clear();
    _subController.clear();
    _priceController.clear();
    _phoneController.clear();
    _pickedFile = null;
    _pickedBytes = null;
    _showImageError = false;
    _formCategory = 'Vegetables';
    _formFresh = 'Today';
    _formOrganic = '100% Organic';
    _formFarm = 'Local';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocBuilder<ProductBloc, ProductState>(
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
                                Text('Tap to pick image from gallery',
                                    style: TextStyle(color: Colors.grey[500])),
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
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Product Name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _subController,
                    decoration: _inputDecoration('Subtitle'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    decoration: _inputDecoration('Price (e.g. \$4.99)'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _formCategory,
                    decoration: _inputDecoration('Category'),
                    items: _categories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setSheet(() => _formCategory = v);
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
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
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () => _submitProduct(setSheet),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Add Product',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductAddSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added successfully'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        } else if (state is ProductAddError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // Get user name from AuthBloc
          String userName = 'User';
          if (authState is AuthSuccess) {
            userName = authState.user.name;
          }

          return BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
            if (state is ProductInitial) {
              context.read<ProductBloc>().add(LoadProductsEvent());
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is ProductLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is ProductLoaded) _lastProducts = state.products;
            final products = _lastProducts;
        
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              floatingActionButton: FloatingActionButton(
                backgroundColor: const Color(0xFF2E7D32),
                onPressed: _showAddProductSheet,
                child: const Icon(Icons.add, color: Colors.white),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $userName👋',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              Text(
                                'Find your fresh organic food',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: NotificationIconButton(
                              showBackground: false,
                              color: const Color(0xFF1B5E20),
                              onPressed: () {
                                NotificationDialogHelper.showNotificationsDialog(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/search-results'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: Color(0xFF1B5E20)),
                              const SizedBox(width: 10),
                              Text(
                                'Search organic products...',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 16),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/category'),
                            child: const Text(
                              'See All',
                              style: TextStyle(color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _categoryItem(
                                'Vegetables',
                                Icons.eco_outlined,
                                Colors.green[50]!,
                                context),
                            _categoryItem(
                                'Fruits',
                                Icons.local_florist,
                                Colors.orange[50]!,
                                context),
                            _categoryItem(
                                'Dairy',
                                Icons.egg_outlined,
                                Colors.yellow[50]!,
                                context),
                            _categoryItem(
                                'Grains',
                                Icons.grass_outlined,
                                Colors.brown[50]!,
                                context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'See All',
                              style: TextStyle(color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.75,
                        children: products.isEmpty
                            ? [
                                _productItem(const ProductModel(id: 'spinach-1', name: 'Organic Spinach', sub: 'Fresh greens', price: '\$4.50', category: '', image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLuIic4tYcrZvlnqopdsZRyuciPM77rza6Qw&s'), context),
                                _productItem(const ProductModel(id: 'tomato-1', name: 'Red Tomatoes', sub: 'Organic farm', price: '\$3.20', category: '', image: 'https://cdn.prod.website-files.com/5b0fe2f89e0734b12f0d7f7e/5ea325d360a1b6c56a0452b4_Brand%20ecomm%20images%20square.png'), context),
                                _productItem(const ProductModel(id: 'apple-1', name: 'Sweet Apples', sub: 'Fresh fruits', price: '\$5.10', category: '', image: 'https://www.gurneys.com/cdn/shop/files/12984A.webp?v=1729090097'), context),
                                _productItem(const ProductModel(id: 'eggs-1', name: 'Brown Eggs', sub: 'Cage free', price: '\$6.50', category: '', image: 'https://images.squarespace-cdn.com/content/v1/63def75d6c752e7159ee7dd3/1689095881545-GJZCBTOHB8MF8LUHTLP7/Hope+Hill+Family+Farms+Brown+Eggs.jpg'), context),
                              ]
                            : products
                                .take(4)
                                .map((p) => _productItem(p, context))
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
            },
          );
        },
      ),
    );
  }



  Widget _categoryItem(
    String name,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/category'),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: const Color(0xFF1B5E20), size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _productItem(
    ProductModel product,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: product.image.startsWith('http')
                    ? Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                        errorBuilder: (ctx, e, st) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        ProductImageHelper.getAssetPath(product.name),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.sub,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.price,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          return BlocBuilder<FavoritesBloc, FavoritesState>(
                            builder: (context, state) {
                              final isFavorite = state is FavoritesLoaded &&
                                  state.favorites.any((p) => p.id == product.id);
                              final isGuest = authState is! AuthSuccess;
                              return GestureDetector(
                                onTap: () {
                                  if (isGuest) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Sign in to save favorites'),
                                        backgroundColor: Colors.orange[700],
                                        action: SnackBarAction(
                                          label: 'Sign In',
                                          textColor: Colors.white,
                                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                                        ),
                                      ),
                                    );
                                  } else {
                                    context
                                        .read<FavoritesBloc>()
                                        .add(ToggleFavoriteEvent(product.id));
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: const Color(0xFF2E7D32),
                                    size: 18,
                                  ),
                                ),
                              );
                            },
                          );
                        },
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