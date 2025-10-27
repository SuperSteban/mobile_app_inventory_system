import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class AddProductCase {
  final ProductRepository repository;

  AddProductCase(this.repository);

  Future<void> call(Product product) async {
    await repository.addProduct(product);
  }
}
