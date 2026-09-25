import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_details_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';

enum ProductState { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final GetProductDetailsUseCase getProductDetailsUseCase;

  ProductState _state = ProductState.initial;
  List<Product> _products = [];
  bool _isCached = false;
  String? _errorMessage;
  String _searchQuery = '';

  ProductProvider({
    required this.getProductsUseCase,
    required this.getProductDetailsUseCase,
  });

  ProductState get state => _state;
  List<Product> get products => _products;
  bool get isCached => _isCached;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> fetchProducts({String? query, bool showLoading = true}) async {
    if (query != null) {
      _searchQuery = query;
    }

    if (showLoading) {
      _state = ProductState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await getProductsUseCase(query: _searchQuery);
      _products = result.products;
      _isCached = result.isCached;
      _state = ProductState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('CacheException: ', '').replaceAll('Exception: ', '');
      _state = ProductState.error;
    }
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    fetchProducts(query: query, showLoading: false);
  }
}
