import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/recipe_model.dart';

abstract class RecipeLocalDataSource {
  Future<void> cacheRecipes(List<RecipeModel> recipes);
  Future<List<RecipeModel>> getCachedRecipes();
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  final SharedPreferences prefs;
  static const String keyRecipesCache = 'RECIPES_CACHE';

  RecipeLocalDataSourceImpl({required this.prefs});

  @override
  Future<void> cacheRecipes(List<RecipeModel> recipes) async {
    try {
      final jsonList = recipes.map((r) => r.toJson()).toList();
      await prefs.setString(keyRecipesCache, jsonEncode(jsonList));
    } catch (e) {
      throw CacheException(message: 'Erreur de sauvegarde des recettes en cache');
    }
  }

  @override
  Future<List<RecipeModel>> getCachedRecipes() async {
    final cachedData = prefs.getString(keyRecipesCache);
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => RecipeModel.fromJson(item)).toList();
      } catch (e) {
        throw CacheException(message: 'Erreur de lecture des recettes en cache');
      }
    } else {
      throw CacheException(message: 'Aucune recette en cache');
    }
  }
}
