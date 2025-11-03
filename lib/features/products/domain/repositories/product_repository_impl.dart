// data/repositories/product_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_inventory_system/features/products/domain/repositories/product_repository.dart';

import '../entities/product.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'products';

  ProductRepositoryImpl(this._firestore);

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final docRef = product.id.isEmpty
          ? _firestore.collection(_collection).doc() // ID automático
          : _firestore.collection(_collection).doc(product.id);

      final productWithId = product.copyWith(id: docRef.id);
      await docRef.set(productWithId.toJson());
      return productWithId;
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  @override
  Future<bool> existsCodeProduct(String codeProduct) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('codeProduct', isEqualTo: codeProduct)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error al verificar código: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }
}