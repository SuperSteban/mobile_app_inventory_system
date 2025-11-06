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
  final String codeProduct;
  final String unit;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.img,
    required this.stock,
    required this.minStock,
    this.storageLocation,
    required this.codeProduct,
    required this.unit,
    required this.createdAt,
    this.updatedAt,
  });

  // Stock helpers
  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= minStock;

  // toJson: Usa FieldValue.serverTimestamp() para updatedAt
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'category': category,
    'img': img,
    'stock': stock,
    'minStock': minStock,
    'storageLocation': storageLocation,
    'codeProduct': codeProduct,
    'unit': unit,
    'createdAt': createdAt,
    'updatedAt': updatedAt != null
        ? Timestamp.fromDate(updatedAt!)
        : FieldValue.serverTimestamp(),
  };

  // fromJson: Manejo seguro de tipos
  factory Product.fromJson(String id, Map<String, dynamic> json) {
    return Product(
      id: id,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'general',
      img: json['img'] as String?,
      stock: (json['stock'] as num?)?.toDouble() ?? 0.0,
      minStock: (json['minStock'] as num?)?.toDouble() ?? 0.0,
      storageLocation: json['storageLocation'] as String?,
      codeProduct: json['codeProduct'] as String? ?? '',
      unit: json['unit'] as String? ?? 'pieza',
      createdAt: _parseTimestamp(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  // Helper para parsear Timestamp
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // EL MÉTODO QUE TE FALTABA: copyWith
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
    String? unit,
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
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, stock: $stock)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}