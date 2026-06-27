import 'package:cwt_ecommerce_admin_panel/data/repositories/otherbrands/other_brand_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/models/othre_brand_category_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../media/controllers/media_controller.dart';
import '../../../media/models/image_model.dart';
import '../../models/other_brand_model.dart';
import '../../models/other_category_model.dart';
import 'other_brand_controller.dart';

class OtherCreateBrandController extends GetxController {
  static OtherCreateBrandController get instance => Get.find();

  final loading = false.obs;
  RxString imageURL = ''.obs;
  RxString departmentname = ''.obs;
  RxString subdepartmentname = ''.obs;
  RxString about = ''.obs;
  final isFeatured = false.obs;
  final name = TextEditingController().obs;
  final formKey = GlobalKey<FormState>();
  final List<OtherCategoryModel> selectedCategories =
      <OtherCategoryModel>[].obs;

  /// Toggle Category Selection
  void toggleSelection(OtherCategoryModel category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }

    update();
  }

  /// Method to reset fields
  void resetFields() {
    name.value.clear();
    departmentname.close();
    loading(false);
    isFeatured(false);
    imageURL.value = '';
    selectedCategories.clear();
  }

  /// Pick Thumbnail Image from Media
  void pickImage() async {
    final controller = Get.put(MediaController());
    List<ImageModel>? selectedImages = await controller.selectImagesFromMedia();

    // Handle the selected images
    if (selectedImages != null && selectedImages.isNotEmpty) {
      // Set the selected image to the main image or perform any other action
      ImageModel selectedImage = selectedImages.first;
      // Update the main image using the selectedImage
      imageURL.value = selectedImage.url;
    }
  }

  /// Register new Brand
  Future<void> createBrand(
      {required String category1,
      required String about,
      subcategory,
      imageUrl}) async {
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
      final newRecord = OtherBrandModel(
          id: '',
          // productsCount: 0,
          // image: imageURL.value,
          name: name.value.text.trim(),
          createdAt: DateTime.now(),
          category: category1,
          subcategory: subcategory,
          about: about,
          image: imageUrl
          // isFeatured: isFeatured.value,
          );

      // Call Repository to Create New Brand
      newRecord.id = await OtherBrandRepository.instance.createBrand(newRecord);

      // Register brand categories if any
      if (selectedCategories.isNotEmpty) {
        if (newRecord.id.isEmpty) {
          throw 'Error storing relational data. Try again';
        }

        // Loop selected Brand Categories
        for (var category in selectedCategories) {
          // Map Data
          final brandCategory = OtherBrandCategoryModel(
              brandId: newRecord.id, categoryId: category.id);
          await OtherBrandRepository.instance
              .createBrandCategory(brandCategory);
        }

        newRecord.brandCategories ??= [];
        newRecord.brandCategories!.addAll(selectedCategories);
      }

      OtherBrandController.instance.addItemToLists(newRecord);

      update();

      resetFields();

      TFullScreenLoader.stopLoading();
      Get.back();
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
