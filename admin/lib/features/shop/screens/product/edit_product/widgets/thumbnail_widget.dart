import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../controllers/product/product_images_controller.dart';

class ProductThumbnailImage extends StatelessWidget {
  const ProductThumbnailImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ProductImagesController controller = Get.put(ProductImagesController());

    return TRoundedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Thumbnail Text
          Text('Product Thumbnail', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Container for Product Thumbnail
          TRoundedContainer(
            height: 300,
            backgroundColor: TColors.primaryBackground,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Thumbnail Image
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Obx(
                      //   () => TRoundedImage(
                      //     width: 220,
                      //     height: 220,
                      //     image: controller.selectedThumbnailImageUrl.value ?? TImages.defaultSingleImageIcon,
                      //     memoryImage: controller.selectedThumbnailImageToDisplay.value,
                      //     imageType: controller.selectedThumbnailImageToDisplay.value != null
                      //         ? ImageType.memory
                      //         : controller.selectedThumbnailImageUrl.value != null
                      //             ? ImageType.network
                      //             : ImageType.asset,
                      //   ),
                      // ),
                    ],
                  ),

                  // Add Thumbnail Button
                  SizedBox(
                    width: 200,
                    child: OutlinedButton(
                      onPressed: () => controller.selectThumbnailImage(),
                      child: const Text('Add Thumbnail'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
