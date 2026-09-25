import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> getRecipes();
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final Dio dio;

  RecipeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<RecipeModel>> getRecipes() async {
    try {
      final response = await dio.get('/recipes');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> jsonList = response.data['recipes'] ?? [];
        return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Impossible de charger les recettes');
      }
    } on DioException catch (e) {
      throw NetworkException(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
