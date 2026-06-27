// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, avoid_print

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

class EditCategoryController extends GetxController {
  static EditCategoryController get instance => Get.find();

  final selectedParent = CategoryModel.empty().obs;
  final loading = false.obs;
  RxString imageURL = ''.obs;
  final isFeatured = false.obs;
  final name = TextEditingController();
  final parentname = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final repository = Get.put(CategoryRepository());
  RxList sub_category_data = [].obs;
  RxString Forupdateid = ''.obs;

  // Guard so init() only seeds the form ONCE per category. The edit form is a
  // StatelessWidget that calls init() on every build; without this guard, every
  // rebuild reset the name + wiped any sub-category the user just added, so
  // edits never persisted ("not updated").
  String? _initializedFor;

  /// Init Data
  void init(CategoryModel category) {
    if (_initializedFor == category.id) return;
    _initializedFor = category.id;
    // if (category.parentId!.isNotEmpty) {
    //   selectedParent.value = CategoryController.instance.allItems
    //       .where((c) => c.id == category.parentId)
    //       .single;
    // }
    name.text = category.name;
    // sub_category_data = category.parentId!;
    print("parent sub ${sub_category_data}");
    print("parent ${category.parentId}");

    /// Use `assignAll` to avoid modification during build
    Future.delayed(Duration.zero, () {
      sub_category_data.assignAll(category.parentId!);
      print("parent subnew $sub_category_data");
    });
    print("parent subnew  ${sub_category_data}");
    isFeatured.value = category.isFeatured;
    imageURL.value = category.image;
  }

  /// Method to reset fields
  void resetFields() {
    selectedParent(CategoryModel.empty());
    loading(false);
    isFeatured(false);
    name.clear();
    sub_category_data.clear();
    imageURL.value = '';
    _initializedFor = null; // allow the form to re-seed on the next edit
  }

  /// Pick a category image directly from the device (file dialog → upload).
  void pickImage() async {
    final url = await Get.put(MediaController()).pickAndUploadImage(
        MediaCategory.categories,
        onPreview: (b) => imageURL.value = b);
    if (url != null && url.isNotEmpty) imageURL.value = url;
  }

  /// Register new Category
  Future<void> updateCategory(CategoryModel category) async {
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
      if (!formKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Map Data
      category.image = imageURL.value;
      category.name = name.text.trim();
      category.parentId = sub_category_data;
      category.isFeatured = isFeatured.value;
      category.updatedAt = DateTime.now();
      category.timestamp = DateTime.now().toIso8601String();

      // Call Repository to Create New User
      await repository.updateCategory(category);

      // Update All Data list
      CategoryController.instance.updateItemFromLists(category);
      Future.delayed(const Duration(seconds: 2), () {
// Here you can write your code

        update();
        // Reset Form
        resetFields();

        // Remove Loader
        TFullScreenLoader.stopLoading();
        Get.back();
        // Success Message & Redirect
        TLoaders.successSnackBar(
            title: 'Congratulations', message: 'Your Record has been updated.');
      });

      // Reset Form
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
