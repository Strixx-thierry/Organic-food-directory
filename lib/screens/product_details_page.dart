import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:organic_food_directory/bloc/auth/auth_bloc.dart';
import 'package:organic_food_directory/bloc/auth/auth_state.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_bloc.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_event.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_state.dart';
import 'package:organic_food_directory/bloc/product/product_bloc.dart';
import 'package:organic_food_directory/bloc/product/product_event.dart';
import 'package:organic_food_directory/bloc/product/product_state.dart';
import 'package:organic_food_directory/models/product_model.dart';
import 'package:organic_food_directory/utils/product_image_helper.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  String _formCategory = 'Vegetables';
  String _formFresh = 'Today';
  String _formOrganic = '100% Organic';
  String _formFarm = 'Local';
  Uint8List? _pickedBytes;

  static const List<String> _categories = [
    'Vegetables', 'Fruits', 'Dairy', 'Grains', 'Meat', 'Organic',
  ];
  static const List<String> _freshnessOptions = ['Today', 'This Week', 'This Month'];
  static const List<String> _organicOptions = ['100% Organic', '75% Organic', '50% Organic', 'Non-Organic'];
  static const List<String> _farmOptions = ['Local', 'Regional', 'Imported'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(StateSetter setSheet) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setSheet(() => _pickedBytes = bytes);
    }
  }

  void _showEditSheet(ProductModel product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price;
    _phoneController.text = product.phone ?? '';
    _formCategory = _categories.contains(product.category) ? product.category : 'Vegetables';
    _formFresh = _freshnessOptions.contains(product.fresh) ? product.fresh! : 'Today';
    _formOrganic = _organicOptions.contains(product.organic) ? product.organic! : '100% Organic';
    _formFarm = _farmOptions.contains(product.farm) ? product.farm! : 'Local';
    _pickedBytes = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocConsumer<ProductBloc, ProductState>(
        listener: (bCtx, state) {
          if (state is ProductEditSuccess || state is ProductDeleteSuccess) {
            Navigator.pop(ctx);
            if (mounted) Navigator.pop(context);
          }
        },
        builder: (bCtx, productState) {
          final isLoading = productState is ProductAdding;
          return StatefulBuilder(
            builder: (ctx2, setSheet) => Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx2).viewInsets.bottom + 24,
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
                        'Edit Product',
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
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _pickedBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(_pickedBytes!, fit: BoxFit.cover, width: double.infinity),
                                )
                              : product.image.startsWith('http')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        product.image,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (c, e, s) => _imagePlaceholder(),
                                      ),
                                    )
                                  : _imagePlaceholder(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 2),
                        child: Text(
                          'Tap image to change',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('Product Name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration('Description'),
                        maxLines: 3,
                        minLines: 1,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        decoration: _inputDecoration('Price (e.g. \$4.99)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _formCategory,
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
                      TextFormField(
                        controller: _phoneController,
                        decoration: _inputDecoration('Phone (WhatsApp number)'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _formFresh,
                        decoration: _inputDecoration('Freshness'),
                        items: _freshnessOptions
                            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setSheet(() => _formFresh = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _formOrganic,
                        decoration: _inputDecoration('Organic'),
                        items: _organicOptions
                            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setSheet(() => _formOrganic = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _formFarm,
                        decoration: _inputDecoration('Origin'),
                        items: _farmOptions
                            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setSheet(() => _formFarm = v);
                        },
                      ),
                      const SizedBox(height: 24),
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (!_formKey.currentState!.validate()) return;
                                  context.read<ProductBloc>().add(EditProductEvent(
                                    productId: product.id,
                                    name: _nameController.text.trim(),
                                    description: _descriptionController.text.trim(),
                                    price: _priceController.text.trim(),
                                    category: _formCategory,
                                    newImageBytes: _pickedBytes,
                                    currentImageUrl: product.image,
                                    phone: _phoneController.text.trim(),
                                    fresh: _formFresh,
                                    organic: _formOrganic,
                                    farm: _formFarm,
                                  ));
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Delete button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final bloc = context.read<ProductBloc>();
                                  final confirmed = await showDialog<bool>(
                                    context: ctx2,
                                    builder: (dCtx) => AlertDialog(
                                      title: const Text('Delete Product'),
                                      content: Text(
                                        'Are you sure you want to delete "${product.name}"? This cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dCtx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(dCtx, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    bloc.add(DeleteProductEvent(product.id));
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[700],
                            side: BorderSide(color: Colors.red[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Delete Product',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text('Tap to pick image from gallery',
            style: TextStyle(color: Colors.grey[500])),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as ProductModel?;

    final productId = product?.id ?? '';
    final productName = product?.name ?? '';
    final productDescription = product?.description ?? '';
    final productPrice = product?.price ?? '';
    final productPhone = product?.phone;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState is AuthSuccess ? authState.user.uid : null;
        final isOwner = currentUserId != null &&
            product?.userId != null &&
            product!.userId == currentUserId;

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: const Color(0xFF2E7D32),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, favState) {
                      final isFavorite = favState is FavoritesLoaded &&
                          favState.favorites.any((p) => p.id == productId);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (authState is! AuthSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Sign in to save favorites'),
                                backgroundColor: Colors.orange[700],
                                action: SnackBarAction(
                                  label: 'Sign In',
                                  textColor: Colors.white,
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(context, '/login'),
                                ),
                              ),
                            );
                          } else {
                            context
                                .read<FavoritesBloc>()
                                .add(ToggleFavoriteEvent(productId));
                          }
                        },
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: product?.image.startsWith('http') == true
                      ? Image.network(
                          product!.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.green[50],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (ctx, e, st) => Container(
                            color: Colors.green[50],
                            child: const Icon(Icons.broken_image,
                                size: 80, color: Colors.green),
                          ),
                        )
                      : Image.asset(
                          ProductImageHelper.getAssetPath(product?.name ?? ''),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, e, st) => Container(
                            color: Colors.green[50],
                            child: const Icon(Icons.image,
                                size: 120, color: Colors.green),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              productName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                SizedBox(width: 4),
                                Text('4.8',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (productDescription.isNotEmpty)
                        Text(
                          productDescription,
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _infoCard(Icons.access_time, 'Fresh',
                              product?.fresh ?? 'Today'),
                          _infoCard(
                            Icons.eco_outlined,
                            (product?.organic ?? '100% Organic')
                                .replaceAll(' Organic', ''),
                            'Organic',
                          ),
                          _infoCard(Icons.location_on_outlined,
                              product?.farm ?? 'Local', 'Farm'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (productDescription.isNotEmpty) ...[
                        const Text(
                          'About Product',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          productDescription,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text(
                      productPrice,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: isOwner
                      ? ElevatedButton(
                          onPressed: () => _showEditSheet(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Edit Product',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            if (productPhone == null || productPhone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contact is not available'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              final url =
                                  'https://wa.me/$productPhone?text=Hi, I am interested in $productName';
                              launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Check Availability',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard(IconData icon, String title, String sub) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12)),
            Text(sub,
                style: TextStyle(color: Colors.grey[600], fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
