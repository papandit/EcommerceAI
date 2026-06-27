import 'package:get/get.dart';

import '../../../features/shop/models/category_model.dart';
import '../../services/api/api_client.dart';

class CategoryRepository extends GetxController {
  static CategoryRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  // Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final list = await _api.getList('/categories');
      final result = list.map((e) => CategoryModel.fromJson(e)).toList();
      update();
      return result;
    } catch (e) {
      throw e.toString();
    }
  }

  // Create a new category → returns new id
  Future<String> createCategory(CategoryModel category) async {
    try {
      final data = await _api.post('/categories', category.toJson());
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw e.toString();
    }
  }

  // Parent categories are represented by the category's ParentId list now — no-op.
  Future<String> createParentCategory(ParentCategoryModel category) async {
    return '';
  }

  // Update an existing category
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _api.put('/categories/${category.id}', category.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _api.delete('/categories/$categoryId');
    } catch (e) {
      throw e.toString();
    }
  }
}
