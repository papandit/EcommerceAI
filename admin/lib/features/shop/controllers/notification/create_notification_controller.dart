import 'package:cwt_ecommerce_admin_panel/data/repositories/coupan/coupan_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/coupan/coupan_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/category_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/coupan_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';

class CreateNotificationController extends GetxController {
  static CreateNotificationController get instance => Get.find();

  final selectedParent = CategoryModel.empty().obs;
  final loading = false.obs;
  final isActive = false.obs;
  final title = TextEditingController();
  final descriptions = TextEditingController();
  final formKey = GlobalKey<FormState>();

  /// Method to reset fields
  void resetFields() {
    selectedParent(CategoryModel.empty());
    loading(false);
    isActive(false);
    title.clear();
    descriptions.clear();
  }

  /// Register new Category
  Future<void> createCoupan() async {
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
      final newRecord = CoupanModel(
        id: '',
        name: title.text.trim(),
        percentage: descriptions.text.trim(),
        createdAt: DateTime.now(),
        isActive: isActive.value,
      );

      // Call Repository to Create New Category
      newRecord.id = await CoupanRepository.instance.createCategory(newRecord);

      // Update All Data list
      CoupanController.instance.addItemToLists(newRecord);

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
}
