import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/recipe_model.dart';

abstract class RecipeLocalDataSource {
  Future<void> cacheRecipes(List<RecipeModel> recipes);
  Future<List<RecipeModel>> getCachedRecipes();
}

/// Implémentation du cache local pour les Recettes avec [Hive] (et fallback SharedPreferences).
class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  final Box? box;
  final SharedPreferences? prefs;
  static const String keyRecipesCache = 'RECIPES_CACHE';

  RecipeLocalDataSourceImpl({this.box, this.prefs});

  @override
  Future<void> cacheRecipes(List<RecipeModel> recipes) async {
    try {
      final jsonList = recipes.map((r) => r.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      if (box != null && box!.isOpen) {
        await box!.put(keyRecipesCache, jsonString);
      }
      if (prefs != null) {
        await prefs!.setString(keyRecipesCache, jsonString);
      }
    } catch (e) {
      throw CacheException(message: 'Erreur de sauvegarde Hive des recettes');
    }
  }

  @override
  Future<List<RecipeModel>> getCachedRecipes() async {
    try {
      String? cachedData;
      if (box != null && box!.isOpen) {
        cachedData = box!.get(keyRecipesCache)?.toString();
      }
      if (cachedData == null && prefs != null) {
        cachedData = prefs!.getString(keyRecipesCache);
      }
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => RecipeModel.fromJson(item)).toList();
      }
      throw CacheException(message: 'Aucune recette en cache');
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Erreur de lecture du cache Hive recettes');
    }
  }
}
