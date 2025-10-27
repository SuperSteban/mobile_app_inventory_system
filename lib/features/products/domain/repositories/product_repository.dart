import '../entities/product.dart';

abstract class ProductRepository {
  Future<void> addProduct(Product product);
  Future<List<Product>> getProducts();
}


//después agregaremos mas funcionalidades como update o delete, por el momento es puro create an show o list 