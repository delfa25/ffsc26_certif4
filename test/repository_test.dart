import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ffsc26_certif4/core/errors/exceptions.dart';
import 'package:ffsc26_certif4/core/errors/failures.dart';
import 'package:ffsc26_certif4/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ffsc26_certif4/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ffsc26_certif4/features/auth/data/models/user_model.dart';
import 'package:ffsc26_certif4/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ffsc26_certif4/features/products/data/datasources/product_local_data_source.dart';
import 'package:ffsc26_certif4/features/products/data/datasources/product_remote_data_source.dart';
import 'package:ffsc26_certif4/features/products/data/models/product_model.dart';
import 'package:ffsc26_certif4/features/products/data/repositories/product_repository_impl.dart';
import 'package:ffsc26_certif4/features/posts/data/datasources/post_local_data_source.dart';
import 'package:ffsc26_certif4/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:ffsc26_certif4/features/posts/data/models/post_model.dart';
import 'package:ffsc26_certif4/features/posts/data/repositories/post_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockProductRemoteDataSource extends Mock implements ProductRemoteDataSource {}
class MockProductLocalDataSource extends Mock implements ProductLocalDataSource {}
class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}
class MockPostLocalDataSource extends Mock implements PostLocalDataSource {}

void main() {
  group('AuthRepositoryImpl Unit Tests', () {
    late AuthRepositoryImpl repository;
    late MockAuthRemoteDataSource mockRemote;
    late MockAuthLocalDataSource mockLocal;

    setUp(() {
      mockRemote = MockAuthRemoteDataSource();
      mockLocal = MockAuthLocalDataSource();
      repository = AuthRepositoryImpl(remoteDataSource: mockRemote, localDataSource: mockLocal);
    });

    const tUser = UserModel(
      id: 1,
      username: 'emilys',
      email: 'emily@dummy.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'female',
      image: '',
      accessToken: 'token123',
    );

    test('login success saves user to local data source', () async {
      when(() => mockRemote.login('emilys', 'pass')).thenAnswer((_) async => tUser);
      when(() => mockLocal.saveUser(tUser)).thenAnswer((_) async => {});

      final user = await repository.login('emilys', 'pass');

      expect(user.username, 'emilys');
      verify(() => mockLocal.saveUser(tUser)).called(1);
    });

    test('login server error throws AuthFailure', () async {
      when(() => mockRemote.login('bad', 'bad')).thenThrow(ServerException(message: 'Error'));

      expect(() => repository.login('bad', 'bad'), throwsA(isA<AuthFailure>()));
    });
  });

  group('ProductRepositoryImpl Unit Tests', () {
    late ProductRepositoryImpl repository;
    late MockProductRemoteDataSource mockRemote;
    late MockProductLocalDataSource mockLocal;

    setUp(() {
      mockRemote = MockProductRemoteDataSource();
      mockLocal = MockProductLocalDataSource();
      repository = ProductRepositoryImpl(remoteDataSource: mockRemote, localDataSource: mockLocal);
    });

    const tProducts = [
      ProductModel(
        id: 10,
        title: 'Smartphone',
        description: 'Great phone',
        price: 499.99,
        rating: 4.8,
        brand: 'TechBrand',
        category: 'smartphones',
        thumbnail: '',
        images: [],
        stock: 10,
      )
    ];

    test('getProducts online fetches from remote and caches data', () async {
      when(() => mockRemote.getProducts(query: null)).thenAnswer((_) async => tProducts);
      when(() => mockLocal.cacheProducts(tProducts)).thenAnswer((_) async => {});

      final result = await repository.getProducts();

      expect(result.isCached, isFalse);
      expect(result.products.length, 1);
      verify(() => mockLocal.cacheProducts(tProducts)).called(1);
    });

    test('getProducts offline falls back to local cache', () async {
      when(() => mockRemote.getProducts(query: null)).thenThrow(NetworkException());
      when(() => mockLocal.getCachedProducts()).thenAnswer((_) async => tProducts);

      final result = await repository.getProducts();

      expect(result.isCached, isTrue);
      expect(result.products.first.id, 10);
      verify(() => mockLocal.getCachedProducts()).called(1);
    });
  });

  group('PostRepositoryImpl Unit Tests', () {
    late PostRepositoryImpl repository;
    late MockPostRemoteDataSource mockRemote;
    late MockPostLocalDataSource mockLocal;

    setUp(() {
      mockRemote = MockPostRemoteDataSource();
      mockLocal = MockPostLocalDataSource();
      repository = PostRepositoryImpl(remoteDataSource: mockRemote, localDataSource: mockLocal);
    });

    const tPosts = [
      PostModel(
        id: 101,
        title: 'Flutter Clean Architecture',
        body: 'Building scalable flutter apps...',
        userId: 1,
        tags: ['flutter', 'dart'],
        views: 120,
        likes: 50,
        dislikes: 2,
      )
    ];

    test('getPosts online fetches from remote and caches data', () async {
      when(() => mockRemote.getPosts()).thenAnswer((_) async => tPosts);
      when(() => mockLocal.cachePosts(tPosts)).thenAnswer((_) async => {});

      final result = await repository.getPosts();

      expect(result.isCached, isFalse);
      expect(result.posts.first.id, 101);
      verify(() => mockLocal.cachePosts(tPosts)).called(1);
    });

    test('getPosts offline falls back to local cache', () async {
      when(() => mockRemote.getPosts()).thenThrow(ServerException(message: 'Offline'));
      when(() => mockLocal.getCachedPosts()).thenAnswer((_) async => tPosts);

      final result = await repository.getPosts();

      expect(result.isCached, isTrue);
      expect(result.posts.first.id, 101);
      verify(() => mockLocal.getCachedPosts()).called(1);
    });
  });
}
