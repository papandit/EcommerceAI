import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../common/widgets/containers/rounded_container.dart';
import '../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../common/widgets/layouts/templates/site_layout.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/luxe_edit/luxe_edit_controller.dart';

class LuxeEditScreen extends StatelessWidget {
  const LuxeEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
      desktop: LuxeEditView(),
      tablet: LuxeEditView(),
      mobile: LuxeEditView(),
    );
  }
}

class LuxeEditView extends StatelessWidget {
  const LuxeEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LuxeEditController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TBreadcrumbsWithHeading(
                  returnToPreviousScreen: false,
                  heading: 'Luxe Edit Section',
                  breadcrumbItems: ['Luxe Edit']),
              const SizedBox(height: TSizes.spaceBtwSections),
              Obx(
                () => controller.loading.value
                    ? const Padding(
                        padding: EdgeInsets.all(60),
                        child:
                            Center(child: CircularProgressIndicator()),
                      )
                    : TRoundedContainer(
                        width: 700,
                        padding: const EdgeInsets.all(TSizes.defaultSpace),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Background Banner',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            Obx(
                              () => GestureDetector(
                                onTap: controller.pickBackground,
                                child: TRoundedImage(
                                  width: 640,
                                  height: 220,
                                  backgroundColor: TColors.primaryBackground,
                                  image: controller.backgroundImage.value
                                          .isNotEmpty
                                      ? controller.backgroundImage.value
                                      : TImages.defaultImage,
                                  imageType: controller
                                          .backgroundImage.value.isNotEmpty
                                      ? ImageType.network
                                      : ImageType.asset,
                                ),
                              ),
                            ),
                            TextButton(
                                onPressed: controller.pickBackground,
                                child: const Text('Select Background Image')),
                            const SizedBox(height: TSizes.spaceBtwInputFields),
                            TextField(
                              controller: controller.titleC,
                              decoration: const InputDecoration(
                                  labelText: 'Title',
                                  hintText: 'e.g. LUXE EDIT'),
                            ),
                            const SizedBox(height: TSizes.spaceBtwInputFields),
                            TextField(
                              controller: controller.subtitleC,
                              decoration: const InputDecoration(
                                  labelText: 'Subtitle',
                                  hintText:
                                      'e.g. A spectacular assortment of styles'),
                            ),
                            const SizedBox(height: TSizes.spaceBtwInputFields),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller.buttonTextC,
                                    decoration: const InputDecoration(
                                        labelText: 'Button Text',
                                        hintText: 'e.g. Shop Now'),
                                  ),
                                ),
                                const SizedBox(width: TSizes.spaceBtwItems),
                                Expanded(
                                  child: TextField(
                                    controller: controller.buttonLinkC,
                                    decoration: const InputDecoration(
                                        labelText: 'Button Link (optional)',
                                        hintText: '/all-products'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            Obx(
                              () => CheckboxMenuButton(
                                value: controller.isActive.value,
                                onChanged: (v) =>
                                    controller.isActive.value = v ?? false,
                                child: const Text('Active (show on storefront)'),
                              ),
                            ),
                            const SizedBox(
                                height: TSizes.spaceBtwSections),
                            Text('Four Tiles',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            Wrap(
                              spacing: TSizes.spaceBtwItems,
                              runSpacing: TSizes.spaceBtwItems,
                              children: List.generate(
                                  4, (i) => _tileEditor(context, controller, i)),
                            ),
                            const SizedBox(
                                height: TSizes.spaceBtwSections),
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: controller.saving.value
                                      ? null
                                      : controller.save,
                                  child: controller.saving.value
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Text('Save Luxe Edit'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tileEditor(
      BuildContext context, LuxeEditController controller, int i) {
    return SizedBox(
      width: 300,
      child: TRoundedContainer(
        padding: const EdgeInsets.all(TSizes.md),
        backgroundColor: TColors.primaryBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tile ${i + 1}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TSizes.sm),
            Obx(
              () => GestureDetector(
                onTap: () => controller.pickTile(i),
                child: TRoundedImage(
                  width: 268,
                  height: 150,
                  backgroundColor: TColors.white,
                  image: controller.tileImages[i].value.isNotEmpty
                      ? controller.tileImages[i].value
                      : TImages.defaultImage,
                  imageType: controller.tileImages[i].value.isNotEmpty
                      ? ImageType.network
                      : ImageType.asset,
                ),
              ),
            ),
            TextButton(
                onPressed: () => controller.pickTile(i),
                child: const Text('Select Image')),
            TextField(
              controller: controller.tileLabelC[i],
              decoration: const InputDecoration(
                  labelText: 'Label', hintText: 'e.g. Bridesmaid Edit'),
            ),
            const SizedBox(height: TSizes.sm),
            TextField(
              controller: controller.tileLinkC[i],
              decoration: const InputDecoration(
                  labelText: 'Link (optional)', hintText: '/all-products'),
            ),
          ],
        ),
      ),
    );
  }
}
