import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/formatters/formatter.dart';

class CategoryModel {
  String id;
  String name;
  String image;
  String? timestamp;
  List? parentId;
  bool isFeatured;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Not Mapped
  List<CategoryModel>? childCategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.isFeatured = false,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.childCategories,
    this.timestamp,
  });

  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  /// Empty Helper Function
  static CategoryModel empty() =>
      CategoryModel(id: '', image: '', name: '', isFeatured: false);

  /// Convert model to Json structure so that you can store data in Firebase
  toJson() {
    return {
      'Name': name,
      'Image': image,
      'ParentId': parentId,
      'IsFeatured': isFeatured,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt = DateTime.now(),
      'timestamp': timestamp ?? Timestamp.now().toString(),
    };
  }

  /// Build from a REST API JSON map (Node/MongoDB backend).
  factory CategoryModel.fromJson(Map<String, dynamic> data) {
    DateTime? _date(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return CategoryModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      parentId: data['ParentId'] is List ? data['ParentId'] : null,
      isFeatured: data['IsFeatured'] ?? false,
      createdAt: _date(data['CreatedAt'] ?? data['createdAt']),
      updatedAt: _date(data['UpdatedAt'] ?? data['updatedAt']),
      timestamp: (data['timestamp'] ?? '').toString(),
    );
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory CategoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    print("Parent Categories = doc ");
    if (document.data() != null) {
      final data = document.data()!;
      print("Parent Categories = dosc  $data ");
      // Map JSON Record to the Model
      return CategoryModel(
        id: document.id,
        name: data['Name'] ?? '',
        image: data['Image'] ?? '',
        parentId: data['ParentId'] ?? '',
        isFeatured: data['IsFeatured'] ?? false,
        createdAt:
            data.containsKey('CreatedAt') ? data['CreatedAt']?.toDate() : null,
        updatedAt:
            data.containsKey('UpdatedAt') ? data['UpdatedAt']?.toDate() : null,
        timestamp: data['timestamp'] ?? Timestamp.now().toString(),
      );
    } else {
      return CategoryModel.empty();
    }
  }
}

class ParentCategoryModel {
  String id;
  String parentname;

  // Not Mapped
  List<ParentCategoryModel>? childCategories;

  ParentCategoryModel({
    required this.id,
    required this.parentname,
  });

  /// Empty Helper Function
  static ParentCategoryModel empty() =>
      ParentCategoryModel(id: '', parentname: '');

  /// Convert model to Json structure so that you can store data in Firebase
  toJson() {
    return {
      'ParentName': parentname,
    };
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory ParentCategoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // Map JSON Record to the Model
      return ParentCategoryModel(
        id: document.id,
        parentname: data['ParentName'] ?? '',
      );
    } else {
      return ParentCategoryModel.empty();
    }
  }
}
