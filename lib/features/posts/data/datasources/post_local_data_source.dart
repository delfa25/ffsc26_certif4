import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/post_model.dart';

abstract class PostLocalDataSource {
  Future<void> cachePosts(List<PostModel> posts);
  Future<List<PostModel>> getCachedPosts();
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final SharedPreferences prefs;

  PostLocalDataSourceImpl({required this.prefs});

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    try {
      final jsonList = posts.map((p) => p.toJson()).toList();
      await prefs.setString(AppConstants.keyPostsCache, jsonEncode(jsonList));
    } catch (e) {
      throw CacheException(message: 'Erreur de sauvegarde des articles en cache');
    }
  }

  @override
  Future<List<PostModel>> getCachedPosts() async {
    final cachedData = prefs.getString(AppConstants.keyPostsCache);
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => PostModel.fromJson(item)).toList();
      } catch (e) {
        throw CacheException(message: 'Erreur de lecture des articles en cache');
      }
    } else {
      throw CacheException(message: 'Aucun article en cache');
    }
  }
}
