import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/banners/banners_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../media/controllers/media_controller.dart';
import '../../models/banner_model.dart';
import 'banner_controller.dart';

class CreateBannerController extends GetxController {
  static CreateBannerController get instance => Get.find();

  final imageURL = ''.obs;
  final loading = false.obs;
  final isActive = true.obs;
  final RxString targetScreen = AppScreens.allAppScreenItems[0].obs;
  final formKey = GlobalKey<FormState>();

  // Optional promo overlay fields (title / subtitle / Shop Now button).
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final buttonTextController = TextEditingController();
  final buttonLinkController = TextEditingController();

  /// Pick an image directly from the device (file dialog → upload → preview).
  void pickImage() async {
    final url = await Get.put(MediaController()).pickAndUploadImage(
        MediaCategory.banners,
        onPreview: (b) => imageURL.value = b);
    if (url != null && url.isNotEmpty) imageURL.value = url;
  }

  /// Register new Banner
  Future<void> createBanner() async {
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
      // Firebase Storage never finished (usually because Storage rules are not
      // published) and would render as a broken image on the storefront.
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

      // Map Data
      final newRecord = BannerModel(
        id: '',
        active: isActive.value,
        imageUrl: imageURL.value,
        targetScreen: targetScreen.value,
        title: titleController.text.trim(),
        subtitle: subtitleController.text.trim(),
        buttonText: buttonTextController.text.trim(),
        buttonLink: buttonLinkController.text.trim(),
      );

      // Call Repository to Create New Banner and update Id
      newRecord.id = await BannerRepository.instance.createBanner(newRecord);

      // Update All Data list
      BannerController.instance.addItemToLists(newRecord);

      // Remove Loader and redirect to the Banners list.
      TFullScreenLoader.stopLoading();
      Get.offNamed(TRoutes.banners);

      // Success Message
      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'New Record has been added.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
