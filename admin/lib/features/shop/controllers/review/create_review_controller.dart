import 'package:cwt_ecommerce_admin_panel/common/review/review_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/category_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/review_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import 'review_controller.dart';

class CreateReviewController extends GetxController {
  static CreateReviewController get instance => Get.find();

  final selectedParent = CategoryModel.empty().obs;
  final loading = false.obs;
  final isActive = false.obs;
  final name = TextEditingController();
  final email = TextEditingController();
  final phonenumber = TextEditingController();
  final message = TextEditingController();
  final percentage = TextEditingController();
  final formKey = GlobalKey<FormState>();
  ReviewModel? review;

  /// Method to reset fields
  void resetFields() {
    selectedParent(CategoryModel.empty());
    loading(false);
    name.clear();
    email.clear();
    phonenumber.clear();
    message.clear();
    percentage.clear();
  }

  /// Register new Category
  Future<void> createReview() async {
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

      final newRecord = ReviewModel(
        id: '',
        name: name.text.trim(),
        email: email.text.trim(),
        message: message.text.trim(),
        phonenumber: phonenumber.text.trim(),
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      newRecord.id = await ReviewRepository.instance.createCategory(newRecord);

      // Update All Data list
      ReviewController.instance.addItemToLists(newRecord);

      resetFields();

      // Remove Loader
      TFullScreenLoader.stopLoading();
      Get.back();
      // Success Message & Redirect
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap11', message: e.toString());
    }
  }
}
