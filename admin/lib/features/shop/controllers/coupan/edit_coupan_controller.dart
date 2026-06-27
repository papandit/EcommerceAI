// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, avoid_print

import 'package:cwt_ecommerce_admin_panel/data/repositories/coupan/coupan_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/coupan/coupan_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/coupan_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';

class EditCoupanController extends GetxController {
  static EditCoupanController get instance => Get.find();

  final selectedParent = CoupanModel.empty().obs;
  final loading = false.obs;
  final isActive = false.obs;
  final name = TextEditingController();
  final percentage = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final repository = Get.put(CoupanRepository());

  void init(CoupanModel coupan) {
    name.text = coupan.name;
    percentage.text = coupan.percentage;
    isActive.value = coupan.isActive;
  }

  /// Method to reset fields
  void resetFields() {
    selectedParent(CoupanModel.empty());
    loading(false);
    isActive(false);
    name.clear();
    percentage.clear();
  }

  /// Register new Category
  Future<void> updateCategory(CoupanModel coupan) async {
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
      coupan.name = name.text.trim();
      coupan.percentage = percentage.text.trim();
      coupan.isActive = isActive.value;
      coupan.updatedAt = DateTime.now();

      // Call Repository to Create New User
      await repository.updateCategory(coupan);

      // Update All Data list
      CoupanController.instance.updateItemFromLists(coupan);

      // Reset Form
      resetFields();

      // Remove Loader
      TFullScreenLoader.stopLoading();
      Get.back();
      // Success Message & Redirect
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'Your Record has been updated.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
