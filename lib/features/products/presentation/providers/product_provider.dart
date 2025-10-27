import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/use_cases/add_product_case.dart';
import '../../domain/use_cases/get_products_case.dart';
import '../../domain/repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final AddProductCase addProductCase;
  final GetProductsCase getProductsCase;
  final ProductRepository repository;

  ProductProvider({
    required this.addProductCase,
    required this.getProductsCase,
    required this.repository,
  });

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createProduct(Product product) async {
    await addProductCase(product);
    _products.add(product);
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await getProductsCase();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> isDuplicateCode(String codeProduct) async {
    return await repository.existsCodeProduct(codeProduct);
  }
}
