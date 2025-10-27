import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? img;
  final double stock;
  final double minStock;
  final String? storageLocation;
  final String codeProduct; //codigo de barras
  final String unit; // unidad de medida (kg, pieza, caja, LTS, gr)
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.img,
    required this.stock,
    required this.minStock,
    this.storageLocation,
    required this.codeProduct,
    required this.createdAt,
    this.updatedAt,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'img': img,
      'stock': stock,
      'minStock': minStock,
      'storageLocation': storageLocation,
      'codeProduct': codeProduct,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'unit': unit,
    };
  }

  //verificar si el stock es bajo
  bool get isLowStock => stock <= minStock;
  //verificar si esta agotado
  bool get isOutOfStock => stock <= 0;

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      img: map['img'],
      stock: map['stock'] ?? 0,
      minStock: map['minStock'] ?? 0,
      codeProduct: map['codeProduct'] ?? '',
      storageLocation: map['storageLocation'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      unit: map['unit'] ?? 'pieza',
    );
  }
  //metodo para copiar con cambios
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? img,
    double? stock,
    double? minStock,
    String? storageLocation,
    String? codeProduct,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      img: img ?? this.img,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      storageLocation: storageLocation ?? this.storageLocation,
      codeProduct: codeProduct ?? this.codeProduct,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unit: unit,
    );
  }
}
