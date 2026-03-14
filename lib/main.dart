import 'package:flutter/material.dart';
import 'package:organic_food_directory/screens/splash_screen.dart';
import 'package:organic_food_directory/screens/login_screen.dart';
import 'package:organic_food_directory/screens/main_screen.dart';
import 'package:organic_food_directory/screens/home_page.dart';
import 'package:organic_food_directory/screens/category_page.dart';
import 'package:organic_food_directory/screens/product_details_page.dart';
import 'package:organic_food_directory/screens/my_list_page.dart';
import 'package:organic_food_directory/screens/profile_page.dart';
import 'package:organic_food_directory/screens/external_link_page.dart';
import 'package:organic_food_directory/screens/search_results_page.dart';
import 'package:organic_food_directory/screens/edit_profile_page.dart';
import 'package:organic_food_directory/screens/favorites_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organic Food Directory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
        '/category': (context) => const CategoryPage(),
        '/product': (context) => const ProductDetailsPage(),
        '/my-list': (context) => const MyListPage(),
        '/profile': (context) => const ProfilePage(),
        '/external-link': (context) => const ExternalLinkPage(),
        '/search-results': (context) => const SearchResultsPage(),
        '/edit-profile': (context) => const EditProfilePage(),
        '/favorites': (context) => const FavoritesPage(),
      },
    );
  }
}