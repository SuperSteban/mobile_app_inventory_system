import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/use_cases/add_product_case.dart';
import '../../domain/use_cases/get_products_case.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/use_cases/update_product_case.dart';

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final AddProductCase _addProductCase;
  final GetProductsCase _getProductsCase;
  final ProductRepository _repository;
  final UpdateProductCase _updateProductCase;

  List<Product> _allProducts = [];

  ProductNotifier({
    required AddProductCase addProductCase,
    required GetProductsCase getProductsCase,
    required ProductRepository repository,
    required UpdateProductCase updateProductCase,
  }) : _addProductCase = addProductCase,
       _getProductsCase = getProductsCase,
       _repository = repository,
       _updateProductCase = updateProductCase,
       super(const AsyncValue.loading()) {
    fetchProducts();
  }

  // Filtros actuales
  String? _filterStorage;
  String? _filterCategory;

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    try {
      _allProducts = await _getProductsCase();
      _applyFilters();
      state = AsyncValue.data(_allProducts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createProduct(Product product) async {
    try {
      await _addProductCase(product);
      _allProducts.add(product);
      _applyFilters();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      _allProducts.removeWhere((p) => p.id == id);
      _applyFilters();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> isDuplicateCode(String code) async {
    return await _repository.existsCodeProduct(code);
  }

  void filterProducts({String? storage, String? category}) {
    _filterStorage = storage;
    _filterCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    final filtered = _allProducts.where((p) {
      final matchStorage =
          _filterStorage == null || p.storageLocation == _filterStorage;
      final matchCategory =
          _filterCategory == null || p.category == _filterCategory;
      return matchStorage && matchCategory;
    }).toList();
    state = AsyncValue.data(filtered);
  }

  Future<void> updateProduct(Product updatedProduct) async {
    try {
      // 1. Validar y actualizar en el repositorio
      await _updateProductCase(updatedProduct);

      // 2. Actualizar en la lista local
      final index = _allProducts.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _allProducts[index] = updatedProduct;
      } else {
        // Si por alguna razón no está, lo agregamos (raro, pero seguro)
        _allProducts.add(updatedProduct);
      }

      // 3. Aplicar filtros y actualizar estado
      _applyFilters();
    } catch (e, st) {
      // 4. Manejar error
      state = AsyncValue.error(e, st);
    }
  }
}
