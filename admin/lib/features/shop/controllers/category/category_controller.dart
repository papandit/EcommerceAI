import 'package:get/get.dart';

import '../../../../data/abstract/base_data_table_controller.dart';
import '../../../../data/repositories/categories/category_repository.dart';
import '../../models/category_model.dart';

class CategoryController extends TBaseController<CategoryModel> {
  static CategoryController get instance => Get.find();

  final _categoryRepository = Get.put(CategoryRepository());

  @override
  Future<void> deleteItem(CategoryModel item) async {
    await _categoryRepository.deleteCategory(item.id);
  }

  @override
  void onInit() {
    print("miral");
    fetchItems();

    // TODO: implement onInit
    super.onInit();
  }

  @override
  Future<List<CategoryModel>> fetchItems() async {
    print("getAllCategories() :: ${_categoryRepository.getAllCategories()}");
    _categoryRepository.getAllCategories().then(
      (value) {
        print("HR :: first.id ::  ${value.first.id}");
        print(value.length);
        print("HR :: first.id :: ${value.last.id}");
      },
    );
    return await _categoryRepository.getAllCategories();
  }

// @override
// Future<List<CategoryModel>> fetchItems() async {
//   List<CategoryModel> categories = await _categoryRepository.getAllCategories();

//   // Fetch all parent categories first (assuming you have a method to get them)
//   List<ParentCategoryModel> parentCategories = await _categoryRepository.getAllParentCategories();

//   for (var category in categories) {
//     if (category.parentId != null && category.parentId!.isNotEmpty) {
//       category.childCategories = [];

//       for (var parentId in category.parentId!) {
//         final parentCategory = parentCategories.firstWhere(
//           (parent) => parent.id == parentId,
//           orElse: () => ParentCategoryModel.empty(),
//         );
//         category.childCategories!.add(CategoryModel(
//           id: parentCategory.id,
//           name: parentCategory.parentname,
//           image: '', // Assuming parent category does not have an image
//           isFeatured: false,
//         ));
//       }
//     }
//   }

//   update(); // Update the state after associating the parent categories
//   return categories;
// }

  @override
  bool containsSearchQuery(CategoryModel item, String query) {
    return item.name.toLowerCase().contains(query.toLowerCase());
  }

  /// Sorting related code
  void sortByName(int sortColumnIndex, bool ascending) {
    sortByProperty(sortColumnIndex, ascending,
        (CategoryModel category) => category.name.toLowerCase());
  }
}
