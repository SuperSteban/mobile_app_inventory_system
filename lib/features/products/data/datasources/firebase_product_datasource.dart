import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';

class FirebaseProductDatasource {
  final _collection = FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(Product product) async {
    await _collection.doc(product.id).set({
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'category': product.category,
      'img': product.img,
      'createdAt': product.createdAt.toIso8601String(),
    });
  }

  Future<List<Product>> getProducts() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: data['id'],
        name: data['name'],
        price: (data['price'] as num).toDouble(),
        category: data['category'],
        img: data['img'],
        createdAt: DateTime.parse(data['createdAt']),
      );
    }).toList();
  }
}
