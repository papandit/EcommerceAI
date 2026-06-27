import 'package:get/get.dart';

import '../../../../utils/constants/enums.dart';
import '../../../media/controllers/media_controller.dart';
import '../../models/product_variation_model.dart';

class ProductImagesController extends GetxController {
  // Singleton instance
  static ProductImagesController get instance => Get.find();

  // Rx Observables for the selected thumbnail image
  Rx<String?> selectedThumbnailImageUrl = Rx<String?>(null);

  // Lists to store additional product images
  final RxList<String> additionalProductImagesUrls = <String>[].obs;

  /// Function to remove Product image
  Future<void> removeImage(int index) async {
    additionalProductImagesUrls.removeAt(index);
  }

  /// Pick the thumbnail directly from the device (file dialog → upload).
  void selectThumbnailImage() async {
    final url = await Get.put(MediaController()).pickAndUploadImage(
        MediaCategory.products,
        onPreview: (b) => selectedThumbnailImageUrl.value = b);
    if (url != null && url.isNotEmpty) selectedThumbnailImageUrl.value = url;
  }

  /// Pick a variation image directly from the device.
  void selectVariationImage(ProductVariationModel variation) async {
    final url = await Get.put(MediaController()).pickAndUploadImage(
        MediaCategory.products,
        onPreview: (b) => variation.image.value = b);
    if (url != null && url.isNotEmpty) variation.image.value = url;
  }

  /// Pick multiple gallery images directly from the device (file dialog →
  /// upload each) and append them to the gallery.
  void selectMultipleProductImages() async {
    final urls = await Get.put(MediaController())
        .pickAndUploadMultipleImages(MediaCategory.products);
    for (final u in urls) {
      if (u.isNotEmpty && !additionalProductImagesUrls.contains(u)) {
        additionalProductImagesUrls.add(u);
      }
    }
  }
}
