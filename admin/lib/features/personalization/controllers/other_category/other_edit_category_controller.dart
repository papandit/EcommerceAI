// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, avoid_print

import 'package:cwt_ecommerce_admin_panel/data/repositories/othercategories/other_category_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/other_category/other_category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/models/other_category_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../media/controllers/media_controller.dart';
import '../../../media/models/image_model.dart';

class OtherEditCategoryController extends GetxController {
  static OtherEditCategoryController get instance => Get.find();

  final selectedParent = OtherCategoryModel.empty().obs;
  final loading = false.obs;
  RxString imageURL = ''.obs;
  final isFeatured = false.obs;
  final name = TextEditingController();
  final parentname = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final repository = Get.put(OtherCategoryRepository());
  List sub_category_data = [].obs;

  /// Init Data
  void init(OtherCategoryModel category) {
    // if (category.parentId!.isNotEmpty) {
    //   selectedParent.value = CategoryController.instance.allItems
    //       .where((c) => c.id == category.parentId)
    //       .single;
    // }
    name.text = category.name;
    // sub_category_data = category.parentId!;
    print("parent sub ${sub_category_data}");
    print("parent ${category.parentId}");
    sub_category_data.addAll(category.parentId!);
    print("parent subnew  ${sub_category_data}");
    isFeatured.value = category.isFeatured;
    imageURL.value = category.image;
  }

  /// Method to reset fields
  void resetFields() {
    selectedParent(OtherCategoryModel.empty());
    loading(false);
    isFeatured(false);
    name.clear();
    sub_category_data.clear();
    imageURL.value = '';
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

  /// Register new Category
  Future<void> updateCategory(OtherCategoryModel category) async {
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
      category.name = name.text.trim();
      category.image = imageURL.value;
      category.parentId = sub_category_data;
      category.isFeatured = isFeatured.value;
      category.updatedAt = DateTime.now();

      // Call Repository to Create New User
      await repository.updateCategory(category);

      // Update All Data list
      OtherCategoryController.instance.updateItemFromLists(category);

      // Reset Form
      resetFields();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Success Message & Redirect
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'Your Record has been updated.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
