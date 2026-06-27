import 'package:cloud_firestore/cloud_firestore.dart';

class OtherBrandCategoryModel {
  String? id;
  final String brandId;
  final String categoryId;

  OtherBrandCategoryModel({
    this.id,
    required this.brandId,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'brandId': brandId,
      'categoryId': categoryId,
    };
  }

  factory OtherBrandCategoryModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OtherBrandCategoryModel(
      id: snapshot.id,
      brandId: data['brandId'] as String,
      categoryId: data['categoryId'] as String,
    );
  }
}
