import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<RecipesResult> getRecipes();
}
