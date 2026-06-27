// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, avoid_print

import 'package:cwt_ecommerce_admin_panel/data/repositories/department/department_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/department/department_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/depaerment_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';

class EditDepartMentController extends GetxController {
  static EditDepartMentController get instance => Get.find();

  final selectedParent = DepartmentModel.empty().obs;
  final loading = false.obs;
  RxString imageURL = ''.obs;
  final isFeatured = false.obs;
  final last_name = "".obs;
  final name = TextEditingController();
  final parentname = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final repository = Get.put(DepartMentRepository());
  List sub_category_data = [].obs;
  RxString Forupdateid = ''.obs;

  /// Init Data
  void init(DepartmentModel category) {
    // if (category.parentId!.isNotEmpty) {
    //   selectedParent.value = CategoryController.instance.allItems
    //       .where((c) => c.id == category.parentId)
    //       .single;
    // }
    last_name.value = category.deptName;
    name.text = category.deptName;
  }

  /// Method to reset fields
  void resetFields() {
    selectedParent(DepartmentModel.empty());
    loading(false);
    isFeatured(false);
    name.clear();
    sub_category_data.clear();
    imageURL.value = '';
  }

  // /// Pick Thumbnail Image from Media
  // void pickImage() async {
  //   final controller = Get.put(MediaController());
  //   List<ImageModel>? selectedImages = await controller.selectImagesFromMedia();

  //   // Handle the selected images
  //   if (selectedImages != null && selectedImages.isNotEmpty) {
  //     // Set the selected image to the main image or perform any other action
  //     ImageModel selectedImage = selectedImages.first;
  //     // Update the main image using the selectedImage
  //     imageURL.value = selectedImage.url;
  //   }
  // }

  /// Register new Category
  Future<void> updateCategory(DepartmentModel category) async {
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

      category.deptName = name.text.trim();
      // category.lastname =
      //     name.text.trim().toLowerCase() == last_name.value.toLowerCase()
      //         ? ""
      //         : last_name.value;

      category.lastname =
          name.text.trim() == last_name.value ? "" : last_name.value;

      // Call Repository to Create New User
      await repository.updateCategory(category);

      // Update All Data list
      DepartMentController.instance.updateItemFromLists(category);
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
