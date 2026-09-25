import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({String? query});
  Future<ProductModel> getProductById(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts({String? query}) async {
    try {
      final endpoint = (query != null && query.isNotEmpty)
          ? '/products/search?q=$query'
          : '/products';
      final response = await dio.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> productsJson = response.data['products'] ?? [];
        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Impossible de charger les produits');
      }
    } on DioException catch (e) {
      throw NetworkException(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await dio.get('/products/$id');
      if (response.statusCode == 200 && response.data != null) {
        return ProductModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Produit introuvable');
      }
    } catch (e) {
      throw ServerException(message: 'Erreur réseau lors de la récupération du produit');
    }
  }
}
