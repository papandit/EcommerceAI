import 'package:cwt_ecommerce_admin_panel/features/shop/models/review_model.dart';
import 'package:get/get.dart';

import '../../data/services/api/api_client.dart';

class ReviewRepository extends GetxController {
  static ReviewRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  // Get all reviews / contact messages
  Future<List<ReviewModel>> getAllCategories() async {
    try {
      final list = await _api.getList('/reviews');
      return list.map((e) => ReviewModel.fromMap(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Create a review → returns new id
  Future<String> createCategory(ReviewModel category) async {
    try {
      final data = await _api.post('/reviews', category.toJson());
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateCategoryName(String id, String newName) async {
    try {
      await _api.put('/reviews/$id', {'name': newName});
    } catch (e) {
      throw e.toString();
    }
  }

  // Update an existing review
  Future<void> updateCategory(ReviewModel category) async {
    try {
      await _api.put('/reviews/${category.id}', category.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete a review
  Future<void> deleteCategory(String ReviewId) async {
    try {
      await _api.delete('/reviews/$ReviewId');
    } catch (e) {
      throw e.toString();
    }
  }
}
