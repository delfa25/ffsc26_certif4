import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>> getCachedProducts();
}

/// Implémentation du cache local pour les Produits avec [Hive] (et fallback SharedPreferences).
class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box? box;
  final SharedPreferences? prefs;

  ProductLocalDataSourceImpl({this.box, this.prefs});

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final jsonList = products.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      if (box != null && box!.isOpen) {
        await box!.put(AppConstants.keyProductsCache, jsonString);
      }
      if (prefs != null) {
        await prefs!.setString(AppConstants.keyProductsCache, jsonString);
      }
    } catch (e) {
      throw CacheException(message: 'Erreur de sauvegarde des produits en cache Hive');
    }
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      String? cachedData;
      if (box != null && box!.isOpen) {
        cachedData = box!.get(AppConstants.keyProductsCache)?.toString();
      }
      if (cachedData == null && prefs != null) {
        cachedData = prefs!.getString(AppConstants.keyProductsCache);
      }
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => ProductModel.fromJson(item)).toList();
      }
      throw CacheException(message: 'Aucun produit en cache');
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Erreur de lecture du cache produits');
    }
  }
}
