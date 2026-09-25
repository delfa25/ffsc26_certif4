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

  const tProductList = [
    ProductModel(
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
    )
  ];

  group('ProductRepositoryImpl', () {
    test('devrait retourner les produits distants et mettre en cache si en ligne', () async {
      when(() => mockRemoteDataSource.getProducts(query: null))
          .thenAnswer((_) async => tProductList);
      when(() => mockLocalDataSource.cacheProducts(tProductList))
          .thenAnswer((_) async => {});

      final result = await repository.getProducts();

      expect(result.isCached, isFalse);
      expect(result.products.length, equals(1));
      expect(result.products.first.title, equals('Essence Mascara Lash Princess'));
      verify(() => mockRemoteDataSource.getProducts(query: null)).called(1);
      verify(() => mockLocalDataSource.cacheProducts(tProductList)).called(1);
    });

    test('devrait retourner les produits du cache local en mode hors-ligne', () async {
      when(() => mockRemoteDataSource.getProducts(query: null))
          .thenThrow(NetworkException(message: 'Pas de réseau'));
      when(() => mockLocalDataSource.getCachedProducts())
          .thenAnswer((_) async => tProductList);

      final result = await repository.getProducts();

      expect(result.isCached, isTrue);
      expect(result.products.length, equals(1));
      expect(result.products.first.id, equals(1));
      verify(() => mockLocalDataSource.getCachedProducts()).called(1);
    });
  });
}
