import 'package:get/get.dart';

import '../../../features/shop/models/banner_model.dart';
import '../../services/api/api_client.dart';

class BannerRepository extends GetxController {
  static BannerRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  // Get all banners
  Future<List<BannerModel>> getAllBanners() async {
    try {
      final list = await _api.getList('/banners');
      return list.map((e) => BannerModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Create a new banner → returns new id
  Future<String> createBanner(BannerModel banner) async {
    try {
      final data = await _api.post('/banners', banner.toJson());
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw e.toString();
    }
  }

  // Update an existing banner
  Future<void> updateBanner(BannerModel banner) async {
    try {
      await _api.put('/banners/${banner.id}', banner.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete a banner
  Future<void> deleteBanner(String bannerId) async {
    try {
      await _api.delete('/banners/$bannerId');
    } catch (e) {
      throw e.toString();
    }
  }
}
