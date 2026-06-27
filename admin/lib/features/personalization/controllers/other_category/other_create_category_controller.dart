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

class OtherCreateCategoryController extends GetxController {
  static OtherCreateCategoryController get instance => Get.find();

  final selectedParent = OtherCategoryModel.empty().obs;
  final loading = false.obs;
  final isFeatured = false.obs;
  final name = TextEditingController();
  final parentname = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RxString imageURL = ''.obs;
  List sub_category_data = [].obs;
  final departmentname = TextEditingController();
  // List department_data = [].obs;

  /// Method to reset fields
  void resetFields() {
    selectedParent(OtherCategoryModel.empty());
    loading(false);
    isFeatured(false);
    name.clear();
    sub_category_data.clear();
    // department_data.clear();
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
      if (!formKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // sub_category_data = ["one", "two", "three"];

      // Map Data
      final newRecord = OtherCategoryModel(
        id: '',
        image: imageURL.value,
        name: name.text.trim(),
        createdAt: DateTime.now(),
        isFeatured: isFeatured.value,
        parentId: sub_category_data,
      );

      // Call Repository to Create New Category
      newRecord.id =
          await OtherCategoryRepository.instance.createCategory(newRecord);

      // Update All Data list
      OtherCategoryController.instance.addItemToLists(newRecord);

      // Reset Form
      resetFields();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Success Message & Redirect
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  // Future<void> createDepartment() async {
  //   try{
  //     TFullScreenLoader.popUpCircular();
  //         final isConnected = await NetworkManager.instance.isConnected();
  //     if (!isConnected) {
  //       TFullScreenLoader.stopLoading();
  //       return;
  //     }

  //     if (!formKey.currentState!.validate()) {
  //       TFullScreenLoader.stopLoading();
  //       return;
  //     }

  //   }
  // }

  // Future<void> createParentCategory() async {
  //   try {
  //     // Start Loading
  //     TFullScreenLoader.popUpCircular();

  //     // Check Internet Connectivity
  //     final isConnected = await NetworkManager.instance.isConnected();
  //     if (!isConnected) {
  //       TFullScreenLoader.stopLoading();
  //       return;
  //     }

  //     // Form Validation
  //     if (!formKey.currentState!.validate()) {
  //       TFullScreenLoader.stopLoading();
  //       return;
  //     }

  //     // Map Data
  //     final newRecord = ParentCategoryModel(
  //       id: '',
  //       parentname: parentname.text.trim(),
  //     );

  //     // Call Repository to Create New Category
  //     newRecord.id =
  //         await CategoryRepository.instance.createParentCategory(newRecord);

  //     // Update All Data list
  //     CategoryController.instance.addItemToLists(newRecord as CategoryModel);

  //     // Reset Form
  //     resetFields();

  //     // Remove Loader
  //     TFullScreenLoader.stopLoading();

  //     // Success Message & Redirect
  //     TLoaders.successSnackBar(
  //         title: 'Congratulations', message: 'New Record has been added.');
  //   } catch (e) {
  //     TFullScreenLoader.stopLoading();
  //     TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
  //   }
  // }
}
