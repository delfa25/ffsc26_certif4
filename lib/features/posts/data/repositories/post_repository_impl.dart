import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_local_data_source.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostLocalDataSource localDataSource;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<PostsResult> getPosts() async {
    try {
      final remotePosts = await remoteDataSource.getPosts();
      await localDataSource.cachePosts(remotePosts);
      return PostsResult(posts: remotePosts, isCached: false);
    } catch (_) {
      try {
        final cachedPosts = await localDataSource.getCachedPosts();
        return PostsResult(posts: cachedPosts, isCached: true);
      } on CacheException catch (e) {
        throw CacheException(message: e.message);
      } catch (e) {
        throw CacheException(message: 'Réseau indisponible et aucun cache trouvé.');
      }
    }
  }
}
