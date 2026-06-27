import 'dart:typed_data';

import 'package:cwt_ecommerce_admin_panel/common/widgets/loaders/circular_loader.dart';
import 'package:cwt_ecommerce_admin_panel/features/media/models/image_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/media/screens/media/widgets/media_uploader.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/enums.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/text_strings.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/dialogs.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../utils/popups/loaders.dart';
import '../../../data/repositories/media/media_repository.dart';
import '../../../data/services/api/api_client.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../screens/media/widgets/media_content.dart';

/// Controller for managing media operations
class MediaController extends GetxController {
  static MediaController get instance => Get.find();

  late DropzoneViewController dropzoneController;

  // Lists to store additional product images
  final RxBool loading = false.obs;
  final RxBool showImagesUploaderSection = false.obs;
  final Rx<MediaCategory> selectedPath = MediaCategory.folders.obs;

  final int initialLoadCount = 10;
  final int loadMoreCount = 10;

  late ListResult bannerImagesListResult;
  late ListResult productImagesListResult;
  late ListResult brandImagesListResult;
  late ListResult categoryImagesListResult;
  late ListResult userImagesListResult;

  final RxList<ImageModel> allImages = <ImageModel>[].obs;
  final RxList<ImageModel> allBannerImages = <ImageModel>[].obs;
  final RxList<ImageModel> allProductImages = <ImageModel>[].obs;
  final RxList<ImageModel> allBrandImages = <ImageModel>[].obs;
  final RxList<ImageModel> allCategoryImages = <ImageModel>[].obs;
  final RxList<ImageModel> allUserImages = <ImageModel>[].obs;

  final RxList<ImageModel> selectedImagesToUpload = <ImageModel>[].obs;
  final MediaRepository mediaRepository = MediaRepository();

  // Get Images
  void getMediaImages() async {
    try {
      loading.value = true;

      RxList<ImageModel> targetList = <ImageModel>[].obs;

      if (selectedPath.value == MediaCategory.banners &&
          allBannerImages.isEmpty) {
        targetList = allBannerImages;
      } else if (selectedPath.value == MediaCategory.brands &&
          allBrandImages.isEmpty) {
        targetList = allBrandImages;
      } else if (selectedPath.value == MediaCategory.categories &&
          allCategoryImages.isEmpty) {
        targetList = allCategoryImages;
      } else if (selectedPath.value == MediaCategory.products &&
          allProductImages.isEmpty) {
        targetList = allProductImages;
      } else if (selectedPath.value == MediaCategory.users &&
          allUserImages.isEmpty) {
        targetList = allUserImages;
      }

      final images = await mediaRepository.fetchImagesFromDatabase(
          selectedPath.value, initialLoadCount);
      targetList.assignAll(images);
      loading.value = false;
    } catch (e) {
      print("Media catch E = $e");
      loading.value = false;
      TLoaders.errorSnackBar(
          title: 'Oh Snap',
          message: 'Unable to fetch Images, Something went wrong. Try again');
    }
  }

  // Load More Images
  loadMoreMediaImages() async {
    try {
      loading.value = true;
      RxList<ImageModel> targetList = <ImageModel>[].obs;

      if (selectedPath.value == MediaCategory.banners) {
        targetList = allBannerImages;
      } else if (selectedPath.value == MediaCategory.brands) {
        targetList = allBrandImages;
      } else if (selectedPath.value == MediaCategory.categories) {
        targetList = allCategoryImages;
      } else if (selectedPath.value == MediaCategory.products) {
        targetList = allProductImages;
      } else if (selectedPath.value == MediaCategory.users) {
        targetList = allUserImages;
      }

      final images = await mediaRepository.loadMoreImagesFromDatabase(
          selectedPath.value,
          initialLoadCount,
          targetList.last.createdAt ?? DateTime.now());
      targetList.addAll(images);

      loading.value = false;
    } catch (e) {
      loading.value = false;
      TLoaders.errorSnackBar(
          title: 'Oh Snap',
          message: 'Unable to fetch Images, Something went wrong. Try again');
    }
  }

  /// Select Local Images on Button Press
  Future<void> selectLocalImages() async {
    final files = await dropzoneController
        .pickFiles(multiple: true, mime: ['image/jpeg', 'image/png']);

    if (files.isNotEmpty) {
      for (var file in files) {
        if (file is html.File) {
          final bytes = await dropzoneController.getFileData(file);
          final image = ImageModel(
            url: '',
            file: file,
            folder: '',
            filename: file.name,
            localImageToDisplay: Uint8List.fromList(bytes),
          );
          selectedImagesToUpload.add(image);
        }
      }
    }
  }

  /// Simple single-image flow used by the Banner / Luxe Edit forms:
  /// opens the OS file picker, uploads the chosen image straight to Storage +
  /// Firestore and returns its download URL — no media bottom-sheet needed.
  Future<String?> pickAndUploadImage(MediaCategory category,
      {void Function(String previewUrl)? onPreview}) async {
    html.FileUploadInputElement? input;
    try {
      input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = false
        ..style.display = 'none';
      html.document.body?.append(input);
      input.click();
      await input.onChange.first;

      final files = input.files;
      if (files == null || files.isEmpty) return null;
      final html.File file = files.first;

      // Show an INSTANT local preview while the upload runs in the background.
      if (onPreview != null) {
        try {
          onPreview(html.Url.createObjectUrlFromBlob(file));
        } catch (_) {}
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoadEnd.first;

      final result = reader.result;
      Uint8List bytes;
      if (result is Uint8List) {
        bytes = result;
      } else if (result is ByteBuffer) {
        bytes = result.asUint8List();
      } else if (result is List<int>) {
        bytes = Uint8List.fromList(result);
      } else {
        throw 'Could not read the selected file.';
      }

      // Upload to our Node/Mongo backend (replaces Firebase Storage). The
      // backend compresses to webp, stores it under /uploads and records it in
      // the Images collection, returning the absolute URL.
      final url = await ApiClient.instance.uploadImage(
        type: _backendTypeFor(category),
        bytes: bytes,
        filename: file.name,
      );

      _safeSnack('Uploaded', 'Image uploaded successfully.', error: false);
      return url;
    } catch (e) {
      _safeSnack('Upload failed', e.toString(), error: true);
      return null;
    } finally {
      input?.remove();
    }
  }

  /// Map a media category to the backend upload route segment
  /// (matches TYPE_FOLDER in the backend upload controller).
  String _backendTypeFor(MediaCategory category) {
    switch (category) {
      case MediaCategory.banners:
        return 'banner';
      case MediaCategory.brands:
        return 'brand';
      case MediaCategory.categories:
        return 'category';
      case MediaCategory.products:
        return 'product';
      case MediaCategory.users:
        return 'profile';
      default:
        return 'product';
    }
  }

  /// Show a snackbar safely. During the async file-pick flow the GetX overlay
  /// context can be unavailable ("No Overlay widget found"), so we defer to the
  /// next frame and swallow any overlay error rather than crashing.
  void _safeSnack(String title, String message, {required bool error}) {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (error) {
            TLoaders.warningSnackBar(title: title, message: message);
          } else {
            TLoaders.successSnackBar(title: title, message: message);
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  /// Pick MULTIPLE images directly from the device, upload each and return
  /// their download URLs (used by the Product create/edit gallery).
  Future<List<String>> pickAndUploadMultipleImages(
      MediaCategory category) async {
    final urls = <String>[];
    html.FileUploadInputElement? input;
    try {
      input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = true
        ..style.display = 'none';
      html.document.body?.append(input);
      input.click();
      await input.onChange.first;

      final files = input.files;
      if (files == null || files.isEmpty) return urls;

      for (final file in files) {
        try {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          await reader.onLoadEnd.first;
          final result = reader.result;
          Uint8List bytes;
          if (result is Uint8List) {
            bytes = result;
          } else if (result is ByteBuffer) {
            bytes = result.asUint8List();
          } else if (result is List<int>) {
            bytes = Uint8List.fromList(result);
          } else {
            continue;
          }
          final url = await ApiClient.instance.uploadImage(
            type: _backendTypeFor(category),
            bytes: bytes,
            filename: file.name,
          );
          urls.add(url);
        } catch (_) {}
      }
      _safeSnack('Uploaded', '${urls.length} image(s) uploaded.', error: false);
    } catch (e) {
      _safeSnack('Upload failed', e.toString(), error: true);
    } finally {
      input?.remove();
    }
    return urls;
  }

  String _storagePathFor(MediaCategory category) {
    switch (category) {
      case MediaCategory.banners:
        return TTexts.bannersStoragePath;
      case MediaCategory.brands:
        return TTexts.brandsStoragePath;
      case MediaCategory.categories:
        return TTexts.categoriesStoragePath;
      case MediaCategory.products:
        return TTexts.productsStoragePath;
      case MediaCategory.users:
        return TTexts.usersStoragePath;
      default:
        return 'Others';
    }
  }

  RxList<ImageModel>? _listForCategory(MediaCategory category) {
    switch (category) {
      case MediaCategory.banners:
        return allBannerImages;
      case MediaCategory.brands:
        return allBrandImages;
      case MediaCategory.categories:
        return allCategoryImages;
      case MediaCategory.products:
        return allProductImages;
      case MediaCategory.users:
        return allUserImages;
      default:
        return null;
    }
  }

  /// Upload Images Confirmation Popup
  void uploadImagesConfirmation() {
    if (selectedPath.value == MediaCategory.folders) {
      TLoaders.warningSnackBar(
          title: 'Select Folder',
          message: 'Please select the Folder in Order to upload the Images.');
      return;
    }

    TDialogs.defaultDialog(
      context: Get.context!,
      title: 'Upload Images',
      confirmText: 'Upload',
      onConfirm: () async => await uploadImages(),
      content:
          'Are you sure you want to upload all the Images in ${selectedPath.value.name.toUpperCase()} folder?',
    );
  }

  /// Upload Images
  Future<void> uploadImages() async {
    try {
      // Remove confirmation box
      Get.back();

      // Start Loader
      uploadImagesLoader();

      // Get the selected category
      MediaCategory selectedCategory = selectedPath.value;

      // Get the corresponding list to update
      RxList<ImageModel> targetList;

      // Check the selected category and update the corresponding list
      switch (selectedCategory) {
        case MediaCategory.banners:
          targetList = allBannerImages;
          break;
        case MediaCategory.brands:
          targetList = allBrandImages;
          break;
        case MediaCategory.categories:
          targetList = allCategoryImages;
          break;
        case MediaCategory.products:
          targetList = allProductImages;
          break;
        case MediaCategory.users:
          targetList = allUserImages;
          break;
        default:
          return;
      }

      // Upload and add images to the target list
      // Using a reverse loop to avoid 'Concurrent modification during iteration' error
      for (int i = selectedImagesToUpload.length - 1; i >= 0; i--) {
        var selectedImage = selectedImagesToUpload[i];
        final bytes = selectedImage.localImageToDisplay;

        // Upload Image to the Storage.
        // Prefer the raw bytes (reliable on Flutter Web); fall back to the
        // html.File only if bytes are somehow missing.
        late final ImageModel uploadedImage;
        if (bytes != null && bytes.isNotEmpty) {
          uploadedImage = await mediaRepository.uploadImageBytesInStorage(
            data: bytes,
            path: getSelectedPath(),
            imageName: selectedImage.filename,
          );
        } else if (selectedImage.file != null) {
          uploadedImage = await mediaRepository.uploadImageFileInStorage(
            file: selectedImage.file!,
            path: getSelectedPath(),
            imageName: selectedImage.filename,
          );
        } else {
          // Nothing to upload for this entry — skip it.
          selectedImagesToUpload.removeAt(i);
          continue;
        }

        // Upload Image to the Firestore
        uploadedImage.mediaCategory = selectedCategory.name;
        final id =
            await mediaRepository.uploadImageFileInDatabase(uploadedImage);

        uploadedImage.id = id;

        selectedImagesToUpload.removeAt(i);
        targetList.add(uploadedImage);
      }

      // Stop Loader after successful upload
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
          title: 'Images Uploaded',
          message: 'Your images have been uploaded successfully.');
    } catch (e) {
      // Stop Loader in case of an error
      TFullScreenLoader.stopLoading();
      // Surface the REAL error so storage/permission issues are diagnosable.
      TLoaders.warningSnackBar(
          title: 'Error Uploading Images', message: e.toString());
    }
  }

  /// Upload Images Loader
  void uploadImagesLoader() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Uploading Images'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(TImages.uploadingImageIllustration,
                  height: 300, width: 300),
              const SizedBox(height: TSizes.spaceBtwItems),
              const Text('Sit Tight, Your images are uploading...'),
            ],
          ),
        ),
      ),
    );
  }

  /// Get Selected Folder Path for Firebase Storage
  String getSelectedPath() {
    String path = '';
    switch (selectedPath.value) {
      case MediaCategory.banners:
        path = TTexts.bannersStoragePath;
        break;
      case MediaCategory.brands:
        path = TTexts.brandsStoragePath;
        break;
      case MediaCategory.categories:
        path = TTexts.categoriesStoragePath;
        break;
      case MediaCategory.products:
        path = TTexts.productsStoragePath;
        break;
      case MediaCategory.users:
        path = TTexts.usersStoragePath;
        break;
      default:
        path = 'Others';
    }

    return path;
  }

  /// Popup Confirmation to remove cloud image
  void removeCloudImageConfirmation(ImageModel image) {
    // Delete Confirmation
    TDialogs.defaultDialog(
      context: Get.context!,
      content: 'Are you sure you want to delete this image?',
      onConfirm: () {
        // Close the previous Dialog Image Popup
        Get.back();

        removeCloudImage(image);
      },
    );
  }

  /// Function to remove cloud image
  removeCloudImage(ImageModel image) async {
    try {
      // Close the removeCloudImageConfirmation() DDialog
      Get.back();

      // Show Loader
      Get.defaultDialog(
        title: '',
        barrierDismissible: false,
        backgroundColor: Colors.transparent,
        content: const PopScope(
            canPop: false,
            child: SizedBox(width: 150, height: 150, child: TCircularLoader())),
      );

      // Delete Image
      await mediaRepository.deleteFileFromStorage(image);

      // Get the corresponding list to update
      RxList<ImageModel> targetList;

      // Check the selected category and update the corresponding list
      switch (selectedPath.value) {
        case MediaCategory.banners:
          targetList = allBannerImages;
          break;
        case MediaCategory.brands:
          targetList = allBrandImages;
          break;
        case MediaCategory.categories:
          targetList = allCategoryImages;
          break;
        case MediaCategory.products:
          targetList = allProductImages;
          break;
        case MediaCategory.users:
          targetList = allUserImages;
          break;
        default:
          return;
      }

      // Remove from the list
      targetList.remove(image);

      update();
      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
          title: 'Image Deleted',
          message: 'Image successfully deleted from your cloud storage');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Images Selection Bottom Sheet
  Future<List<ImageModel>?> selectImagesFromMedia(
      {List<String>? alreadySelectedUrls,
      bool allowSelection = true,
      bool allowMultipleSelection = false}) async {
    showImagesUploaderSection.value = true;
    List<ImageModel>? selectedImages = await Get.bottomSheet<List<ImageModel>>(
      isScrollControlled: true,
      backgroundColor: TColors.primaryBackground,
      FractionallySizedBox(
        heightFactor: 1,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                const MediaUploader(),
                MediaContent(
                  allowSelection: allowSelection,
                  alreadySelectedUrls: alreadySelectedUrls ?? [],
                  allowMultipleSelection: allowMultipleSelection,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return selectedImages;
  }
}
