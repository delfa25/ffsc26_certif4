import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';

import 'features/posts/data/datasources/post_local_data_source.dart';
import 'features/posts/data/datasources/post_remote_data_source.dart';
import 'features/posts/data/repositories/post_repository_impl.dart';
import 'features/posts/domain/usecases/get_posts_usecase.dart';
import 'features/posts/presentation/providers/post_provider.dart';

import 'features/products/data/datasources/product_local_data_source.dart';
import 'features/products/data/datasources/product_remote_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/usecases/get_product_details_usecase.dart';
import 'features/products/domain/usecases/get_products_usecase.dart';
import 'features/products/presentation/providers/product_provider.dart';

import 'features/recipes/data/datasources/recipe_local_data_source.dart';
import 'features/recipes/data/datasources/recipe_remote_data_source.dart';
import 'features/recipes/data/repositories/recipe_repository_impl.dart';
import 'features/recipes/domain/usecases/get_recipes_usecase.dart';
import 'features/recipes/presentation/providers/recipe_provider.dart';
import 'features/auth/domain/usecases/refresh_token_usecase.dart';

import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Initialisation de Hive pour la mise en cache locale performante
  await Hive.initFlutter();
  final productsBox = await Hive.openBox('products_box');
  final postsBox = await Hive.openBox('posts_box');
  final recipesBox = await Hive.openBox('recipes_box');
  final authBox = await Hive.openBox('auth_box');

  final dio = Dio();
  final apiClient = ApiClient(dioClient: dio, prefs: prefs);

  // Auth dependencies
  final authRemote = AuthRemoteDataSourceImpl(dio: apiClient.dio);
  final authLocal = AuthLocalDataSourceImpl(prefs: prefs, box: authBox);
  final authRepo = AuthRepositoryImpl(remoteDataSource: authRemote, localDataSource: authLocal);

  // Products dependencies (1er écran de données REST)
  final productRemote = ProductRemoteDataSourceImpl(dio: apiClient.dio);
  final productLocal = ProductLocalDataSourceImpl(box: productsBox, prefs: prefs);
  final productRepo = ProductRepositoryImpl(remoteDataSource: productRemote, localDataSource: productLocal);

  // Posts dependencies (2e écran de données REST)
  final postRemote = PostRemoteDataSourceImpl(dio: apiClient.dio);
  final postLocal = PostLocalDataSourceImpl(box: postsBox, prefs: prefs);
  final postRepo = PostRepositoryImpl(remoteDataSource: postRemote, localDataSource: postLocal);

  // Recipes dependencies (3e écran de données REST)
  final recipeRemote = RecipeRemoteDataSourceImpl(dio: apiClient.dio);
  final recipeLocal = RecipeLocalDataSourceImpl(box: recipesBox, prefs: prefs);
  final recipeRepo = RecipeRepositoryImpl(remoteDataSource: recipeRemote, localDataSource: recipeLocal);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: LoginUseCase(authRepo),
            registerUseCase: RegisterUseCase(authRepo),
            logoutUseCase: LogoutUseCase(authRepo),
            getCurrentUserUseCase: GetCurrentUserUseCase(authRepo),
            refreshTokenUseCase: RefreshTokenUseCase(authRepo),
          )..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            getProductsUseCase: GetProductsUseCase(productRepo),
            getProductDetailsUseCase: GetProductDetailsUseCase(productRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(
            getPostsUseCase: GetPostsUseCase(postRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(
            getRecipesUseCase: GetRecipesUseCase(recipeRepo),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Certification App - Fullstack Flutter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.status == AuthStatus.loading ||
              authProvider.status == AuthStatus.uninitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (authProvider.isAuthenticated) {
            return const HomePage();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
