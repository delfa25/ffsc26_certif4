import 'package:flutter/material.dart';
import '../../../../core/network/network_error_handler.dart';
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
  String? _userNotification;
  String _searchQuery = '';

  ProductProvider({
    required this.getProductsUseCase,
    required this.getProductDetailsUseCase,
  });

  ProductState get state => _state;
  List<Product> get products => _products;
  bool get isCached => _isCached;
  bool get isOfflineMode => _isCached;
  String? get errorMessage => _errorMessage;
  String? get userNotification => _userNotification;
  String get searchQuery => _searchQuery;

  Future<void> fetchProducts({String? query, bool showLoading = true}) async {
    if (query != null) {
      _searchQuery = query;
    }

    if (showLoading) {
      _state = ProductState.loading;
      _errorMessage = null;
      _userNotification = null;
      notifyListeners();
    }

    try {
      final result = await getProductsUseCase(query: _searchQuery);
      _products = result.products;
      _isCached = result.isCached;
      if (result.isCached) {
        _userNotification = NetworkErrorHandler.getOfflineNotificationMessage(feature: 'Produits');
      } else {
        _userNotification = null;
      }
      _state = ProductState.loaded;
    } catch (e) {
      _errorMessage = NetworkErrorHandler.getErrorMessage(e);
      _state = ProductState.error;
    }
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    fetchProducts(query: query, showLoading: false);
  }

  void clearNotification() {
    _userNotification = null;
    notifyListeners();
  }
}
