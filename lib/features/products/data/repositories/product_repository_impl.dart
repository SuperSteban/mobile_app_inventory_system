// features/products/data/repositories/product_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/firebase_product_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseProductDatasource datasource;
  final FirebaseFirestore _firestore;

  ProductRepositoryImpl({
    required this.datasource,
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;


  @override
  Future<List<Product>> getProducts() async {
    return await datasource.getProducts();
  }

  @override
  Future<bool> existsCodeProduct(String codeProduct) async {
    return await datasource.existsCodeProduct(codeProduct);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  // IMPLEMENTADO: Crear con ID automático
  @override
  Future<Product> createProduct(Product product) async {
    try {
      final docRef = product.id.isEmpty
          ? _firestore.collection('products').doc() // ID automático
          : _firestore.collection('products').doc(product.id);

      final productWithId = product.copyWith(id: docRef.id);
      await docRef.set(productWithId.toJson());
      return productWithId;
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  // IMPLEMENTADO: Actualizar producto
  @override
  Future<void> updateProduct(Product product) async {
    try {
      if (product.id.isEmpty) {
        throw Exception('No se puede actualizar un producto sin ID');
      }

      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }
}