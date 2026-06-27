import 'package:cwt_ecommerce_admin_panel/features/personalization/models/other_category_model.dart';
import 'package:get/get.dart';

import '../../services/api/api_client.dart';

/// Other-category repository (Node/MongoDB backend).
///
/// The main entity lives in the generic `/others` collection. The legacy
/// "OtherParentCategories" collection is no longer used; that method is a safe
/// no-op kept for call-site compatibility.
class OtherCategoryRepository extends GetxController {
  // Singleton instance of the OtherCategoryRepository
  static OtherCategoryRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  // Get all categories from the generic 'Others' collection
  Future<List<OtherCategoryModel>> getAllCategories() async {
    try {
      final list = await _api.getList('/others');
      return list.map(_categoryFromJson).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Create a new category → returns new id
  Future<String> createCategory(OtherCategoryModel category) async {
    try {
      final data = await _api.post('/others', category.toJson());
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw e.toString();
    }
  }

  // Legacy "OtherParentCategories" collection — no backend endpoint; no-op.
  Future<String> createParentCategory(OtherParentCategoryModel category) async =>
      '';

  // Update an existing category
  Future<void> updateCategory(OtherCategoryModel category) async {
    try {
      await _api.put('/others/${category.id}', category.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete an existing category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _api.delete('/others/$categoryId');
    } catch (e) {
      throw e.toString();
    }
  }

  // OtherCategoryModel has no fromJson factory; map the API map here without
  // touching the model. Mirrors the legacy fromSnapshot field mapping.
  OtherCategoryModel _categoryFromJson(Map<String, dynamic> data) {
    if (data.isEmpty) return OtherCategoryModel.empty();
    return OtherCategoryModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      parentId: data['ParentId'] is List ? data['ParentId'] as List : null,
      isFeatured: data['IsFeatured'] ?? false,
      createdAt: _parseDate(data['CreatedAt']),
      updatedAt: _parseDate(data['UpdatedAt']),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
