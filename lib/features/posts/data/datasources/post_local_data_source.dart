import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/post_model.dart';

abstract class PostLocalDataSource {
  Future<void> cachePosts(List<PostModel> posts);
  Future<List<PostModel>> getCachedPosts();
}

/// Implémentation du cache local pour les Articles avec [Hive] (et fallback SharedPreferences).
class PostLocalDataSourceImpl implements PostLocalDataSource {
  final Box? box;
  final SharedPreferences? prefs;

  PostLocalDataSourceImpl({this.box, this.prefs});

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    try {
      final jsonList = posts.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      if (box != null && box!.isOpen) {
        await box!.put(AppConstants.keyPostsCache, jsonString);
      }
      if (prefs != null) {
        await prefs!.setString(AppConstants.keyPostsCache, jsonString);
      }
    } catch (e) {
      throw CacheException(message: 'Erreur de sauvegarde Hive des articles');
    }
  }

  @override
  Future<List<PostModel>> getCachedPosts() async {
    try {
      String? cachedData;
      if (box != null && box!.isOpen) {
        cachedData = box!.get(AppConstants.keyPostsCache)?.toString();
      }
      if (cachedData == null && prefs != null) {
        cachedData = prefs!.getString(AppConstants.keyPostsCache);
      }
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => PostModel.fromJson(item)).toList();
      }
      throw CacheException(message: 'Aucun article en cache');
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Erreur de lecture du cache Hive articles');
    }
  }
}
