import 'package:cwt_ecommerce_admin_panel/data/repositories/categories/category_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/category_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../media/controllers/media_controller.dart';

class CreateCategoryController extends GetxController {
  static CreateCategoryController get instance => Get.find();

  final selectedParent = CategoryModel.empty().obs;
  final loading = false.obs;
  final isFeatured = false.obs;
  final name = TextEditingController();
  final parentname = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RxString imageURL = ''.obs;
  List sub_category_data = [].obs;
  final departmentname = TextEditingController();
  List department_data = [].obs;
  RxString Forupdateid = ''.obs;

  /// Method to reset fields
  void resetFields() {
    selectedParent(CategoryModel.empty());
    loading(false);
    isFeatured(false);
    name.clear();
    sub_category_data.clear();
    department_data.clear();
    imageURL.value = '';
  }

  /// Pick a category image directly from the device (file dialog → upload).
  void pickImage() async {
    final url = await Get.put(MediaController()).pickAndUploadImage(
        MediaCategory.categories,
        onPreview: (b) => imageURL.value = b);
    if (url != null && url.isNotEmpty) imageURL.value = url;
  }

  /// Register new Category
  Future<void> createCategory() async {
    try {
      // Start Loading
      TFullScreenLoader.popUpCircular();

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (formKey.currentState != null && !formKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
            title: 'Missing name',
            message: 'Please enter a Category Name before creating.');
        return;
      }
      if (name.text.trim().isEmpty) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
            title: 'Missing name',
            message: 'Please enter a Category Name before creating.');
        return;
      }

      // Map Data
      final newRecord = CategoryModel(
        id: '',
        image: imageURL.value,
        name: name.text.trim(),
        createdAt: DateTime.now(),
        isFeatured: isFeatured.value,
        parentId: sub_category_data,
      );

      // Call Repository to Create New Category
      newRecord.id =
          await CategoryRepository.instance.createCategory(newRecord);

      // Update All Data list
      CategoryController.instance.addItemToLists(newRecord);
      update();

      // Reset Form + close loader
      resetFields();
      TFullScreenLoader.stopLoading();

      // Success Message
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
