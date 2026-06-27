import 'package:cwt_ecommerce_admin_panel/features/shop/models/product_category_model.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/product_model.dart';
import '../../services/api/api_client.dart';

/// Repository for managing product data (Node/MongoDB backend).
///
/// Note: the legacy "ProductCategory" many-to-many link collection is no longer
/// used — each product stores its CategoryId directly — so the link methods are
/// safe no-ops kept for call-site compatibility.
class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  /// Create product → returns new id.
  Future<String> createProduct(ProductModel product) async {
    try {
      final data = await _api.post('/products', product.toJson());
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Legacy product-category link — no-op (category lives on the product).
  Future<String> createProductCategory(
      ProductCategoryModel productCategory) async {
    return '';
  }

  /// Update product.
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _api.put('/products/${product.id}', product.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update specific field(s) on a product.
  Future<void> updateProductSpecificValue(id, Map<String, dynamic> data) async {
    try {
      await _api.put('/products/$id', data);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get all products (newest first).
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final list = await _api.getList('/products', query: {'sort': 'newest'});
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  /// Get a single product by id.
  Future<ProductModel?> getOrderById(String productID) async {
    try {
      final data = await _api.getOne('/products/$productID');
      if (data.isEmpty) throw 'Order not found';
      return ProductModel.fromJson(data);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Legacy product-category links — none in the new model.
  Future<List<ProductCategoryModel>> getProductCategories(
      String productId) async {
    return <ProductCategoryModel>[];
  }

  /// Legacy — no-op.
  Future<void> removeProductCategory(
      String productId, String categoryId) async {}

  /// Delete product.
  Future<void> deleteProduct(ProductModel product) async {
    try {
      await _api.delete('/products/${product.id}');
    } catch (e) {
      throw e.toString();
    }
  }
}
