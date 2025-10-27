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

  List<Product> _allProducts = []; // 🔹 Lista completa
  List<Product> _products = []; // 🔹 Lista filtrada
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createProduct(Product product) async {
    await addProductCase(product);
    _allProducts.add(product);
    _products.add(product);
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allProducts = await getProductsCase();
      _products = List.from(_allProducts); // 🔹 Inicializa con todos
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

  void filterProducts({String? storage, String? category}) {
    _products = _allProducts.where((p) {
      final matchStorage = storage == null || p.storageLocation == storage;
      final matchCategory = category == null || p.category == category;
      return matchStorage && matchCategory;
    }).toList();
    notifyListeners();
  }
}
