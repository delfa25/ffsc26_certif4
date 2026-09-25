import 'package:flutter/material.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/get_recipes_usecase.dart';

enum RecipeState { initial, loading, loaded, error }

class RecipeProvider extends ChangeNotifier {
  final GetRecipesUseCase getRecipesUseCase;

  RecipeState _state = RecipeState.initial;
  List<Recipe> _recipes = [];
  bool _isCached = false;
  String? _errorMessage;

  RecipeProvider({required this.getRecipesUseCase});

  RecipeState get state => _state;
  List<Recipe> get recipes => _recipes;
  bool get isCached => _isCached;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRecipes({bool showLoading = true}) async {
    if (showLoading) {
      _state = RecipeState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await getRecipesUseCase();
      _recipes = result.recipes;
      _isCached = result.isCached;
      _state = RecipeState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('CacheException: ', '').replaceAll('Exception: ', '');
      _state = RecipeState.error;
    }
    notifyListeners();
  }
}
