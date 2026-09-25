import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/get_posts_usecase.dart';

enum PostState { initial, loading, loaded, error }

class PostProvider extends ChangeNotifier {
  final GetPostsUseCase getPostsUseCase;

  PostState _state = PostState.initial;
  List<Post> _posts = [];
  bool _isCached = false;
  String? _errorMessage;

  PostProvider({required this.getPostsUseCase});

  PostState get state => _state;
  List<Post> get posts => _posts;
  bool get isCached => _isCached;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPosts({bool showLoading = true}) async {
    if (showLoading) {
      _state = PostState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await getPostsUseCase();
      _posts = result.posts;
      _isCached = result.isCached;
      _state = PostState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('CacheException: ', '').replaceAll('Exception: ', '');
      _state = PostState.error;
    }
    notifyListeners();
  }
}
