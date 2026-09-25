import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<ProductsResult> call({String? query}) {
    return repository.getProducts(query: query);
  }
}
