import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/banner/banner_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/banners/banners_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../media/controllers/media_controller.dart';
import '../../models/banner_model.dart';

class EditBannerController extends GetxController {
  static EditBannerController get instance => Get.find();

  final imageURL = ''.obs;
  final loading = false.obs;
  final isActive = false.obs;
  final targetScreen = '/on-boarding'.obs;
  final formKey = GlobalKey<FormState>();
  final repository = Get.put(BannerRepository());

  // Optional promo overlay fields.
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final buttonTextController = TextEditingController();
  final buttonLinkController = TextEditingController();

  /// Init Data
  void init(BannerModel banner) {
    imageURL.value = banner.imageUrl;
    isActive.value = banner.active;
    targetScreen.value = banner.targetScreen;
    titleController.text = banner.title;
    subtitleController.text = banner.subtitle;
    buttonTextController.text = banner.buttonText;
    buttonLinkController.text = banner.buttonLink;
  }

  /// Pick an image directly from the device (file dialog → upload → preview).
  void pickImage() async {
    final url = await Get.put(MediaController()).pickAndUploadImage(
        MediaCategory.banners,
        onPreview: (b) => imageURL.value = b);
    if (url != null && url.isNotEmpty) imageURL.value = url;
  }

  /// Register new Banner
  Future<void> updateBanner(BannerModel banner) async {
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

      // Require a real (uploaded) image. A blob:/data: URL means the upload to
      // Firebase Storage never finished and would render broken on the front.
      final img = imageURL.value.trim();
      if (img.isEmpty) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
            title: 'Add an image',
            message: 'Please upload a banner image before saving.');
        return;
      }
      if (img.startsWith('blob:') || img.startsWith('data:')) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
            title: 'Image upload not finished',
            message:
                'The banner image did not upload to storage. Re-upload it (and make sure Firebase Storage rules are published), then save.');
        return;
      }

      // Map Data (always persist — covers image, status and promo text edits)
      banner.imageUrl = imageURL.value;
      banner.targetScreen = targetScreen.value;
      banner.active = isActive.value;
      banner.title = titleController.text.trim();
      banner.subtitle = subtitleController.text.trim();
      banner.buttonText = buttonTextController.text.trim();
      banner.buttonLink = buttonLinkController.text.trim();

      // Call Repository to Update
      await repository.updateBanner(banner);

      // Update the List
      BannerController.instance.updateItemFromLists(banner);

      // Update UI Listeners
      update();

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
