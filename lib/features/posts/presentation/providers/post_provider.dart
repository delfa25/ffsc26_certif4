import 'package:flutter/material.dart';
import '../../../../core/network/network_error_handler.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/get_posts_usecase.dart';

enum PostState { initial, loading, loaded, error }

class PostProvider extends ChangeNotifier {
  final GetPostsUseCase getPostsUseCase;

  PostState _state = PostState.initial;
  List<Post> _posts = [];
  bool _isCached = false;
  String? _errorMessage;
  String? _userNotification;

  PostProvider({required this.getPostsUseCase});

  PostState get state => _state;
  List<Post> get posts => _posts;
  bool get isCached => _isCached;
  bool get isOfflineMode => _isCached;
  String? get errorMessage => _errorMessage;
  String? get userNotification => _userNotification;

  Future<void> fetchPosts({bool showLoading = true}) async {
    if (showLoading) {
      _state = PostState.loading;
      _errorMessage = null;
      _userNotification = null;
      notifyListeners();
    }

    try {
      final result = await getPostsUseCase();
      _posts = result.posts;
      _isCached = result.isCached;
      if (result.isCached) {
        _userNotification = NetworkErrorHandler.getOfflineNotificationMessage(feature: 'Articles');
      } else {
        _userNotification = null;
      }
      _state = PostState.loaded;
    } catch (e) {
      _errorMessage = NetworkErrorHandler.getErrorMessage(e);
      _state = PostState.error;
    }
    notifyListeners();
  }

  void clearNotification() {
    _userNotification = null;
    notifyListeners();
  }
}
