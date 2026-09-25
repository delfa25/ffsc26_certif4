import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ffsc26_certif4/core/errors/exceptions.dart';
import 'package:ffsc26_certif4/features/products/data/datasources/product_local_data_source.dart';
import 'package:ffsc26_certif4/features/products/data/datasources/product_remote_data_source.dart';
import 'package:ffsc26_certif4/features/products/data/models/product_model.dart';
import 'package:ffsc26_certif4/features/products/data/repositories/product_repository_impl.dart';

class MockProductRemoteDataSource extends Mock implements ProductRemoteDataSource {}
class MockProductLocalDataSource extends Mock implements ProductLocalDataSource {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;
  late MockProductLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    mockLocalDataSource = MockProductLocalDataSource();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tProduct1 = ProductModel(
    id: 1,
    title: 'Essence Mascara Lash Princess',
    description: 'Mascara de qualité',
    price: 9.99,
    rating: 4.94,
    brand: 'Essence',
    category: 'beauty',
    thumbnail: 'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png',
    images: [],
    stock: 5,
  );

  const tProduct2 = ProductModel(
    id: 2,
    title: 'Eyeshadow Palette with Mirror',
    description: 'Palette fards à paupières',
    price: 19.99,
    rating: 4.5,
    brand: 'Glamour',
    category: 'beauty',
    thumbnail: 'https://cdn.dummyjson.com/products/images/beauty/eyeshadow.png',
    images: [],
    stock: 8,
  );

  const tProductList = [tProduct1, tProduct2];

  group('ProductRepositoryImpl - getProducts', () {
    test('devrait retourner les produits distants et mettre en cache si en ligne', () async {
      when(() => mockRemoteDataSource.getProducts(query: null))
          .thenAnswer((_) async => tProductList);
      when(() => mockLocalDataSource.cacheProducts(tProductList))
          .thenAnswer((_) async => {});

      final result = await repository.getProducts();

      expect(result.isCached, isFalse);
      expect(result.products.length, equals(2));
      expect(result.products.first.title, equals('Essence Mascara Lash Princess'));
      verify(() => mockRemoteDataSource.getProducts(query: null)).called(1);
      verify(() => mockLocalDataSource.cacheProducts(tProductList)).called(1);
    });

    test('devrait rechercher les produits en ligne sans écraser le cache global', () async {
      when(() => mockRemoteDataSource.getProducts(query: 'mascara'))
          .thenAnswer((_) async => [tProduct1]);

      final result = await repository.getProducts(query: 'mascara');

      expect(result.isCached, isFalse);
      expect(result.products.length, equals(1));
      verify(() => mockRemoteDataSource.getProducts(query: 'mascara')).called(1);
      verifyNever(() => mockLocalDataSource.cacheProducts(any()));
    });

    test('devrait retourner les produits du cache local en mode hors-ligne', () async {
      when(() => mockRemoteDataSource.getProducts(query: null))
          .thenThrow(NetworkException(message: 'Pas de réseau'));
      when(() => mockLocalDataSource.getCachedProducts())
          .thenAnswer((_) async => tProductList);

      final result = await repository.getProducts();

      expect(result.isCached, isTrue);
      expect(result.products.length, equals(2));
      expect(result.products.first.id, equals(1));
      verify(() => mockLocalDataSource.getCachedProducts()).called(1);
    });

    test('devrait filtrer les produits en cache par requête en mode hors-ligne', () async {
      when(() => mockRemoteDataSource.getProducts(query: 'mascara'))
          .thenThrow(NetworkException(message: 'Hors-ligne'));
      when(() => mockLocalDataSource.getCachedProducts())
          .thenAnswer((_) async => tProductList);

      final result = await repository.getProducts(query: 'mascara');

      expect(result.isCached, isTrue);
      expect(result.products.length, equals(1));
      expect(result.products.first.title, contains('Mascara'));
    });

    test('devrait lever CacheException en mode hors-ligne si aucun cache n\'est disponible', () async {
      when(() => mockRemoteDataSource.getProducts(query: null))
          .thenThrow(NetworkException(message: 'Pas de réseau'));
      when(() => mockLocalDataSource.getCachedProducts())
          .thenThrow(CacheException(message: 'Aucun cache'));

      expect(
        () => repository.getProducts(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('ProductRepositoryImpl - getProductById', () {
    test('devrait retourner le produit distant par ID en ligne', () async {
      when(() => mockRemoteDataSource.getProductById(1))
          .thenAnswer((_) async => tProduct1);

      final result = await repository.getProductById(1);

      expect(result.id, equals(1));
      expect(result.title, equals(tProduct1.title));
      verify(() => mockRemoteDataSource.getProductById(1)).called(1);
    });

    test('devrait récupérer le produit depuis le cache local lors d\'une panne réseau', () async {
      when(() => mockRemoteDataSource.getProductById(1))
          .thenThrow(NetworkException(message: 'Pas de réseau'));
      when(() => mockLocalDataSource.getCachedProducts())
          .thenAnswer((_) async => tProductList);

      final result = await repository.getProductById(1);

      expect(result.id, equals(1));
      expect(result.title, equals(tProduct1.title));
      verify(() => mockLocalDataSource.getCachedProducts()).called(1);
    });

    test('devrait lever CacheException si le produit n\'est pas dans le cache en mode hors-ligne', () async {
      when(() => mockRemoteDataSource.getProductById(99))
          .thenThrow(NetworkException(message: 'Pas de réseau'));
      when(() => mockLocalDataSource.getCachedProducts())
          .thenAnswer((_) async => tProductList);

      expect(
        () => repository.getProductById(99),
        throwsA(isA<CacheException>()),
      );
    });
  });
}
