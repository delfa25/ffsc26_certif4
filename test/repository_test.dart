import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ffsc26_certif4/core/errors/exceptions.dart';
import 'package:ffsc26_certif4/core/errors/failures.dart';
import 'package:ffsc26_certif4/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ffsc26_certif4/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ffsc26_certif4/features/auth/data/models/user_model.dart';
import 'package:ffsc26_certif4/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ffsc26_certif4/features/products/data/datasources/product_local_data_source.dart';
import 'package:ffsc26_certif4/features/products/data/datasources/product_remote_data_source.dart';
import 'package:ffsc26_certif4/features/products/data/models/product_model.dart';
import 'package:ffsc26_certif4/features/products/data/repositories/product_repository_impl.dart';
import 'package:ffsc26_certif4/features/posts/data/datasources/post_local_data_source.dart';
import 'package:ffsc26_certif4/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:ffsc26_certif4/features/posts/data/models/post_model.dart';
import 'package:ffsc26_certif4/features/posts/data/repositories/post_repository_impl.dart';
import 'package:ffsc26_certif4/features/recipes/data/datasources/recipe_local_data_source.dart';
import 'package:ffsc26_certif4/features/recipes/data/datasources/recipe_remote_data_source.dart';
import 'package:ffsc26_certif4/features/recipes/data/models/recipe_model.dart';
import 'package:ffsc26_certif4/features/recipes/data/repositories/recipe_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockProductRemoteDataSource extends Mock implements ProductRemoteDataSource {}
class MockProductLocalDataSource extends Mock implements ProductLocalDataSource {}
class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}
class MockPostLocalDataSource extends Mock implements PostLocalDataSource {}
class MockRecipeRemoteDataSource extends Mock implements RecipeRemoteDataSource {}
class MockRecipeLocalDataSource extends Mock implements RecipeLocalDataSource {}

void main() {
  group('AuthRepositoryImpl Unit Tests', () {
    late AuthRepositoryImpl repository;
    late MockAuthRemoteDataSource mockRemote;
    late MockAuthLocalDataSource mockLocal;

    setUp(() {
      mockRemote = MockAuthRemoteDataSource();
      mockLocal = MockAuthLocalDataSource();
      repository = AuthRepositoryImpl(remoteDataSource: mockRemote, localDataSource: mockLocal);
    });

    const tUser = UserModel(
      id: 1,
      username: 'emilys',
      email: 'emily@dummy.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'female',
      image: '',
      accessToken: 'token123',
      refreshToken: 'refresh123',
    );

    test('login success saves user to local data source', () async {
      when(() => mockRemote.login('emilys', 'pass')).thenAnswer((_) async => tUser);
      when(() => mockLocal.saveUser(tUser)).thenAnswer((_) async => {});

      final user = await repository.login('emilys', 'pass');

      expect(user.username, 'emilys');
      verify(() => mockLocal.saveUser(tUser)).called(1);
    });

    test('login server error throws AuthFailure', () async {
      when(() => mockRemote.login('bad', 'bad')).thenThrow(ServerException(message: 'Error'));

      expect(() => repository.login('bad', 'bad'), throwsA(isA<AuthFailure>()));
    });

    test('refreshToken updates local tokens and returns refreshed user', () async {
      when(() => mockLocal.getRefreshToken()).thenAnswer((_) async => 'refresh123');
      when(() => mockRemote.refreshToken('refresh123')).thenAnswer((_) async => {
        'accessToken': 'newAccessToken',
        'refreshToken': 'newRefreshToken',
      });
      when(() => mockLocal.saveTokens(accessToken: 'newAccessToken', refreshToken: 'newRefreshToken'))
          .thenAnswer((_) async => {});
      when(() => mockLocal.getSavedUser()).thenAnswer((_) async => tUser.copyWithTokens(
        accessToken: 'newAccessToken',
        refreshToken: 'newRefreshToken',
      ));

      final result = await repository.refreshToken();

      expect(result.accessToken, 'newAccessToken');
      expect(result.refreshToken, 'newRefreshToken');
      verify(() => mockRemote.refreshToken('refresh123')).called(1);
    });
  });

  group('ProductRepositoryImpl Unit Tests', () {
    late ProductRepositoryImpl repository;
    late MockProductRemoteDataSource mockRemote;
    late MockProductLocalDataSource mockLocal;

    setUp(() {
      mockRemote = MockProductRemoteDataSource();
      mockLocal = MockProductLocalDataSource();
      repository = ProductRepositoryImpl(remoteDataSource: mockRemote, localDataSource: mockLocal);
    });

    const tProducts = [
      ProductModel(
        id: 10,
        title: 'Smartphone',
        description: 'Great phone',
        price: 499.99,
        rating: 4.8,
        brand: 'TechBrand',
        category: 'smartphones',
        thumbnail: '',
        images: [],
        stock: 10,
      )
    ];

    test('getProducts online fetches from remote and caches data', () async {
      when(() => mockRemote.getProducts(query: null)).thenAnswer((_) async => tProducts);
      when(() => mockLocal.cacheProducts(tProducts)).thenAnswer((_) async => {});

      final result = await repository.getProducts();

      expect(result.isCached, isFalse);
      expect(result.products.length, 1);
      verify(() => mockLocal.cacheProducts(tProducts)).called(1);
    });

    test('getProducts offline falls back to local cache', () async {
      when(() => mockRemote.getProducts(query: null)).thenThrow(NetworkException());
      when(() => mockLocal.getCachedProducts()).thenAnswer((_) async => tProducts);

      final result = await repository.getProducts();

      expect(result.isCached, isTrue);
      expect(result.products.first.id, 10);
      verify(() => mockLocal.getCachedProducts()).called(1);
    });

    test('getProductById fetches product detail online', () async {
      when(() => mockRemote.getProductById(10)).thenAnswer((_) async => tProducts.first);

      final result = await repository.getProductById(10);

      expect(result.id, 10);
      expect(result.title, 'Smartphone');
      verify(() => mockRemote.getProductById(10)).called(1);
    });
  });

  group('PostRepositoryImpl Unit Tests', () {
    late PostRepositoryImpl repository;
    late MockPostRemoteDataSource mockRemote;
    late MockPostLocalDataSource mockLocal;

    setUp(() {
      mockRemote = MockPostRemoteDataSource();
      mockLocal = MockPostLocalDataSource();
      repository = PostRepositoryImpl(remoteDataSource: mockRemote, localDataSource: mockLocal);
    });

    const tPosts = [
      PostModel(
        id: 101,
        title: 'Flutter Clean Architecture',
        body: 'Building scalable flutter apps...',
        userId: 1,
        tags: ['flutter', 'dart'],
        views: 120,
        likes: 50,
        dislikes: 2,
      )
    ];

    test('getPosts online fetches from remote and caches data', () async {
      when(() => mockRemote.getPosts()).thenAnswer((_) async => tPosts);
      when(() => mockLocal.cachePosts(tPosts)).thenAnswer((_) async => {});

      final result = await repository.getPosts();

      expect(result.isCached, isFalse);
      expect(result.posts.first.id, 101);
      verify(() => mockLocal.cachePosts(tPosts)).called(1);
    });

    test('getPosts offline falls back to local cache', () async {
      when(() => mockRemote.getPosts()).thenThrow(ServerException(message: 'Offline'));
      when(() => mockLocal.getCachedPosts()).thenAnswer((_) async => tPosts);

      final result = await repository.getPosts();

      expect(result.isCached, isTrue);
      expect(result.posts.first.id, 101);
      verify(() => mockLocal.getCachedPosts()).called(1);
    });
  });

  group('RecipeRepositoryImpl Unit Tests', () {
    late RecipeRepositoryImpl repository;
    late MockRecipeRemoteDataSource mockRemote;
    late MockRecipeLocalDataSource mockLocal;

    setUp(() {
      mockRemote = MockRecipeRemoteDataSource();
      mockLocal = MockRecipeLocalDataSource();
      repository = RecipeRepositoryImpl(remoteDataSource: mockRemote, localDataSource: mockLocal);
    });

    const tRecipes = [
      RecipeModel(
        id: 1,
        name: 'Classic Margherita Pizza',
        ingredients: ['Pizza dough', 'Tomato sauce', 'Fresh mozzarella', 'Fresh basil'],
        instructions: ['Preheat oven', 'Roll out dough', 'Bake until golden'],
        prepTimeMinutes: 20,
        cookTimeMinutes: 15,
        servings: 4,
        difficulty: 'Easy',
        cuisine: 'Italian',
        mealType: ['Dinner'],
        image: 'https://cdn.dummyjson.com/recipe-images/1.webp',
        rating: 4.6,
      )
    ];

    test('getRecipes online fetches from remote and caches data', () async {
      when(() => mockRemote.getRecipes()).thenAnswer((_) async => tRecipes);
      when(() => mockLocal.cacheRecipes(tRecipes)).thenAnswer((_) async => {});

      final result = await repository.getRecipes();

      expect(result.isCached, isFalse);
      expect(result.recipes.first.name, contains('Margherita Pizza'));
      verify(() => mockLocal.cacheRecipes(tRecipes)).called(1);
    });

    test('getRecipes offline falls back to local cache', () async {
      when(() => mockRemote.getRecipes()).thenThrow(ServerException(message: 'Offline'));
      when(() => mockLocal.getCachedRecipes()).thenAnswer((_) async => tRecipes);

      final result = await repository.getRecipes();

      expect(result.isCached, isTrue);
      expect(result.recipes.first.id, 1);
      verify(() => mockLocal.getCachedRecipes()).called(1);
    });
  });
}
