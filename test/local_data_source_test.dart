import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ffsc26_certif4/core/errors/exceptions.dart';
import 'package:ffsc26_certif4/core/utils/constants.dart';
import 'package:ffsc26_certif4/features/products/data/datasources/product_local_data_source.dart';
import 'package:ffsc26_certif4/features/products/data/models/product_model.dart';
import 'package:ffsc26_certif4/features/posts/data/datasources/post_local_data_source.dart';
import 'package:ffsc26_certif4/features/posts/data/models/post_model.dart';
import 'package:ffsc26_certif4/features/recipes/data/datasources/recipe_local_data_source.dart';
import 'package:ffsc26_certif4/features/recipes/data/models/recipe_model.dart';

class MockBox extends Mock implements Box {}

void main() {
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    when(() => mockBox.isOpen).thenReturn(true);
  });

  group('ProductLocalDataSourceImpl (Hive Data Access)', () {
    late ProductLocalDataSourceImpl dataSource;

    setUp(() {
      dataSource = ProductLocalDataSourceImpl(box: mockBox);
    });

    const tProducts = [
      ProductModel(
        id: 1,
        title: 'Essence Mascara',
        description: 'Test description',
        price: 9.99,
        rating: 4.9,
        brand: 'Essence',
        category: 'beauty',
        thumbnail: '',
        images: [],
        stock: 5,
      ),
    ];

    test('devrait sauvegarder les produits dans la boîte Hive', () async {
      when(() => mockBox.put(AppConstants.keyProductsCache, any()))
          .thenAnswer((_) async => {});

      await dataSource.cacheProducts(tProducts);

      verify(() => mockBox.put(AppConstants.keyProductsCache, any())).called(1);
    });

    test('devrait lire les produits depuis la boîte Hive', () async {
      final jsonString = jsonEncode(tProducts.map((e) => e.toJson()).toList());
      when(() => mockBox.get(AppConstants.keyProductsCache)).thenReturn(jsonString);

      final result = await dataSource.getCachedProducts();

      expect(result.length, 1);
      expect(result.first.title, 'Essence Mascara');
    });

    test('devrait lever CacheException si la boîte Hive est vide', () async {
      when(() => mockBox.get(AppConstants.keyProductsCache)).thenReturn(null);

      expect(() => dataSource.getCachedProducts(), throwsA(isA<CacheException>()));
    });
  });

  group('PostLocalDataSourceImpl (Hive Data Access)', () {
    late PostLocalDataSourceImpl dataSource;

    setUp(() {
      dataSource = PostLocalDataSourceImpl(box: mockBox);
    });

    const tPosts = [
      PostModel(
        id: 1,
        title: 'Test Post',
        body: 'Body test',
        userId: 1,
        tags: ['flutter'],
        views: 10,
        likes: 5,
        dislikes: 0,
      ),
    ];

    test('devrait sauvegarder les articles dans la boîte Hive', () async {
      when(() => mockBox.put(AppConstants.keyPostsCache, any()))
          .thenAnswer((_) async => {});

      await dataSource.cachePosts(tPosts);

      verify(() => mockBox.put(AppConstants.keyPostsCache, any())).called(1);
    });

    test('devrait lire les articles depuis la boîte Hive', () async {
      final jsonString = jsonEncode(tPosts.map((e) => e.toJson()).toList());
      when(() => mockBox.get(AppConstants.keyPostsCache)).thenReturn(jsonString);

      final result = await dataSource.getCachedPosts();

      expect(result.length, 1);
      expect(result.first.title, 'Test Post');
    });
  });

  group('RecipeLocalDataSourceImpl (Hive Data Access)', () {
    late RecipeLocalDataSourceImpl dataSource;

    setUp(() {
      dataSource = RecipeLocalDataSourceImpl(box: mockBox);
    });

    const tRecipes = [
      RecipeModel(
        id: 1,
        name: 'Pizza Margherita',
        ingredients: ['Mozzarella', 'Tomate'],
        instructions: ['Cuire'],
        prepTimeMinutes: 10,
        cookTimeMinutes: 15,
        servings: 2,
        difficulty: 'Facile',
        cuisine: 'Italienne',
        mealType: ['Dinner'],
        image: '',
        rating: 4.8,
      ),
    ];

    test('devrait sauvegarder les recettes dans la boîte Hive', () async {
      when(() => mockBox.put(RecipeLocalDataSourceImpl.keyRecipesCache, any()))
          .thenAnswer((_) async => {});

      await dataSource.cacheRecipes(tRecipes);

      verify(() => mockBox.put(RecipeLocalDataSourceImpl.keyRecipesCache, any())).called(1);
    });

    test('devrait lire les recettes depuis la boîte Hive', () async {
      final jsonString = jsonEncode(tRecipes.map((e) => e.toJson()).toList());
      when(() => mockBox.get(RecipeLocalDataSourceImpl.keyRecipesCache)).thenReturn(jsonString);

      final result = await dataSource.getCachedRecipes();

      expect(result.length, 1);
      expect(result.first.name, 'Pizza Margherita');
    });
  });
}
