import 'dart:typed_data';

import 'package:cwt_ecommerce_admin_panel/features/media/models/image_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/media_controller.dart';
import 'folder_dropdown.dart';

class MediaUploader extends StatelessWidget {
  const MediaUploader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MediaController());
    return Obx(
      () => controller.showImagesUploaderSection.value
          ? Column(
              children: [
                TRoundedContainer(
                  height: 250,
                  showBorder: true,
                  borderColor: TColors.borderPrimary,
                  backgroundColor: TColors.primaryBackground,
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            DropzoneView(
                              mime: const ['image/jpeg', 'image/png'],
                              cursor: CursorType.Default,
                              operation: DragOperation.copy,
                              onCreated: (ctrl) => controller.dropzoneController = ctrl,
                              onLoaded: () => print('Zone loaded'),
                              onError: (ev) => print('Zone error: $ev'),
                              onHover: () {
                                print('Zone hovered');
                              },
                              onLeave: () {
                                print('Zone left');
                              },
                              onDrop: (ev) async {
                                if (ev is html.File) {
                                  final bytes = await controller.dropzoneController.getFileData(ev);
                                  final image = ImageModel(
                                    url: '',
                                    file: ev,
                                    folder: '',
                                    filename: ev.name,
                                    localImageToDisplay: Uint8List.fromList(bytes),
                                  );
                                  controller.selectedImagesToUpload.add(image);
                                } else if (ev is String) {
                                  print('Zone drop: $ev');
                                } else {
                                  print('Zone unknown type: ${ev.runtimeType}');
                                }
                              },
                              onDropInvalid: (ev) => print('Zone invalid MIME: $ev'),
                              onDropMultiple: (ev) async {
                                print('Zone drop multiple: $ev');
                              },
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(TImages.defaultMultiImageIcon, width: 50, height: 50),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                const Text('Drag and Drop Images here'),
                                const SizedBox(height: TSizes.spaceBtwItems),
                                OutlinedButton(onPressed: () => controller.selectLocalImages(), child: const Text('Select Images')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Show locally selected images
                if (controller.selectedImagesToUpload.isNotEmpty)
                  TRoundedContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('Select Folder', style: Theme.of(context).textTheme.headlineSmall),
                                const SizedBox(width: TSizes.spaceBtwItems),
                                MediaFolderDropdown(
                                  onChanged: (MediaCategory? newValue) {
                                    if (newValue != null) {
                                      controller.selectedPath.value = newValue;
                                      controller.getMediaImages();
                                    }
                                  },
                                )
                              ],
                            ),
                            Row(
                              children: [
                                TextButton(onPressed: () => controller.selectedImagesToUpload.clear(), child: const Text('Remove All')),
                                const SizedBox(width: TSizes.spaceBtwItems),
                                TDeviceUtils.isMobileScreen(context)
                                    ? const SizedBox.shrink()
                                    : SizedBox(
                                        width: TSizes.buttonWidth,
                                        child: ElevatedButton(
                                          onPressed: () => controller.uploadImagesConfirmation(),
                                          child: const Text('Upload'),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: TSizes.spaceBtwSections),
                        Wrap(
                          alignment: WrapAlignment.start,
                          spacing: TSizes.spaceBtwItems / 2,
                          runSpacing: TSizes.spaceBtwItems / 2,
                          children: controller.selectedImagesToUpload
                              .where((image) => image.localImageToDisplay != null)
                              .map((element) => TRoundedImage(
                                    width: 90,
                                    height: 90,
                                    padding: TSizes.sm,
                                    imageType: ImageType.memory,
                                    memoryImage: element.localImageToDisplay,
                                    backgroundColor: TColors.primaryBackground,
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: TSizes.spaceBtwSections),
                        TDeviceUtils.isMobileScreen(context)
                            ? SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => controller.uploadImagesConfirmation(),
                                  child: const Text('Upload'),
                                ),
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                  ),
                const SizedBox(height: TSizes.spaceBtwSections),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
