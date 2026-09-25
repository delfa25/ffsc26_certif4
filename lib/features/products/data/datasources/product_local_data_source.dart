import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>> getCachedProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final SharedPreferences prefs;

  ProductLocalDataSourceImpl({required this.prefs});

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final jsonList = products.map((p) => p.toJson()).toList();
      await prefs.setString(AppConstants.keyProductsCache, jsonEncode(jsonList));
    } catch (e) {
      throw CacheException(message: 'Erreur de sauvegarde des produits en cache');
    }
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final cachedData = prefs.getString(AppConstants.keyProductsCache);
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => ProductModel.fromJson(item)).toList();
      } catch (e) {
        throw CacheException(message: 'Erreur de lecture du cache produits');
      }
    } else {
      throw CacheException(message: 'Aucun produit en cache');
    }
  }
}
