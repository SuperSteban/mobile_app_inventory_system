import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_app_inventory_system/features/products/domain/use_cases/update_product_case.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/use_cases/add_product_case.dart';
import '../../domain/use_cases/get_products_case.dart';
import 'product_notifier.dart';

final productProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
  final sl = GetIt.instance;

  return ProductNotifier(
    addProductCase: sl<AddProductCase>(),
    getProductsCase: sl<GetProductsCase>(),
    updateProductCase: sl<UpdateProductCase>(),
    repository: sl<ProductRepository>(),
  );
});

