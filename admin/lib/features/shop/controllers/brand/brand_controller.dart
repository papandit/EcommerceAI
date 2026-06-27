import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:get/get.dart';

import '../../../../data/abstract/base_data_table_controller.dart';
import '../../../../data/repositories/brands/brand_repository.dart';
import '../../models/brand_model.dart';

class BrandController extends TBaseController<BrandModel> {
  static BrandController get instance => Get.find();

  final _brandRepository = Get.put(BrandRepository());
  final categoryController = Get.put(CategoryController());

  @override
  Future<List<BrandModel>> fetchItems() async {
    // Fetch brands
    final fetchedBrands = await _brandRepository.getAllBrands();

    // Fetch Brand Categories Relational Data
    final fetchedBrandCategories =
        await _brandRepository.getAllBrandCategories();

    // Fetch All Categories is data does not already exist
    if (categoryController.allItems.isNotEmpty) {
      await categoryController.fetchItems();
    }

    // Loop all brands and fetch categories of each
    for (var brand in fetchedBrands) {
      // Extract categoryIds from the documents
      List<String> categoryIds = fetchedBrandCategories
          .where((brandCategory) => brandCategory.brandId == brand.id)
          .map((brandCategory) => brandCategory.categoryId)
          .toList();

      brand.brandCategories = categoryController.allItems
          .where((category) => categoryIds.contains(category.id))
          .toList();
    }

    return fetchedBrands;
  }

  void sortByName(int sortColumnIndex, bool ascending) {
    sortByProperty(
        sortColumnIndex, ascending, (BrandModel b) => b.name.toLowerCase());
  }

  @override
  bool containsSearchQuery(BrandModel item, String query) {
    return item.name.toLowerCase().contains(query.toLowerCase());
  }

  @override
  Future<void> deleteItem(BrandModel item) async {
    await _brandRepository.deleteBrand(item);
  }
}
