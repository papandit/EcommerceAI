import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/formatters/formatter.dart';
import 'other_category_model.dart';

class OtherBrandModel {
  String id;
  String name;
  // Uint8List image;
  String image;
  // bool isFeatured;
  // int? productsCount;
  DateTime? createdAt;
  DateTime? updatedAt;
  String category;
  String? subcategory;
  String about;

  // Not mapped
  List<OtherCategoryModel>? brandCategories;

  OtherBrandModel({
    required this.id,
    required this.image,
    required this.name,
    required this.category,
    required this.about,
    this.subcategory,

    // this.isFeatured = false,
    // this.productsCount,
    this.createdAt,
    this.updatedAt,
    this.brandCategories,
  });

  /// Empty Helper Function
  static OtherBrandModel empty() =>
      OtherBrandModel(id: '', name: '', category: '', about: '', image: '');
  // id: '', name: '', category: '', about: '', image: Uint8List(0));

  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  /// Convert model to Json structure so that you can store data in Firebase
  toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'CreatedAt': createdAt,
      // 'IsFeatured': isFeatured,
      // 'ProductsCount': productsCount = 0,
      'UpdatedAt': updatedAt = DateTime.now(),
      'Category': category,
      'subcategory': subcategory,
      'About': about,
    };
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory OtherBrandModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return OtherBrandModel.empty();
    return OtherBrandModel(
      id: data['Id'] ?? '',
      name: data['Name'] ?? '',
      category: data['Category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      about: data['About'] ?? '',
      // image: data['Image'] != null ? base64Decode(data['Image']) : Uint8List(0),
      image: data['Image'] ?? '',
      // isFeatured: data['IsFeatured'] ?? false,
      // productsCount: int.parse((data['ProductsCount'] ?? 0).toString()),
      createdAt:
          data.containsKey('CreatedAt') ? data['CreatedAt']?.toDate() : null,
      updatedAt:
          data.containsKey('UpdatedAt') ? data['UpdatedAt']?.toDate() : null,
    );
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory OtherBrandModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // Map JSON Record to the Model
      return OtherBrandModel(
        id: document.id,
        name: data['Name'] ?? '',
        category: data['Category'] ?? '',
        subcategory: data['subcategory'] ?? '',
        about: data['About'] ?? '',
        // image:
        //     data['Image'] != null ? base64Decode(data['Image']) : Uint8List(0),
        image: data['Image'] ?? '',
        // productsCount: data['ProductsCount'] ?? '',
        // isFeatured: data['IsFeatured'] ?? false,
        createdAt:
            data.containsKey('CreatedAt') ? data['CreatedAt']?.toDate() : null,
        updatedAt:
            data.containsKey('UpdatedAt') ? data['UpdatedAt']?.toDate() : null,
      );
    } else {
      return OtherBrandModel.empty();
    }
  }
}
