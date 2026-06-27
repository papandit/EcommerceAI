import 'package:cwt_ecommerce_admin_panel/data/repositories/department/department_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/depaerment_model.dart';
import 'package:get/get.dart';
import '../../../../data/abstract/base_data_table_controller.dart';

class DepartMentController extends TBaseController<DepartmentModel> {
  static DepartMentController get instance => Get.find();

  final _departmentRepository = Get.put(DepartMentRepository());

  final RxBool isAdding = false.obs;

  @override
  Future<void> deleteItem(DepartmentModel item) async {
    await _departmentRepository.deleteCategory(item.id);
  }

  /// Create a new department and add it to the list.
  Future<void> addDepartment(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    try {
      isAdding.value = true;
      final dept =
          DepartmentModel(id: '', deptName: trimmed, lastname: trimmed);
      final id = await _departmentRepository.createDepartment(dept);
      dept.id = id;
      addItemToLists(dept);
      Get.snackbar('Success', 'Department "$trimmed" added',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isAdding.value = false;
    }
  }

  var departmentName = <String>[
    'Popular',
    'Festival',
    'Best Selling',
    'Trending',
  ].obs;

  var oldDepartmentName = <String>[
    'Popular',
    'Festival',
    'Best Selling',
    'Trending',
  ].obs;

  @override
  Future<List<DepartmentModel>> fetchItems() async {
    try {
      List<DepartmentModel> categories =
          await _departmentRepository.getAllCategories();

      if (categories.isNotEmpty) {
        print("miral.id :: ${categories.first.id}");
        print("HR :: first.id :: ${categories.last.id}");
        print("Total Categories: ${categories.length}");

        // Extract unique department names
        final fetchedDepartments = categories.map((e) => e.deptName).toSet();
        final fetchedOldDepartments = categories.map((e) => e.lastname).toSet();

        // Update lists with default and fetched values (removes duplicates)
        departmentName.assignAll([
          'Popular',
          'Festival',
          'Best Selling',
          'Trending',
          ...fetchedDepartments,
        ]);

        oldDepartmentName.assignAll([
          'Popular',
          'Festival',
          'Best Selling',
          'Trending',
          ...fetchedOldDepartments,
        ]);
      }

      return categories;
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

// @override
// Future<List<DepartmentModel>> fetchItems() async {
//   List<DepartmentModel> categories = await _departmentRepository.getAllCategories();

//   // Fetch all parent categories first (assuming you have a method to get them)
//   List<ParentCategoryModel> parentCategories = await _departmentRepository.getAllParentCategories();

//   for (var category in categories) {
//     if (category.parentId != null && category.parentId!.isNotEmpty) {
//       category.childCategories = [];

//       for (var parentId in category.parentId!) {
//         final parentCategory = parentCategories.firstWhere(
//           (parent) => parent.id == parentId,
//           orElse: () => ParentCategoryModel.empty(),
//         );
//         category.childCategories!.add(DepartmentModel(
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
  bool containsSearchQuery(DepartmentModel item, String query) {
    return item.name.toLowerCase().contains(query.toLowerCase());
  }

  /// Sorting related code
  void sortByName(int sortColumnIndex, bool ascending) {
    sortByProperty(sortColumnIndex, ascending,
        (DepartmentModel category) => category.name.toLowerCase());
  }
}
