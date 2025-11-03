// domain/use_cases/add_product_case.dart
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class AddProductCase {
  final ProductRepository repository;
  AddProductCase(this.repository);

  Future<Product> call(Product product) async {
    // Validar código duplicado
    final exists = await repository.existsCodeProduct(product.codeProduct);
    if (exists && product.id.isEmpty) {
      throw Exception('El código de barras ya está en uso');
    }

    return await repository.createProduct(product);
  }
}