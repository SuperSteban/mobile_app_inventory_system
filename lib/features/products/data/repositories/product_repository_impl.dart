import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/firebase_product_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseProductDatasource datasource;

  ProductRepositoryImpl(this.datasource);

  @override
  Future<void> addProduct(Product product) async {
    await datasource.addProduct(product);
  }

  @override
  Future<List<Product>> getProducts() async {
    return await datasource.getProducts();
  }
}
