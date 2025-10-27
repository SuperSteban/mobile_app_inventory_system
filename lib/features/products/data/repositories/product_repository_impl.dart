import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/firebase_product_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseProductDatasource datasource;

  ProductRepositoryImpl(this.datasource);

  @override
  Future<void> addProduct(Product product) {
    return datasource.addProduct(product);
  }

  @override
  Future<List<Product>> getProducts() {
    return datasource.getProducts();
  }

  @override
  Future<bool> existsCodeProduct(String codeProduct) {
    return datasource.existsCodeProduct(codeProduct);
  }
}
