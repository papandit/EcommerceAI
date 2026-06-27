import 'package:get/get.dart';

import '../../services/api/api_client.dart';

/// Talks to our backend's admin BrandShoot endpoints (/api/admin/ai/*). The
/// backend holds the API key and proxies BrandShoot — this never sees it.
class AiRepository extends GetxController {
  static AiRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  /// Live BrandShoot category list (for the category dropdown).
  Future<dynamic> getCategories() async {
    return _api.getRaw('/admin/ai/categories');
  }

  /// Selectable preset model cards (Indian Woman, Indian Girl, …).
  /// Each item has { id, name, imageFullUrl }.
  Future<dynamic> getModels({String subType = 'photoshoot'}) async {
    return _api.getRaw('/admin/ai/models?sub_type=$subType');
  }

  /// Start a photoshoot (one product on one model, several poses).
  /// Provide the product either by [productId] (existing product) or
  /// [productImageB64] (a NEW product being created). Provide the model by
  /// [modelId] (preset) or [modelImageB64] (uploaded, base64).
  Future<Map<String, dynamic>> startPhotoshoot({
    String? productId,
    String? productImageB64,
    String? modelId,
    String? modelImageB64,
    String categoryId = 'Cloths',
  }) {
    return _api.post('/admin/ai/photoshoot', {
      if (productId != null && productId.isNotEmpty) 'productId': productId,
      if (productImageB64 != null && productImageB64.isNotEmpty)
        'productImage': productImageB64,
      if (modelId != null && modelId.isNotEmpty) 'modelId': modelId,
      if (modelImageB64 != null && modelImageB64.isNotEmpty)
        'modelImage': modelImageB64,
      'categoryId': categoryId,
    });
  }

  /// Re-host chosen result URLs to our own /uploads and return the durable URLs
  /// (used when creating a NEW product — there's no product to publish to yet).
  Future<Map<String, dynamic>> rehost(List<String> selectedUrls) {
    return _api.post('/admin/ai/rehost', {'selectedUrls': selectedUrls});
  }

  /// Start a catalog (product on multiple models).
  Future<Map<String, dynamic>> startCatalog({
    required String productId,
    required List<String> modelImagesB64,
    String categoryId = 'Cloths',
    String? backgroundColor,
  }) {
    return _api.post('/admin/ai/catalog', {
      'productId': productId,
      'modelImages': modelImagesB64,
      'categoryId': categoryId,
      if (backgroundColor != null && backgroundColor.isNotEmpty)
        'backgroundColor': backgroundColor,
    });
  }

  /// Poll a generation job. Returns { status, images:[{fullUrl,...}], ... }.
  Future<Map<String, dynamic>> getJob(String jobId) {
    return _api.getOne('/admin/ai/jobs/$jobId');
  }

  /// Re-host + publish the chosen result URLs to the product gallery.
  Future<Map<String, dynamic>> publish(
      String jobId, List<String> selectedUrls) {
    return _api.post('/admin/ai/jobs/$jobId/save', {
      'selectedUrls': selectedUrls,
    });
  }
}
