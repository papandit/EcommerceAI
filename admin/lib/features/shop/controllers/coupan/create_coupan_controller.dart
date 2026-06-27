import 'package:cwt_ecommerce_admin_panel/data/repositories/coupan/coupan_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/coupan/coupan_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/category_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/coupan_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';

class CreateCoupanController extends GetxController {
  static CreateCoupanController get instance => Get.find();

  final selectedParent = CategoryModel.empty().obs;
  final loading = false.obs;
  final isActive = false.obs;
  final name = TextEditingController();
  final percentage = TextEditingController();
  final formKey = GlobalKey<FormState>();
  CoupanModel? coupan;

  /// Method to reset fields
  void resetFields() {
    selectedParent(CategoryModel.empty());
    loading(false);
    isActive(false);
    name.clear();
    percentage.clear();
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

      final newRecord = CoupanModel(
        id: '',
        name: name.text.trim(),
        percentage: percentage.text.trim(),
        createdAt: DateTime.now(),
        isActive: isActive.value,
      );
//=============================================================================
      // Call Repository to Create New Category and get the unique ID
      // final uniqueId =
      //     await CoupanRepository.instance.createCategory(newRecord);

      // // Update the name of the new record with the unique ID
      // newRecord.name = uniqueId;

      // // Update the record in Firestore with the new name
      // await CoupanRepository.instance
      //     .updateCategoryName(uniqueId, newRecord.name);

      // // Update All Data list
      // CoupanController.instance.addItemToLists(newRecord);
//=============================================================================
      // Call Repository to Create New Category
      newRecord.id = await CoupanRepository.instance.createCategory(newRecord);

      // Update All Data list
      CoupanController.instance.addItemToLists(newRecord);

      resetFields();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Success Message & Redirect
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap11', message: e.toString());
    }
  }
}
