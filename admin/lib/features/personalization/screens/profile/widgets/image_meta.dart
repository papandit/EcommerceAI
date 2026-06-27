import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../common/widgets/images/image_uploader.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/user_controller.dart';

class ImageAndMeta extends StatelessWidget {
  const ImageAndMeta({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    return TRoundedContainer(
      padding: const EdgeInsets.symmetric(
          vertical: TSizes.lg, horizontal: TSizes.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              // User Image
              Obx(
                () => TImageUploader(
                  right: 10,
                  bottom: 20,
                  left: null,
                  width: 200,
                  height: 200,
                  circular: true,
                  // icon: Iconsax.camera,
                  loading: controller.loading.value,
                  // onIconButtonPressed: () => controller.updateProfilePicture(),
                  imageType: controller.user.value.profilePicture.isNotEmpty
                      ? ImageType.network
                      : ImageType.asset,
                  image: controller.user.value.profilePicture.isNotEmpty
                      ? controller.user.value.profilePicture
                      : TImages.user,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Obx(() => Text(controller.user.value.fullName,
                  style: Theme.of(context).textTheme.headlineLarge)),
              Obx(() => Text(controller.user.value.email)),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ],
      ),
    );
  }
}
