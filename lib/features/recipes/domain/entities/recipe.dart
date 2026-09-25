class Recipe {
  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final double rating;
  final String image;
  final List<String> mealType;

  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    required this.rating,
    required this.image,
    required this.mealType,
  });
}

class RecipesResult {
  final List<Recipe> recipes;
  final bool isCached;

  const RecipesResult({
    required this.recipes,
    required this.isCached,
  });
}
