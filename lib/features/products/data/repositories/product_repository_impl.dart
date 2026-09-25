import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<ProductsResult> getProducts({String? query}) async {
    try {
      final remoteProducts = await remoteDataSource.getProducts(query: query);
      if (query == null || query.isEmpty) {
        await localDataSource.cacheProducts(remoteProducts);
      }
      return ProductsResult(products: remoteProducts, isCached: false);
    } catch (_) {
      try {
        final cachedProducts = await localDataSource.getCachedProducts();
        if (query != null && query.isNotEmpty) {
          final filtered = cachedProducts
              .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
          return ProductsResult(products: filtered, isCached: true);
        }
        return ProductsResult(products: cachedProducts, isCached: true);
      } on CacheException catch (e) {
        throw CacheException(message: e.message);
      } catch (e) {
        throw CacheException(message: 'Réseau indisponible et aucun cache trouvé.');
      }
    }
  }

  @override
  Future<Product> getProductById(int id) async {
    try {
      return await remoteDataSource.getProductById(id);
    } catch (_) {
      try {
        final cached = await localDataSource.getCachedProducts();
        return cached.firstWhere(
          (p) => p.id == id,
          orElse: () => throw CacheException(message: 'Produit hors-ligne non trouvé en cache'),
        );
      } catch (e) {
        throw CacheException(message: 'Impossible de charger le détail du produit');
      }
    }
  }
}
