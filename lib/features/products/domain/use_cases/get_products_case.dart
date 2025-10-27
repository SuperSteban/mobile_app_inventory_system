import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsCase {
  final ProductRepository repository;

  GetProductsCase(this.repository);

  Future<List<Product>> call() async {
    return await repository.getProducts();
  }
}
