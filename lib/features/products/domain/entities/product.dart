import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? img;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.img,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'createdAt': createdAt,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'],
      price: map['price'].toDouble(),
      category: map['category'],
      img: map['img'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
