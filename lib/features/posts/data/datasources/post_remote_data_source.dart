import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await dio.get('/posts');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> postsJson = response.data['posts'] ?? [];
        return postsJson.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Impossible de charger les articles');
      }
    } on DioException catch (e) {
      throw NetworkException(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
