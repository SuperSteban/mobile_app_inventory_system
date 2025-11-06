// domain/repositories/product_repository.dart
import '../entities/product.dart';

abstract class ProductRepository {
  // Crear producto (con ID manual o automático)
  Future<Product> createProduct(Product product);

  // Actualizar producto existente
  Future<void> updateProduct(Product product);

  // Obtener todos los productos
  Future<List<Product>> getProducts();

  // Verificar si el código ya existe
  Future<bool> existsCodeProduct(String codeProduct);

  // Eliminar producto
  Future<void> deleteProduct(String id);
}