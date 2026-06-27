import 'package:cwt_ecommerce_admin_panel/features/shop/models/brand_category_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/brands/brand_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../media/controllers/media_controller.dart';
import '../../models/brand_model.dart';
import '../../models/category_model.dart';
import 'brand_controller.dart';

class CreateBrandController extends GetxController {
  static CreateBrandController get instance => Get.find();

  final loading = false.obs;
  RxString imageURL = ''.obs;
  final isFeatured = false.obs;
  final name = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final List<CategoryModel> selectedCategories = <CategoryModel>[].obs;

  /// Toggle Category Selection
  void toggleSelection(CategoryModel category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }

    update();
  }

  /// Method to reset fields
  void resetFields() {
    name.clear();
    loading(false);
    isFeatured(false);
    imageURL.value = '';
    selectedCategories.clear();
  }

  /// Pick a brand image directly from the device (file dialog → upload).
  void pickImage() async {
    final url = await Get.put(MediaController()).pickAndUploadImage(
        MediaCategory.brands,
        onPreview: (b) => imageURL.value = b);
    if (url != null && url.isNotEmpty) imageURL.value = url;
  }

  /// Register new Brand
  Future<void> createBrand() async {
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
      final newRecord = BrandModel(
        id: '',
        productsCount: 0,
        image: imageURL.value,
        name: name.text.trim(),
        createdAt: DateTime.now(),
        isFeatured: isFeatured.value,
      );

      // Call Repository to Create New Brand
      newRecord.id = await BrandRepository.instance.createBrand(newRecord);

      // Register brand categories if any
      if (selectedCategories.isNotEmpty) {
        if (newRecord.id.isEmpty) {
          throw 'Error storing relational data. Try again';
        }

        // Loop selected Brand Categories
        for (var category in selectedCategories) {
          // Map Data
          final brandCategory = BrandCategoryModel(
              brandId: newRecord.id, categoryId: category.id);
          await BrandRepository.instance.createBrandCategory(brandCategory);
        }

        newRecord.brandCategories ??= [];
        newRecord.brandCategories!.addAll(selectedCategories);
      }

      // Update All Data list
      BrandController.instance.addItemToLists(newRecord);

      // Update UI Listeners
      update();

      // Reset Form
      resetFields();

      // Remove Loader
      TFullScreenLoader.stopLoading();
      Get.back();
      // Success Message & Redirect
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
