// domain/use_cases/update_product_case.dart
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class UpdateProductCase {
  final ProductRepository repository;

  UpdateProductCase(this.repository);

  Future<void> call(Product product) async {
    // Validar código duplicado (excepto si es el mismo producto)
    final exists = await repository.existsCodeProduct(product.codeProduct);
    if (exists) {
      final currentProducts = await repository.getProducts();
      final conflictingProduct = currentProducts.firstWhere(
            (p) => p.codeProduct == product.codeProduct,
        orElse: () => product,
      );
      if (conflictingProduct.id != product.id) {
        throw Exception('El código de barras ya está en uso por otro producto');
      }
    }

    await repository.updateProduct(product);
  }
}