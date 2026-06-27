import 'package:get/get.dart';

import '../../../features/shop/models/brand_category_model.dart';
import '../../../features/shop/models/brand_model.dart';
import '../../services/api/api_client.dart';

/// Brand repository (Node/MongoDB backend).
///
/// The legacy "BrandCategory" link collection is no longer used; those methods
/// are safe no-ops kept for call-site compatibility.
class BrandRepository extends GetxController {
  static BrandRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  // Get all brands
  Future<List<BrandModel>> getAllBrands() async {
    try {
      final list = await _api.getList('/brands');
      return list.map((e) => BrandModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Legacy brand-category links — no longer used.
  Future<List<BrandCategoryModel>> getAllBrandCategories() async =>
      <BrandCategoryModel>[];

  Future<List<BrandCategoryModel>> getSpecificBrandCategories(
          String brandId) async =>
      <BrandCategoryModel>[];

  // Create a new brand → returns new id
  Future<String> createBrand(BrandModel brand) async {
    try {
      final data = await _api.post('/brands', brand.toJson());
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> createBrandCategory(BrandCategoryModel brandCategory) async =>
      '';

  // Update an existing brand
  Future<void> updateBrand(BrandModel brand) async {
    try {
      await _api.put('/brands/${brand.id}', brand.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete a brand
  Future<void> deleteBrand(BrandModel brand) async {
    try {
      await _api.delete('/brands/${brand.id}');
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteBrandCategory(String brandCategoryId) async {}
}
