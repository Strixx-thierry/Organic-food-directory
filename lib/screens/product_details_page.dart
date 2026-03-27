import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_bloc.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_event.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_state.dart';
import 'package:organic_food_directory/bloc/auth/auth_bloc.dart';
import 'package:organic_food_directory/bloc/auth/auth_state.dart';
import 'package:organic_food_directory/models/product_model.dart';
import 'package:organic_food_directory/utils/product_image_helper.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as ProductModel?;

    final productId = product?.id ?? 'demo-spinach';
    final productName = product?.name ?? 'Organic Spinach';
    final productSub = product?.sub ?? '1kg, Fresh from farm';
    final productPrice = product?.price ?? '\$4.50';
    final productPhone = product?.phone;

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
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final isGuest = authState is! AuthSuccess;
                  return BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, state) {
                      final isFavorite = state is FavoritesLoaded &&
                          state.favorites.any((p) => p.id == productId);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
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
                            context.read<FavoritesBloc>().add(ToggleFavoriteEvent(productId));
                          }
                        },
                      );
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
                          child: const Center(
                              child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (ctx, e, st) => Container(
                        color: Colors.green[50],
                        child: const Icon(Icons.broken_image,
                            size: 80, color: Colors.green),
                      ),
                    )
                  : Image.asset(
                      ProductImageHelper.getAssetPath(
                          product?.name ?? ''),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productSub,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _infoCard(Icons.access_time, 'Fresh', product?.fresh ?? 'Today'),
                      _infoCard(Icons.eco_outlined, product?.organic ?? '100%', 'Organic'),
                      _infoCard(Icons.location_on_outlined, product?.farm ?? 'Local', 'Farm'),
                    ],
                  ),
                  const SizedBox(height: 32),
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
                    'Our organic product is grown without any synthetic pesticides or fertilizers. It is harvested fresh daily and delivered straight to your door. Packed with nutrients, it is the perfect addition to your healthy diet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
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
                const Text('Price', style: TextStyle(color: Colors.grey, fontSize: 14)),
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
              child: ElevatedButton(
                onPressed: () {
                  if (productPhone == null || productPhone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact is not available'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    final url = 'https://wa.me/$productPhone?text=Hi, I am interested in $productName';
                    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
