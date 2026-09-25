import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ffsc26_certif4/core/errors/exceptions.dart';
import 'package:ffsc26_certif4/features/recipes/data/datasources/recipe_local_data_source.dart';
import 'package:ffsc26_certif4/features/recipes/data/datasources/recipe_remote_data_source.dart';
import 'package:ffsc26_certif4/features/recipes/data/models/recipe_model.dart';
import 'package:ffsc26_certif4/features/recipes/data/repositories/recipe_repository_impl.dart';

class MockRecipeRemoteDataSource extends Mock implements RecipeRemoteDataSource {}
class MockRecipeLocalDataSource extends Mock implements RecipeLocalDataSource {}

void main() {
  late RecipeRepositoryImpl repository;
  late MockRecipeRemoteDataSource mockRemoteDataSource;
  late MockRecipeLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockRecipeRemoteDataSource();
    mockLocalDataSource = MockRecipeLocalDataSource();
    repository = RecipeRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tRecipeList = [
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

  group('RecipeRepositoryImpl - getRecipes', () {
    test('devrait retourner les recettes distantes et les sauvegarder en cache', () async {
      when(() => mockRemoteDataSource.getRecipes())
          .thenAnswer((_) async => tRecipeList);
      when(() => mockLocalDataSource.cacheRecipes(tRecipeList))
          .thenAnswer((_) async => {});

      final result = await repository.getRecipes();

      expect(result.isCached, isFalse);
      expect(result.recipes.length, equals(1));
      expect(result.recipes.first.name, contains('Margherita Pizza'));
      verify(() => mockRemoteDataSource.getRecipes()).called(1);
      verify(() => mockLocalDataSource.cacheRecipes(tRecipeList)).called(1);
    });

    test('devrait basculer vers le cache local en cas de panne réseau', () async {
      when(() => mockRemoteDataSource.getRecipes())
          .thenThrow(ServerException(message: 'Server unreachable'));
      when(() => mockLocalDataSource.getCachedRecipes())
          .thenAnswer((_) async => tRecipeList);

      final result = await repository.getRecipes();

      expect(result.isCached, isTrue);
      expect(result.recipes.first.id, equals(1));
      verify(() => mockLocalDataSource.getCachedRecipes()).called(1);
    });

    test('devrait lever CacheException si le réseau et le cache échouent tous les deux', () async {
      when(() => mockRemoteDataSource.getRecipes())
          .thenThrow(ServerException(message: 'Server error'));
      when(() => mockLocalDataSource.getCachedRecipes())
          .thenThrow(CacheException(message: 'Cache vide'));

      expect(
        () => repository.getRecipes(),
        throwsA(isA<CacheException>()),
      );
    });
  });
}
