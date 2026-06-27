import 'package:cwt_ecommerce_admin_panel/features/shop/models/coupan_model.dart';
import 'package:get/get.dart';

import '../../services/api/api_client.dart';

class CoupanRepository extends GetxController {
  static CoupanRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  // Get all coupons
  Future<List<CoupanModel>> getAllCategories() async {
    try {
      final list = await _api.getList('/coupons');
      return list.map((e) => CoupanModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Create a coupon → returns new id
  Future<String> createCategory(CoupanModel category) async {
    try {
      final data = await _api.post('/coupons', category.toJson());
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateCategoryName(String id, String newName) async {
    try {
      await _api.put('/coupons/$id', {'name': newName});
    } catch (e) {
      throw e.toString();
    }
  }

  // Update an existing coupon
  Future<void> updateCategory(CoupanModel category) async {
    try {
      await _api.put('/coupons/${category.id}', category.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete a coupon
  Future<void> deleteCategory(String coupanId) async {
    try {
      await _api.delete('/coupons/$coupanId');
    } catch (e) {
      throw e.toString();
    }
  }
}
