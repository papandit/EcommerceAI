import 'package:cwt_ecommerce_admin_panel/features/shop/models/depaerment_model.dart';
import 'package:get/get.dart';

import '../../services/api/api_client.dart';

class DepartMentRepository extends GetxController {
  static DepartMentRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  // Get all departments
  Future<List<DepartmentModel>> getAllCategories() async {
    try {
      final list = await _api.getList('/departments');
      return list.map((e) => DepartmentModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Create a new department → returns new id
  Future<String> createDepartment(DepartmentModel department) async {
    try {
      final data = await _api.post('/departments', department.toJson());
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw e.toString();
    }
  }

  // Legacy alias kept for compatibility (creates a department record).
  Future<String> createCategory(DepartmentModel category) async {
    return createDepartment(category);
  }

  // Update an existing department
  Future<void> updateCategory(DepartmentModel category) async {
    try {
      await _api.put('/departments/${category.id}', category.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete a department
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _api.delete('/departments/$categoryId');
    } catch (e) {
      throw e.toString();
    }
  }
}
