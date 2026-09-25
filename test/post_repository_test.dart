import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ffsc26_certif4/core/errors/exceptions.dart';
import 'package:ffsc26_certif4/features/posts/data/datasources/post_local_data_source.dart';
import 'package:ffsc26_certif4/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:ffsc26_certif4/features/posts/data/models/post_model.dart';
import 'package:ffsc26_certif4/features/posts/data/repositories/post_repository_impl.dart';

class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}
class MockPostLocalDataSource extends Mock implements PostLocalDataSource {}

void main() {
  late PostRepositoryImpl repository;
  late MockPostRemoteDataSource mockRemoteDataSource;
  late MockPostLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockPostRemoteDataSource();
    mockLocalDataSource = MockPostLocalDataSource();
    repository = PostRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tPostList = [
    PostModel(
      id: 1,
      title: 'His mother had always taught him',
      body: 'His mother had always taught him that his voice was important...',
      userId: 121,
      tags: ['history', 'american', 'crime'],
      views: 305,
      likes: 192,
      dislikes: 25,
    )
  ];

  group('PostRepositoryImpl', () {
    test('devrait retourner les articles distants et les sauvegarder en cache', () async {
      when(() => mockRemoteDataSource.getPosts())
          .thenAnswer((_) async => tPostList);
      when(() => mockLocalDataSource.cachePosts(tPostList))
          .thenAnswer((_) async => {});

      final result = await repository.getPosts();

      expect(result.isCached, isFalse);
      expect(result.posts.length, equals(1));
      expect(result.posts.first.title, contains('His mother'));
      verify(() => mockRemoteDataSource.getPosts()).called(1);
      verify(() => mockLocalDataSource.cachePosts(tPostList)).called(1);
    });

    test('devrait charger les articles depuis le cache lors d\'une panne réseau', () async {
      when(() => mockRemoteDataSource.getPosts())
          .thenThrow(ServerException(message: 'Server error'));
      when(() => mockLocalDataSource.getCachedPosts())
          .thenAnswer((_) async => tPostList);

      final result = await repository.getPosts();

      expect(result.isCached, isTrue);
      expect(result.posts.first.id, equals(1));
      verify(() => mockLocalDataSource.getCachedPosts()).called(1);
    });
  });
}
