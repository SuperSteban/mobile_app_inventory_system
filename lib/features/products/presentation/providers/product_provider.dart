import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/use_cases/add_product_case.dart';
import '../../domain/use_cases/get_products_case.dart';

class ProductProvider extends ChangeNotifier {
  final AddProductCase addProductCase;
  final GetProductsCase getProductsCase;

  ProductProvider({
    required this.addProductCase,
    required this.getProductsCase,
  });

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> addProduct(Product product) async {
    _setLoading(true);
    try {
      await addProductCase(product);
      _products.add(product); // opcional: reflejarlo localmente
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> fetchProducts() async {
    _setLoading(true);
    try {
      final result = await getProductsCase();
      _products = result;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
