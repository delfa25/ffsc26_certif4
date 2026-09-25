import '../entities/product.dart';

abstract class ProductRepository {
  Future<ProductsResult> getProducts({String? query});
  Future<Product> getProductById(int id);
}
