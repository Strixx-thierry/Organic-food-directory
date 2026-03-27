import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organic_food_directory/bloc/auth/auth_bloc.dart';
import 'package:organic_food_directory/bloc/profile/profile_bloc.dart';
import 'package:organic_food_directory/bloc/product/product_bloc.dart';
import 'package:organic_food_directory/bloc/favorites/favorites_bloc.dart';
import 'package:organic_food_directory/bloc/lists/lists_bloc.dart';
import 'package:organic_food_directory/repositories/user_repository.dart';
import 'package:organic_food_directory/repositories/product_repository.dart';
import 'package:organic_food_directory/repositories/favorites_repository.dart';
import 'package:organic_food_directory/repositories/lists_repository.dart';
import 'package:organic_food_directory/screens/auth_wrapper.dart';
import 'package:organic_food_directory/screens/login_screen.dart';
import 'package:organic_food_directory/screens/signup_screen.dart';
import 'package:organic_food_directory/screens/main_screen.dart';
import 'package:organic_food_directory/screens/category_page.dart';
import 'package:organic_food_directory/screens/product_details_page.dart';
import 'package:organic_food_directory/screens/my_list_page.dart';
import 'package:organic_food_directory/screens/profile_page.dart';
import 'package:organic_food_directory/screens/external_link_page.dart';
import 'package:organic_food_directory/screens/search_results_page.dart';
import 'package:organic_food_directory/screens/edit_profile_page.dart';
import 'package:organic_food_directory/screens/favorites_page.dart';
import 'package:organic_food_directory/screens/privacy_and_security_page.dart';
import 'package:organic_food_directory/screens/help_and_support_page.dart';
import 'package:organic_food_directory/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Clear any cached session so the login page always shows first.
  // Timeout prevents this from blocking startup on slow emulators.
  try {
    await FirebaseAuth.instance.signOut().timeout(const Duration(seconds: 5));
  } catch (_) {}

  await dotenv.load(fileName: ".env");

  // Init notifications in the background — no need to block runApp for this.
  NotificationService().initialize();

  runApp(MyApp(
    userRepo: UserRepository(),
    productRepo: ProductRepository(),
  ));
}

class MyApp extends StatelessWidget {
  final UserRepository userRepo;
  final ProductRepository productRepo;

  const MyApp({super.key, required this.userRepo, required this.productRepo});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(repository: userRepo)),
        BlocProvider(create: (_) => ProfileBloc(repository: userRepo)),
        BlocProvider(create: (_) => ProductBloc(repository: productRepo)),
        BlocProvider(
          create: (_) => FavoritesBloc(
            favRepo: FavoritesRepository(),
            productRepo: productRepo,
          ),
        ),
        BlocProvider(
          create: (_) => ListsBloc(repository: ListsRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Organic Food Directory',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const MainScreen(),
          '/category': (context) => const CategoryPage(),
          '/product': (context) => const ProductDetailsPage(),
          '/my-list': (context) => const MyListPage(),
          '/profile': (context) => const ProfilePage(),
          '/external-link': (context) => const ExternalLinkPage(),
          '/search-results': (context) => const SearchResultsPage(),
          '/edit-profile': (context) => const EditProfilePage(),
          '/favorites': (context) => const FavoritesPage(),
          '/privacy-security': (context) => const PrivacyAndSecurityPage(),
          '/help-support': (context) => const HelpAndSupportPage(),
        },
      ),
    );
  }
}