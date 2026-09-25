import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_data_source.dart';
import '../datasources/recipe_remote_data_source.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remoteDataSource;
  final RecipeLocalDataSource localDataSource;

  RecipeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<RecipesResult> getRecipes() async {
    try {
      final remoteRecipes = await remoteDataSource.getRecipes();
      await localDataSource.cacheRecipes(remoteRecipes);
      return RecipesResult(recipes: remoteRecipes, isCached: false);
    } catch (_) {
      try {
        final cachedRecipes = await localDataSource.getCachedRecipes();
        return RecipesResult(recipes: cachedRecipes, isCached: true);
      } on CacheException catch (e) {
        throw CacheException(message: e.message);
      } catch (e) {
        throw CacheException(message: 'Réseau indisponible et aucun cache recettes disponible.');
      }
    }
  }
}
