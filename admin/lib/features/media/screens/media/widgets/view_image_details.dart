import 'package:clipboard/clipboard.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/images/t_rounded_image.dart';
import 'package:cwt_ecommerce_admin_panel/features/media/controllers/media_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/enums.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/device/device_utility.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../models/image_model.dart';

class ImagePopup extends StatelessWidget {
  // The image model to display detailed information about.
  final ImageModel image;

  // Constructor for the ImagePopup class.
  const ImagePopup({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        // Define the shape of the dialog.
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.borderRadiusLg)),
        child: TRoundedContainer(
          // Set the width of the rounded container based on the screen size.
          width: TDeviceUtils.isDesktopScreen(context)
              ? MediaQuery.of(context).size.width * 0.4
              : double.infinity,
          padding: const EdgeInsets.all(TSizes.spaceBtwItems),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the image with an option to close the dialog.
              SizedBox(
                child: Stack(
                  children: [
                    // Display the image with rounded container.
                    TRoundedContainer(
                      backgroundColor: TColors.primaryBackground,
                      child: TRoundedImage(
                        image: image.url,
                        applyImageRadius: true,
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: TDeviceUtils.isDesktopScreen(context)
                            ? MediaQuery.of(context).size.width * 0.4
                            : double.infinity,
                        imageType: ImageType.network,
                      ),
                    ),
                    // Close icon button positioned at the top-right corner.
                    Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Iconsax.close_circle)))
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Display various metadata about the image.
              // Includes image name, path, type, size, creation and modification dates, and URL.
              // Also provides an option to copy the image URL.
              Row(
                children: [
                  Expanded(
                      child: Text('Image Name:',
                          style: Theme.of(context).textTheme.bodyLarge)),
                  Expanded(
                      flex: 3,
                      child: Text(image.filename,
                          style: Theme.of(context).textTheme.titleLarge)),
                ],
              ),

              // Display the image URL with an option to copy it.
              Row(
                children: [
                  Expanded(
                      child: Text('Image URL:',
                          style: Theme.of(context).textTheme.bodyLarge)),
                  Expanded(
                    flex: 2,
                    child: Text(image.url,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        FlutterClipboard.copy(image.url).then((value) =>
                            TLoaders.customToast(message: 'URL copied!'));
                      },
                      child: const Text('Copy URL'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Display a button to delete the image.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextButton(
                      onPressed: () => MediaController.instance
                          .removeCloudImageConfirmation(image),
                      child: const Text('Delete Image',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
