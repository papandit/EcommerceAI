import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/formatters/formatter.dart';
import 'category_model.dart';

class BrandModel {
  String id;
  String name;
  String image;
  bool isFeatured;
  int? productsCount;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Not mapped
  List<CategoryModel>? brandCategories;

  BrandModel({
    required this.id,
    required this.image,
    required this.name,
    this.isFeatured = false,
    this.productsCount,
    this.createdAt,
    this.updatedAt,
    this.brandCategories,
  });

  /// Empty Helper Function
  static BrandModel empty() => BrandModel(id: '', image: '', name: '');

  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  /// Convert model to Json structure so that you can store data in Firebase
  toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'CreatedAt': createdAt,
      'IsFeatured': isFeatured,
      'ProductsCount': productsCount = 0,
      'UpdatedAt': updatedAt = DateTime.now(),
    };
  }

  /// Parse a date that may be a Firestore Timestamp OR an ISO-8601 string
  /// (the REST API returns strings).
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      if (v is String) return DateTime.tryParse(v);
      return v.toDate(); // Firestore Timestamp
    } catch (_) {
      return null;
    }
  }

  /// Map a JSON map (embedded Brand or REST API response) to the model.
  factory BrandModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return BrandModel.empty();
    return BrandModel(
      id: (data['Id'] ?? data['id'] ?? data['_id'] ?? '').toString(),
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      productsCount: int.tryParse((data['ProductsCount'] ?? 0).toString()) ?? 0,
      createdAt: _parseDate(data['CreatedAt'] ?? data['createdAt']),
      updatedAt: _parseDate(data['UpdatedAt'] ?? data['updatedAt']),
    );
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory BrandModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // Map JSON Record to the Model
      return BrandModel(
        id: document.id,
        name: data['Name'] ?? '',
        image: data['Image'] ?? '',
        productsCount: data['ProductsCount'] ?? '',
        isFeatured: data['IsFeatured'] ?? false,
        createdAt:
            data.containsKey('CreatedAt') ? data['CreatedAt']?.toDate() : null,
        updatedAt:
            data.containsKey('UpdatedAt') ? data['UpdatedAt']?.toDate() : null,
      );
    } else {
      return BrandModel.empty();
    }
  }
}
