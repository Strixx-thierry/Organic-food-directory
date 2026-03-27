import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
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
            final products = state is ProductLoaded ? state.products : [];
        
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
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
                                Icons.apple_outlined,
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
                child: Image.asset(
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
                      Row(
                        children: [
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
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/product'),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
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