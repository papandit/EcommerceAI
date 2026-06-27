import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/formatters/formatter.dart';

class OtherCategoryModel {
  String id;
  String name;
  String image;
  List? parentId;
  bool isFeatured;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Not Mapped
  List<OtherCategoryModel>? childCategories;

  OtherCategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.isFeatured = false,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.childCategories,
  });

  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  /// Empty Helper Function
  static OtherCategoryModel empty() =>
      OtherCategoryModel(id: '', image: '', name: '', isFeatured: false);

  /// Convert model to Json structure so that you can store data in Firebase
  toJson() {
    return {
      'Name': name,
      'Image': image,
      'ParentId': parentId,
      'IsFeatured': isFeatured,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt = DateTime.now(),
    };
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory OtherCategoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // Map JSON Record to the Model
      return OtherCategoryModel(
        id: document.id,
        name: data['Name'] ?? '',
        image: data['Image'] ?? '',
        parentId: data['ParentId'] ?? '',
        isFeatured: data['IsFeatured'] ?? false,
        createdAt:
            data.containsKey('CreatedAt') ? data['CreatedAt']?.toDate() : null,
        updatedAt:
            data.containsKey('UpdatedAt') ? data['UpdatedAt']?.toDate() : null,
      );
    } else {
      return OtherCategoryModel.empty();
    }
  }
}

class OtherParentCategoryModel {
  String id;
  String parentname;

  // Not Mapped
  List<OtherParentCategoryModel>? childCategories;

  OtherParentCategoryModel({
    required this.id,
    required this.parentname,
  });

  /// Empty Helper Function
  static OtherParentCategoryModel empty() =>
      OtherParentCategoryModel(id: '', parentname: '');

  /// Convert model to Json structure so that you can store data in Firebase
  toJson() {
    return {
      'ParentName': parentname,
    };
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory OtherParentCategoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // Map JSON Record to the Model
      return OtherParentCategoryModel(
        id: document.id,
        parentname: data['ParentName'] ?? '',
      );
    } else {
      return OtherParentCategoryModel.empty();
    }
  }
}
