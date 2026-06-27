import 'package:cwt_ecommerce_admin_panel/features/personalization/models/other_brand_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/models/othre_brand_category_model.dart';
import 'package:get/get.dart';

import '../../services/api/api_client.dart';

/// Other-brand repository (Node/MongoDB backend).
///
/// The main entity lives in the generic `/others` collection. The legacy
/// "OtherBrandCategory" / "BrandCategory" link collections are no longer used;
/// those methods are safe no-ops kept for call-site compatibility.
class OtherBrandRepository extends GetxController {
  // Singleton instance of the OtherBrandRepository
  static OtherBrandRepository get instance => Get.put(OtherBrandRepository());

  final ApiClient _api = ApiClient.instance;

  // Get all brands from the generic 'Others' collection
  Future<List<OtherBrandModel>> getAllBrands() async {
    try {
      final list = await _api.getList('/others');
      return list.map((e) => OtherBrandModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Legacy link collection — no backend endpoint; no-op.
  Future<List<OtherBrandCategoryModel>> getAllBrandCategories() async =>
      <OtherBrandCategoryModel>[];

  // Legacy link collection — no backend endpoint; no-op.
  Future<List<OtherBrandCategoryModel>> getSpecificBrandCategories(
          String brandId) async =>
      <OtherBrandCategoryModel>[];

  // Create a new brand → returns new id
  Future<String> createBrand(OtherBrandModel brand) async {
    try {
      final data = await _api.post('/others', brand.toJson());
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw e.toString();
    }
  }

  // Legacy link collection — no backend endpoint; no-op.
  Future<String> createBrandCategory(
          OtherBrandCategoryModel brandCategory) async =>
      '';

  // Update an existing brand
  Future<void> updateBrand(OtherBrandModel brand) async {
    try {
      await _api.put('/others/${brand.id}', brand.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete an existing brand
  Future<void> deleteBrand(OtherBrandModel brand) async {
    try {
      await _api.delete('/others/${brand.id}');
    } catch (e) {
      throw e.toString();
    }
  }

  // Legacy link collection — no backend endpoint; no-op.
  Future<void> deleteBrandCategory(String brandCategoryId) async {}
}
