import 'package:cwt_ecommerce_admin_panel/data/repositories/coupan/coupan_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/coupan_model.dart';
import 'package:get/get.dart';

import '../../../../data/abstract/base_data_table_controller.dart';

class CoupanController extends TBaseController<CoupanModel> {
  static CoupanController get instance => Get.find();
  final _coupanRepository = Get.put(CoupanRepository());

  @override
  Future<void> deleteItem(CoupanModel item) async {
    await _coupanRepository.deleteCategory(item.id);
  }

  @override
  Future<List<CoupanModel>> fetchItems() async {
    print("getAllCategories() :: ${_coupanRepository.getAllCategories()}");
    _coupanRepository.getAllCategories().then(
      (value) {
        print("HR :: first.id ::  ${value.first.id}");
        print(value.length);
        print("HR :: first.id :: ${value.last.id}");
      },
    );
    return await _coupanRepository.getAllCategories();
  }

  @override
  bool containsSearchQuery(CoupanModel item, String query) {
    return item.name.toLowerCase().contains(query.toLowerCase());
  }

  /// Sorting related code
  void sortByName(int sortColumnIndex, bool ascending) {
    sortByProperty(sortColumnIndex, ascending,
        (CoupanModel coupan) => coupan.name.toLowerCase());
  }
}
