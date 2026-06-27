// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, avoid_print

// import 'package:cwt_ecommerce_admin_panel/data/repositories/review/review_repository.dart';
// import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/review/review_controller.dart';
// import 'package:cwt_ecommerce_admin_panel/features/shop/models/review_model.dart';
import 'package:cwt_ecommerce_admin_panel/common/review/review_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/review_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';

import 'review_controller.dart';

class EditReviewController extends GetxController {
  static EditReviewController get instance => Get.find();

  final selectedParent = ReviewModel.empty().obs;
  final loading = false.obs;
  final name = TextEditingController();
  final email = TextEditingController();
  final message = TextEditingController();
  final phonenumber = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final repository = Get.put(ReviewRepository());

  void init(ReviewModel review) {
    name.text = review.name;
    message.text = review.message;
    phonenumber.text = review.phonenumber;
    email.text = review.email;
  }

  /// Method to reset fields
  void resetFields() {
    selectedParent(ReviewModel.empty());
    loading(false);

    name.clear();
    email.clear();
    message.clear();
    phonenumber.clear();
  }

  /// Register new Category
  Future<void> updateCategory(ReviewModel review) async {
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
      review.name = name.text.trim();
      review.email = email.text.trim();
      review.message = message.text.trim();
      review.phonenumber = phonenumber.text.trim();

      review.updatedAt = DateTime.now();

      // Call Repository to Create New User
      await repository.updateCategory(review);

      // Update All Data list
      ReviewController.instance.updateItemFromLists(review);

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
