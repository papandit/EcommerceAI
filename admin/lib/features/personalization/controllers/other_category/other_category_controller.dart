import 'package:cwt_ecommerce_admin_panel/data/repositories/othercategories/other_category_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/models/other_category_model.dart';
import 'package:get/get.dart';

import '../../../../data/abstract/base_data_table_controller.dart';

class OtherCategoryController extends TBaseController<OtherCategoryModel> {
  static OtherCategoryController get instance => Get.find();

  final _categoryRepository = Get.put(OtherCategoryRepository());

  @override
  Future<void> deleteItem(OtherCategoryModel item) async {
    await _categoryRepository.deleteCategory(item.id);
  }

  @override
  Future<List<OtherCategoryModel>> fetchItems() async {
    return await _categoryRepository.getAllCategories();
  }

  @override
  bool containsSearchQuery(OtherCategoryModel item, String query) {
    return item.name.toLowerCase().contains(query.toLowerCase());
  }

  /// Sorting related code
  void sortByName(int sortColumnIndex, bool ascending) {
    sortByProperty(sortColumnIndex, ascending,
        (OtherCategoryModel category) => category.name.toLowerCase());
  }
}
