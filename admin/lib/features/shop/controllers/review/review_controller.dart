import 'package:cwt_ecommerce_admin_panel/common/review/review_repository.dart';

import 'package:cwt_ecommerce_admin_panel/features/shop/models/review_model.dart';
import 'package:get/get.dart';

import '../../../../data/abstract/base_data_table_controller.dart';

class ReviewController extends TBaseController<ReviewModel> {
  static ReviewController get instance => Get.find();
  final _ReviewRepository = Get.put(ReviewRepository());

  @override
  Future<void> deleteItem(ReviewModel item) async {
    await _ReviewRepository.deleteCategory(item.id);
  }

  @override
  Future<List<ReviewModel>> fetchItems() async {
    print("getAllCategories() :: ${_ReviewRepository.getAllCategories()}");
    _ReviewRepository.getAllCategories().then(
      (value) {},
    );
    return await _ReviewRepository.getAllCategories();
  }

  @override
  bool containsSearchQuery(ReviewModel item, String query) {
    return item.name.toLowerCase().contains(query.toLowerCase());
  }

  /// Sorting related code
  void sortByName(int sortColumnIndex, bool ascending) {
    sortByProperty(sortColumnIndex, ascending,
        (ReviewModel Review) => Review.name.toLowerCase());
  }
}
