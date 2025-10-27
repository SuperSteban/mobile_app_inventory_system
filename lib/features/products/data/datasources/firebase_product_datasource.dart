import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';

class FirebaseProductDatasource {
  final _collection = FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(Product product) async {
    await _collection.doc(product.id).set(product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Product.fromMap(doc.id, doc.data());
    }).toList();
  }

  //que no haya duplicados en codigo de barras
  Future<bool> existsCodeProduct(String codeProduct) async {
    final snapshot = await _collection
        .where('codeProduct', isEqualTo: codeProduct)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
