import '../entities/product.dart';
import '../repositories/product_repository.dart';

class AddProductCase {
  final ProductRepository repository;

  AddProductCase(this.repository);

  Future<void> call(Product product) {
    return repository.addProduct(product);
  }
}
