import '../entities/post.dart';

abstract class PostRepository {
  Future<PostsResult> getPosts();
}
