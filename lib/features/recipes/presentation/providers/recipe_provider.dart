import 'package:flutter/material.dart';
import '../../../../core/network/network_error_handler.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/get_recipes_usecase.dart';

enum RecipeState { initial, loading, loaded, error }

class RecipeProvider extends ChangeNotifier {
  final GetRecipesUseCase getRecipesUseCase;

  RecipeState _state = RecipeState.initial;
  List<Recipe> _recipes = [];
  bool _isCached = false;
  String? _errorMessage;
  String? _userNotification;

  RecipeProvider({required this.getRecipesUseCase});

  RecipeState get state => _state;
  List<Recipe> get recipes => _recipes;
  bool get isCached => _isCached;
  bool get isOfflineMode => _isCached;
  String? get errorMessage => _errorMessage;
  String? get userNotification => _userNotification;

  Future<void> fetchRecipes({bool showLoading = true}) async {
    if (showLoading) {
      _state = RecipeState.loading;
      _errorMessage = null;
      _userNotification = null;
      notifyListeners();
    }

    try {
      final result = await getRecipesUseCase();
      _recipes = result.recipes;
      _isCached = result.isCached;
      if (result.isCached) {
        _userNotification = NetworkErrorHandler.getOfflineNotificationMessage(feature: 'Recettes');
      } else {
        _userNotification = null;
      }
      _state = RecipeState.loaded;
    } catch (e) {
      _errorMessage = NetworkErrorHandler.getErrorMessage(e);
      _state = RecipeState.error;
    }
    notifyListeners();
  }

  void clearNotification() {
    _userNotification = null;
    notifyListeners();
  }
}
