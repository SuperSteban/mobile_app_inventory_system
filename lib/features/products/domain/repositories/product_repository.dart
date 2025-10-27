import '../entities/product.dart';

abstract class ProductRepository {
  Future<void> addProduct(Product product);
  Future<List<Product>> getProducts();
  Future<bool> existsCodeProduct(String codeProduct);
  Future<void> deleteProduct(String id);
}
