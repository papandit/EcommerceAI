// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cwt_ecommerce_admin_panel/data/repositories/otherbrands/other_brand_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/other_category/other_category_controller.dart';
import 'package:get/get.dart';

import '../../../../data/abstract/base_data_table_controller.dart';
import '../../models/other_brand_model.dart';

class OtherBrandController extends TBaseController<OtherBrandModel> {
  // static OtherBrandController get instance => Get.find();
  static OtherBrandController get instance => Get.put(OtherBrandController());

  final _brandRepository = Get.put(OtherBrandRepository());
  final categoryController = Get.put(OtherCategoryController());

  @override
  Future<List<OtherBrandModel>> fetchItems() async {
    // Fetch brands
    final fetchedBrands = await _brandRepository.getAllBrands();

    // Fetch Brand Categories Relational Data
    final fetchedBrandCategories =
        await _brandRepository.getAllBrandCategories();

    // Fetch All Categories is data does not already exist
    if (categoryController.allItems.isNotEmpty)
      await categoryController.fetchItems();

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
    sortByProperty(sortColumnIndex, ascending,
        (OtherBrandModel b) => b.name.toLowerCase());
  }

  @override
  bool containsSearchQuery(OtherBrandModel item, String query) {
    return item.name.toLowerCase().contains(query.toLowerCase());
  }

  @override
  Future<void> deleteItem(OtherBrandModel item) async {
    await _brandRepository.deleteBrand(item);
  }
}
